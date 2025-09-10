import SwiftUI
import Photos

struct ImageDetailView: View {
    let ids: [String]
    let currentID: String

    @State private var startIndex: Int = 0

    var body: some View {
        TabView(selection: $startIndex) {
            ForEach(ids.indices, id: \.self) { idx in
                DetailPage(localIdentifier: ids[idx])
                    .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .onAppear {
            if let idx = ids.firstIndex(of: currentID) {
                startIndex = idx
            }
        }
    }
}

