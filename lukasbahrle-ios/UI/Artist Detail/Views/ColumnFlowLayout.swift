//
//  ColumnFlowLayout.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        
        let availableWidth = collectionView.bounds.size.width
        //inset(by: collectionView.layoutMargins).width
        let maxNumColumns:CGFloat = 3//Int(availableWidth / minColumnWidth)
        let cellWidth = ((availableWidth) / CGFloat(maxNumColumns)).rounded(.down)
        
        self.itemSize = CGSize(width: cellWidth, height: cellWidth + 40)
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        self.sectionInsetReference = .fromSafeArea
    }
}
