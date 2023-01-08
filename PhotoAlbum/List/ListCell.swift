//
//  ListCell.swift
//  PhotoAlbum
//
//  Created by Yonghyun on 2023/01/07.
//

import UIKit
import SnapKit
import Then

final class ListCell: UITableViewCell {
    
    let thumbnail = UIImageView()
    let labelStackView = UIStackView()
    let albumTitle = UILabel()
    let numberOfImages = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayouts()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        albumTitle.text = nil
        numberOfImages.text = nil
    }
    
    private func setLayouts() {
        setProperties()
        setViewHierarchy()
        setConstraints()
    }
    
    private func setProperties() {
        labelStackView.do {
            $0.axis = .vertical
            $0.distribution = .fillEqually
        }
        
        albumTitle.do {
            $0.textColor = .black
            $0.font = .systemFont(ofSize: 17)
        }
        
        numberOfImages.do {
            $0.textColor = .black
            $0.font = .systemFont(ofSize: 12)
        }
    }
    
    private func setViewHierarchy() {
        contentView.addSubview(thumbnail)
        contentView.addSubview(labelStackView)
        
        labelStackView.addArrangedSubview(albumTitle)
        labelStackView.addArrangedSubview(numberOfImages)
    }
    
    private func setConstraints() {
        thumbnail.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
        
        labelStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(thumbnail.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalTo(thumbnail).inset(10)
        }
    }
}
