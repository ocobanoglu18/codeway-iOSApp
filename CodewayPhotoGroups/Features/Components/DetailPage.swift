import SwiftUI
import Foundation
import Photos

struct DetailPage: View {
   let localIdentifier: String
   @State private var image: UIImage? = nil

   var body: some View {
       ZStack {
           if let img = image {
               Image(uiImage: img).resizable().scaledToFit()
                   .background(Color.black.opacity(0.95))
                   .ignoresSafeArea()
           } else {
               Color.black.opacity(0.95).ignoresSafeArea()
                   .overlay(ProgressView().tint(.white))
           }
       }
       .task {
           if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
               await withCheckedContinuation { cont in
                   ImageLoader.shared.requestFullSize(for: asset) { img in
                       self.image = img
                       cont.resume()
                   }
               }
           }
       }
   }
}
