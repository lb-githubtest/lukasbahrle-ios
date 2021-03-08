//
//  ArtistDetailViewController+DragDrop.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import UIKit
import ArtistBrowser

extension ArtistDetailViewController: UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        guard viewModel.albumsLoadState.current != .loading else {
            return []
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? Draggable else{
            return []
        }
        
        let itemProvider = NSItemProvider(object: cell.dragItemProvider)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = cell.dragLocalObject
        
        return [dragItem]
    }
}


extension ArtistDetailViewController: UICollectionViewDropDelegate{
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        
        guard let albumsSection = viewModel.sectionIndexFor(type: .albumCollection) else {
            return
        }
        
        if  let targetIndexPath = coordinator.destinationIndexPath {
            if targetIndexPath.section < albumsSection {
                destinationIndexPath = IndexPath(item: 0, section: albumsSection)
            }
            else if targetIndexPath.section > albumsSection {
                let row = collectionView.numberOfItems(inSection: albumsSection)
                destinationIndexPath = IndexPath(item: row - 1, section: albumsSection)
            }
            else {
                destinationIndexPath = targetIndexPath
            }
        }
        else{
            let row = collectionView.numberOfItems(inSection: albumsSection)
            destinationIndexPath = IndexPath(item: row - 1, section: albumsSection)
        }
        
        if coordinator.proposal.operation == .move {
           self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let albumsSection = viewModel.sectionIndexFor(type: .albumCollection) else {
            
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        guard collectionView.hasActiveDrag, let destinationIndexPath = destinationIndexPath, destinationIndexPath.section == albumsSection else {
            
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        self.onDragDropCompleted()
    }
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath:IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath {
            
            collectionView.performBatchUpdates({
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
                self.viewModel.reorderAlbum(from: sourceIndexPath.item, to: destinationIndexPath.item)
                
            }, completion: nil)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    private func onDragDropCompleted(){
        loadMoreAlbumsIfScrolledBottom(dragDropCompleted: true)
    }
    
}
