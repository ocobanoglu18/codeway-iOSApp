import Foundation

final class GroupAdapter: ObservableObject {
    struct SheetState: Identifiable {
        let ids: [String]
        let currentID: String
        var id: String { currentID }
    }

    @Published var assetIDs: [String] = []
    @Published var sheet: SheetState? = nil

    private let viewModel: ScannerViewModel
    private let group: PhotoGroup?

    init(viewModel: ScannerViewModel, group: PhotoGroup?) {
        self.viewModel = viewModel
        self.group = group
    }

    func refresh() {
        self.assetIDs = viewModel.itemsFor(group: group)
    }

    func openDetail(for id: String) {
        self.sheet = .init(ids: self.assetIDs, currentID: id)
    }
}
