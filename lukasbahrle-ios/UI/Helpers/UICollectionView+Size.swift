//
//  UICollectionView+Size.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 01/03/2021.
//

import UIKit

extension UICollectionView {
    var maxCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return bounds.width - insets
    }
}
