//
//  ListViewController.swift
//  PhotoAlbum
//
//  Created by Yonghyun on 2023/01/06.
//

import UIKit
import Photos

class ListViewController: UITableViewController {
    
    enum Section: Int {
        case recentAlbum = 0
        case customAlbums
        
        static let count = 2
    }
    
    var recentAlbum: PHFetchResult<PHAsset>!
    var customAlbumsCollections: PHFetchResult<PHCollection>!
    var customAlbums: [PHFetchResult<PHAsset>] = []
    let sectionLocalizedTitles = ["", NSLocalizedString("Albums", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "앨범"
        tableView.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        
        let recentAlbumOptions = PHFetchOptions()
        recentAlbumOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        recentAlbum = PHAsset.fetchAssets(with: recentAlbumOptions)
        customAlbumsCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        for num in 0..<customAlbumsCollections.count {
            let collection = customAlbumsCollections.object(at: num)
            
            guard let assetCollection = collection as? PHAssetCollection else { fatalError() }
            customAlbums.append(PHAsset.fetchAssets(in: assetCollection, options: nil))
        }
        
        PHPhotoLibrary.shared().register(self)
    }
}

extension ListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .recentAlbum:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else { fatalError() }
            cell.albumTitle.text = "Recents"
            cell.numberOfImages.text = String(recentAlbum.count)
            
            if let firstAsset = recentAlbum.firstObject {
                PhotoManager.fetchImage(
                    asset: firstAsset,
                    size: .init(width: 70, height: 70),
                    contentMode: .aspectFit
                ) { [weak cell] image in
                    DispatchQueue.main.async {
                        cell?.thumbnail.image = image
                    }
                }
            }
            
            return cell
            
        case .customAlbums:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else { fatalError() }
            let collection = customAlbumsCollections.object(at: indexPath.row)
            cell.albumTitle.text = collection.localizedTitle
            cell.numberOfImages.text = String(customAlbums[indexPath.row].count)
            
            if let firstAsset = customAlbums[indexPath.row].firstObject {
                PhotoManager.fetchImage(
                    asset: firstAsset,
                    size: .init(width: 70, height: 70),
                    contentMode: .aspectFit
                ) { [weak cell] image in
                    DispatchQueue.main.async {
                        cell?.thumbnail.image = image
                    }
                }
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .recentAlbum: return 1
        case .customAlbums: return customAlbumsCollections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AlbumViewController()
        
        switch Section(rawValue: indexPath.section)! {
        case .recentAlbum:
            vc.navigationItem.title = "Recents"
            vc.selectedAlbum = recentAlbum
        case .customAlbums:
            guard let collection = customAlbumsCollections.object(at: indexPath.row) as? PHAssetCollection else { fatalError() }
            vc.selectedAlbum = PHAsset.fetchAssets(in: collection, options: nil)
            vc.navigationItem.title = collection.localizedTitle
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

extension ListViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: recentAlbum) {
                recentAlbum = changeDetails.fetchResultAfterChanges
            }
            
            if let changeDetails = changeInstance.changeDetails(for: customAlbumsCollections) {
                customAlbumsCollections = changeDetails.fetchResultAfterChanges
                for num in 0..<customAlbumsCollections.count {
                    let collection = customAlbumsCollections.object(at: num)
                    guard let assetCollection = collection as? PHAssetCollection else { fatalError() }
                    customAlbums.append(PHAsset.fetchAssets(in: assetCollection, options: nil))
                }
            }
            
            tableView.reloadData()
        }
    }
}
