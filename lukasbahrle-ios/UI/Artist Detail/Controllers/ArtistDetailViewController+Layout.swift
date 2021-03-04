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

        switch indexPath.section {
        case 0:
            let contentType = viewModel.contentType(at: indexPath.row)
            
            switch contentType {
            case .artistInfo:
                return CGSize(width: availableWidth, height: 470)
            case .albumsFilterDates:
                return CGSize(width: availableWidth, height: 90)
            default:
                let columns:CGFloat = 2
                let cellWidth = ((availableWidth) / columns).rounded(.down)
                return CGSize(width: cellWidth, height: cellWidth + 40)
            }
        case 1:
            return CGSize(width: availableWidth, height: 100)
        default:
            return CGSize.zero
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//            let indexPath = IndexPath(row: 0, section: section)
//            let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//
//            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
//                                                      withHorizontalFittingPriority: .required,
//                                                      verticalFittingPriority: .fittingSizeLevel)
//    }
}
