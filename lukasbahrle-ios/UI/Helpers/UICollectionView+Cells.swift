//
//  UICollectionView+Cells.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 06/03/2021.
//

import UIKit

extension UICollectionView {
    func register(_ cellClass: AnyClass){
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withReuseIdentifier:identifier, for: indexPath) as! T
    }
}
