//
//  ArtistDetailViewController+Layout.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import UIKit


extension ArtistDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let availableWidth = collectionView.bounds.size.width
        
        if indexPath.section >= viewModel.numberOfSections {
            return CGSize(width: availableWidth, height: 100)
        }
        let sectionType = viewModel.sectionType(at: indexPath.section)

        switch sectionType {
            case .artistInfo:
                return CGSize(width: availableWidth, height: availableWidth + 100)
            case .albumTitle:
                return CGSize(width: availableWidth, height: 40)
            case .albumsFilters:
                return CGSize(width: availableWidth, height: 60)
            case .albumCollection:
                let columns:CGFloat = 2
                let cellWidth = ((availableWidth) / columns).rounded(.down)
                
                return CGSize(width: cellWidth, height: cellWidth + 40)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
