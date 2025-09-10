import Foundation
import Photos
import Combine

final class ScannerViewModel {
    struct Output {
        let progressPublisher: AnyPublisher<(processed: Int, total: Int, finished: Bool), Never>
        let groupsPublisher: AnyPublisher<[PhotoGroup: [String]], Never>
        let othersPublisher: AnyPublisher<[String], Never>
    }

    private let progressSubject = CurrentValueSubject<(processed: Int, total: Int, finished: Bool), Never>((0,0,false))
    private let groupsSubject = CurrentValueSubject<[PhotoGroup: [String]], Never>([:])
    private let othersSubject = CurrentValueSubject<[String], Never>([])

    private var assets: PHFetchResult<PHAsset>?
    private var cancellables = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "scanner.queue", qos: .userInitiated)

    private var processed = 0
    private var total = 0
    private var finished = false
    private var groups: [PhotoGroup: [String]] = [:]
    private var others: [String] = []

    func output() -> Output {
        .init(progressPublisher: progressSubject.eraseToAnyPublisher(),
              groupsPublisher: groupsSubject.eraseToAnyPublisher(),
              othersPublisher: othersSubject.eraseToAnyPublisher())
    }

    func requestAndStart() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized || status == .limited else {
                self.progressSubject.send((0,0,true))
                return
            }
            self.startScanOrResume()
        }
    }

    private func startScanOrResume() {
        self.assets = PHAsset.fetchAssets(with: .image, options: nil)
        self.total = self.assets?.count ?? 0

        if let savedIndex = Persistence.loadGroupIndex(), let savedState = Persistence.loadScanState() {
            self.groups = Dictionary(uniqueKeysWithValues: savedIndex.groups.compactMap { (k, v) in
                PhotoGroup(rawValue: k).map { ($0, v) }
            })
            self.others = savedIndex.others
            self.processed = min(savedState.processed, self.total)
            self.finished = savedState.finished

            DispatchQueue.main.async {
                self.groupsSubject.send(self.groups)
                self.othersSubject.send(self.others)
                self.progressSubject.send((self.processed, self.total, self.finished))
            }

            if !self.finished {
                self.scan(startAt: self.processed)
            }
        } else {
            DispatchQueue.main.async {
                self.progressSubject.send((0, self.total, false))
            }
            self.scan(startAt: 0)
        }
    }

    private func scan(startAt index: Int) {
        guard let assets = self.assets, total > 0 else {
            DispatchQueue.main.async {
                self.finished = true
                self.progressSubject.send((self.total, self.total, true))
            }
            return
        }

        queue.async {
            let count = assets.count
            if index >= count {
                DispatchQueue.main.async {
                    self.finished = true
                    self.progressSubject.send((self.processed, self.total, true))
                    self.persist()
                }
                return
            }

            for i in index..<count {
                autoreleasepool {
                    let asset = assets.object(at: i)
                    let hash = asset.reliableHash()

                    if let group = PhotoGroup.group(for: hash) {
                        var arr = self.groups[group, default: []]
                        arr.append(asset.localIdentifier)
                        self.groups[group] = arr
                    } else {
                        self.others.append(asset.localIdentifier)
                    }

                    self.processed += 1

                    if self.processed % 10 == 0 || self.processed == count {
                        DispatchQueue.main.async {
                            self.groupsSubject.send(self.groups)
                            self.othersSubject.send(self.others)
                            self.progressSubject.send((self.processed, self.total, self.processed == self.total))
                        }
                        self.persist()
                    }
                }
            }

            DispatchQueue.main.async {
                self.finished = true
                self.progressSubject.send((self.processed, self.total, true))
                self.persist()
            }
        }
    }

    private func persist() {
        let encGroups = Dictionary(uniqueKeysWithValues: self.groups.map { ($0.key.rawValue, $0.value) })
        let groupIndex = GroupIndex(groups: encGroups, others: self.others)
        Persistence.saveGroupIndex(groupIndex)

        let state = ScanState(total: self.total, processed: self.processed, finished: self.finished)
        Persistence.saveScanState(state)
    }

    func itemsFor(group: PhotoGroup?) -> [String] {
        if let g = group { return groups[g] ?? [] }
        return others
    }
}
