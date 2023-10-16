//
//  MediaPreviewView.swift
//  DarkRoomTest
//
//  Created by 엑소더스이엔티 on 2023/10/16.
//

import UIKit

class MediaPreviewView: UIView {
    let collectionview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.isPagingEnabled = true
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = .clear
        return collectionview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    private func prepare() {
        prepareBackgroundView()
        prepareCollectionView()
    }
    
    private func prepareBackgroundView() {
        let darkBackground = UIView()
        darkBackground.translatesAutoresizingMaskIntoConstraints = false
        darkBackground.backgroundColor = .black
        darkBackground.alpha = 0.7
        addSubview(darkBackground)
        
        NSLayoutConstraint.activate([
            darkBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            darkBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            darkBackground.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            darkBackground.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    private func prepareCollectionView() {
        addSubview(collectionview)
        
        NSLayoutConstraint.activate([
            collectionview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            collectionview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            collectionview.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            collectionview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
        
        collectionview.register(PreviewCell.self, forCellWithReuseIdentifier: "PreviewCell")
    }
}
