//
//  ArtistDetailViewController.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class ArtistDetailViewController: UICollectionViewController {

    let numberOfTopCells = 1
    
    var viewModel: ArtistDetailViewModel! {
        didSet{
            bind()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        
        collectionView.collectionViewLayout = layout
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: LoadingCollectionViewCell.self))
        collectionView.register(ArtistDetailInfoCell.self, forCellWithReuseIdentifier: String(describing: ArtistDetailInfoCell.self))
        collectionView.register(AlbumsDatesCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: AlbumsDatesCollectionViewCell.self))
        
        enableDragDrop()
        
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func bind(){
        self.title = viewModel.title
        //viewModel.observer = self
        
        viewModel.albumsLoadState.valueChanged = { [weak self] state in
            switch state {
            case .loaded(canLoadMore: _, countAdded: let count):
                self?.onAlbumsLoaded(countAdded: count)
            default:
                break
            }
        }
    }
    
    private func enableDragDrop(){
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
    }
    
    private func onAlbumsLoaded(countAdded: Int){
        
        let startIndex = viewModel.numberOfContentItems - countAdded
        let endIndex = viewModel.numberOfContentItems - 1
        var indexPaths: [IndexPath] = []
        
        for index in startIndex...endIndex{
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        
        
        
        collectionView.insertItems(at: indexPaths)
    }
}


//extension ArtistDetailViewController: ArtistDetailViewModelObserver{
//
//    func onLoadingStateChange(value: LoadState, previous: LoadState) {
//
//    }
//
//    func onAlbumListUpdated() {
//        collectionView.reloadData()
//    }
//
//    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>) {
//        guard let cell = collectionView.cellForItem(at: IndexPath(row: index + numberOfTopCells, section: 0)) as? AlbumViewCell else {return}
//        cell.onImageLoadResult(result: result)
//    }
//
//    func onAlbumsFilterDatesChanged(start: (text: String, date: Date)?, end: (text: String, date: Date)?) {
//        guard let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? AlbumsDatesCollectionViewCell else {return}
//        cell.set(start: start, end: end)
//    }
//}
//
//extension ArtistDetailViewController: AlbumsFilterDatesViewDelegate{
//    func onAlbumsFilterStartDateChange(_ date: Date) {
//        viewModel.onAlbumsFilterStartDateChange(date)
//    }
//
//    func onAlbumsFilterEndDateChange(_ date: Date) {
//        viewModel.onAlbumsFilterEndDateChange(date)
//    }
//}


// MARK: UICollectionViewDataSource

extension ArtistDetailViewController{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfContentItems
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let contentType = viewModel.contentType(at: indexPath.row)
        
        switch contentType {
        case .artistInfo:
            return makeArtistInfoCell(collectionView: collectionView, indexPath: indexPath)
        case .albumsFilterDates:
            return makeAlbumsFilterDatesCell(collectionView: collectionView, indexPath: indexPath)
        case .album:
            return makeAlbumCell(collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(ArtistDetailHeaderView.self)",
                for: indexPath) as? ArtistDetailHeaderView
              else {
                fatalError("Invalid view type")
            }

        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CellPreloadable{
            cell.preload()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CellPreloadable{
            cell.cancelLoad()
        }
    }
}



// MARK: Cells

extension ArtistDetailViewController{
    func makeArtistInfoCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ArtistDetailInfoCell.self), for: indexPath) as! ArtistDetailInfoCell
        
        cell.setup(viewModel: viewModel.artistInfoViewModel())
        return cell
    }
    
    func makeAlbumsFilterDatesCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumsDatesCollectionViewCell.self), for: indexPath) as! AlbumsDatesCollectionViewCell
        
        cell.setup(viewModel: viewModel.albumsDatesFilterViewModel())
        return cell
    }
    
    func makeAlbumCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        
        guard let albumViewModel = viewModel.album(at: indexPath.row) else {
                fatalError()
                }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumViewCell.self), for: indexPath) as! AlbumViewCell
        
        cell.setup(viewModel: albumViewModel)
        return cell
    }
}
