import UIKit
import Photos
import Combine
import SwiftUI

final class HomeViewController: UICollectionViewController {
    private let viewModel = ScannerViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var grouped: [PhotoGroup: [String]] = [:]
    private var others: [String] = []

    private var processed: Int = 0
    private var total: Int = 0

    init() {
        let layout = HomeViewController.makeLayout()
        super.init(collectionViewLayout: layout)
        title = "Photo Groups"
        configureNav()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        AppearanceManager.apply()
        view.backgroundColor = .systemGroupedBackground
        collectionView.backgroundColor = .clear

        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: GroupCell.reuseID)
        collectionView.register(ProgressHeaderView.self,
                                forSupplementaryViewOfKind: ProgressHeaderView.kind,
                                withReuseIdentifier: ProgressHeaderView.reuseID)

        bindViewModel()
        viewModel.requestAndStart()
    }

    private func configureNav() {
        navigationController?.navigationBar.prefersLargeTitles = true

        let refresh = UIAction(title: "Rescan", image: UIImage(systemName: "arrow.clockwise")) { [weak self] _ in
            self?.viewModel.requestAndStart()
        }
        let sortAZ = UIAction(title: "Sort A–Z", image: UIImage(systemName: "textformat.abc")) { [weak self] _ in
            self?.collectionView.reloadData()
        }

        func themeAction(for appearance: AppAppearance) -> UIAction {
            UIAction(
                title: appearance.title,
                state: AppearanceManager.current == appearance ? .on : .off
            ) { _ in
                AppearanceManager.current = appearance
            }
        }

        if #available(iOS 15.0, *) {
            let themeMenu = UIMenu(title: "Theme", options: .displayInline, children: [
                themeAction(for: .system),
                themeAction(for: .light),
                themeAction(for: .dark)
            ])

            let mainMenu = UIMenu(title: "", children: [refresh, sortAZ, themeMenu])

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: nil,
                image: UIImage(systemName: "ellipsis.circle"),
                primaryAction: nil,
                menu: mainMenu
            )
        } else {
            // iOS 14 and earlier: use an action sheet
            let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showActionsLegacy))
            navigationItem.rightBarButtonItem = button
        }
    }

    @objc private func showActionsLegacy() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Rescan", style: .default) { [weak self] _ in
            self?.viewModel.requestAndStart()
        })
        alert.addAction(UIAlertAction(title: "Sort A–Z", style: .default) { [weak self] _ in
            self?.collectionView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }


    private func bindViewModel() {
        let output = viewModel.output()

        output.groupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] groups in
                self?.grouped = groups
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        output.othersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                self?.others = ids
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        output.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                guard let self else { return }
                let (processed, total, _) = progress
                self.processed = processed
                self.total = total

                if let header = self.collectionView.visibleSupplementaryViews(ofKind: ProgressHeaderView.kind).first as? ProgressHeaderView {
                    let pct = total > 0 ? Float(processed) / Float(total) : 0
                    header.render(percent: pct, processed: processed, total: total)
                }
            }
            .store(in: &cancellables)
    }

    private func groupsDisplayList() -> [(title: String, count: Int, group: PhotoGroup?)] {
        var result: [(title: String, count: Int, group: PhotoGroup?)] = []

        for g in PhotoGroup.allCases {
            if let count = grouped[g]?.count, count > 0 {
                result.append((title: g.rawValue.uppercased(), count: count, group: g))
            }
        }
        if !others.isEmpty {
            result.append((title: "Others", count: others.count, group: nil))
        }

        return result.sorted(by: { lhs, rhs in
            let lhsIsGroup = lhs.group != nil
            let rhsIsGroup = rhs.group != nil
            if lhsIsGroup != rhsIsGroup {
                return lhsIsGroup && !rhsIsGroup
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        })
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let nonEmpty = grouped.filter { !$0.value.isEmpty }
        let othersCount = others.isEmpty ? 0 : 1
        return nonEmpty.count + othersCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCell.reuseID, for: indexPath) as? GroupCell else {
            return UICollectionViewCell()
        }
        let items = groupsDisplayList()
        let entry = items[indexPath.item]
        cell.configure(title: entry.title, count: entry.count)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let items = groupsDisplayList()
        let entry = items[indexPath.item]
        let detail = GroupDetailView(group: entry.group, viewModel: viewModel)
        let hosting = UIHostingController(rootView: detail)
        hosting.title = entry.title
        navigationController?.pushViewController(hosting, animated: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }


    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == ProgressHeaderView.kind else { return UICollectionReusableView() }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ProgressHeaderView.kind,
                                                                     withReuseIdentifier: ProgressHeaderView.reuseID,
                                                                     for: indexPath) as! ProgressHeaderView
        let pct = total > 0 ? Float(processed) / Float(total) : 0
        header.render(percent: pct, processed: processed, total: total)
        return header
    }
    
    private static func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(104) 
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(104)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 14
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(72)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: ProgressHeaderView.kind,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        header.zIndex = 2
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

}

