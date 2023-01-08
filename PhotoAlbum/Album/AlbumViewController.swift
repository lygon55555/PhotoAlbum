//
//  AlbumViewController.swift
//  PhotoAlbum
//
//  Created by Yonghyun on 2023/01/07.
//

import UIKit
import Photos

final class AlbumViewController: UIViewController {
    private enum Const {
        static let numberOfColumns: CGFloat = 3
        static let cellSpace: CGFloat = 1
        static let length = (UIScreen.main.bounds.size.width - cellSpace * (numberOfColumns - 1)) / numberOfColumns
        static let cellSize = CGSize(width: length, height: length)
        static let scale = UIScreen.main.scale
    }
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Const.cellSpace
        layout.minimumInteritemSpacing = Const.cellSpace
        layout.itemSize = Const.cellSize
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.contentInset = .zero
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var selectedAlbum: PHFetchResult<PHAsset>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayouts()
    }
    
    private func setLayouts() {
        setProperties()
        setViewHierarchy()
        setConstraints()
    }
    
    private func setProperties() {
        self.view.backgroundColor = .white
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    private func setViewHierarchy() {
        self.view.addSubview(collectionView)
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func showImageData(_ filename: String, _ filesize: String) {
        let alert = UIAlertController(title: "사진정보", message: "파일명 : \(filename) \n 파일크기 : \(filesize)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }
}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAlbum.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else { fatalError() }
        
        PhotoManager.fetchImage(
            asset: self.selectedAlbum[indexPath.item],
            size: .init(width: Const.length * Const.scale, height: Const.length * Const.scale),
            contentMode: .aspectFit
        ) { [weak cell] image in
            DispatchQueue.main.async {
                cell?.imageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result = PhotoManager.getImageData(asset: selectedAlbum[indexPath.row])
        showImageData(result.0, result.1)
    }
}

extension AlbumViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) { }
}
