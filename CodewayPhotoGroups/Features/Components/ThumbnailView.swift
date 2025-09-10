import SwiftUI
import Photos

struct ThumbnailView: View {
    let localIdentifier: String
    @State private var image: UIImage? = nil

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                Color.secondary.opacity(0.2)
                    .overlay(ProgressView())
            }
        }
        .task {
            if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                await withCheckedContinuation { cont in
                    ImageLoader.shared.requestThumbnail(for: asset, targetSize: CGSize(width: 200, height: 200)) { img in
                        self.image = img
                        cont.resume()
                    }
                }
            }
        }
    }
}
