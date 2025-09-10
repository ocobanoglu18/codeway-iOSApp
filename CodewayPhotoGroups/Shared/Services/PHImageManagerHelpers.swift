import Photos
import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let imageManager = PHCachingImageManager()

    func requestThumbnail(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .opportunistic
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true

        imageManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFill,
                                  options: options) { image, _ in
            completion(image)
        }
    }

    func requestFullSize(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true

        imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            if let data = data, let img = UIImage(data: data) {
                completion(img)
            } else {
                completion(nil)
            }
        }
    }
}