//
//  PhotoManager.swift
//  PhotoAlbum
//
//  Created by Yonghyun on 2023/01/08.
//

import UIKit
import Photos

struct PhotoManager {
    static func fetchImage(asset: PHAsset, size: CGSize, contentMode: PHImageContentMode, completion: @escaping (UIImage) -> Void) {
        let imageManager = PHCachingImageManager()
        
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: contentMode, options: option) { image, _ in
            guard let image = image else { return }
            image.accessibilityIdentifier = asset.value(forKey: "filename") as? String
            completion(image)
        }
    }
    
    static func getImageData(asset: PHAsset) -> (String, String) {
        var filesize = ""
        let resources = PHAssetResource.assetResources(for: asset)
        let filename = resources.first!.originalFilename
        
        var sizeOnDisk: Int64 = 0
        
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
            filesize = String(format: "%.2f", Double(sizeOnDisk) / (1024.0*1024.0))+" MB"
        }
        
        return (filename, filesize)
    }
}
