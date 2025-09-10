import SwiftUI
import Photos

struct GroupDetailView: View {
    let group: PhotoGroup?
    @ObservedObject private var adapter: GroupAdapter

    init(group: PhotoGroup?, viewModel: ScannerViewModel) {
        self.group = group
        self.adapter = GroupAdapter(viewModel: viewModel, group: group)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(adapter.assetIDs, id: \.self) { id in
                    ThumbnailView(localIdentifier: id)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .onTapGesture {
                            adapter.openDetail(for: id)
                        }
                }
            }
            .padding(12)
        }
        .sheet(item: $adapter.sheet) { sheet in
            ImageDetailView(ids: sheet.ids, currentID: sheet.currentID)
        }
        .onAppear {
            adapter.refresh()
        }
    }
}


