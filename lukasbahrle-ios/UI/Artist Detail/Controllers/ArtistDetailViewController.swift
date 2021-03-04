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
        collectionView.register(AlbumViewCell.self, forCellWithReuseIdentifier: String(describing: AlbumViewCell.self))
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: LoadingCollectionViewCell.self))
        collectionView.register(ArtistDetailInfoCell.self, forCellWithReuseIdentifier: String(describing: ArtistDetailInfoCell.self))
        collectionView.register(AlbumsDatesCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: AlbumsDatesCollectionViewCell.self))
        collectionView.register(AlbumsHeaderCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: AlbumsHeaderCollectionViewCell.self))
        
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
            case .loaded(canLoadMore:let canLoadMore, countAdded: let count):
                self?.onAlbumsLoaded(canLoadMore: canLoadMore, countAdded: count)
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
    
    private func onAlbumsLoaded(canLoadMore: Bool, countAdded: Int){
        guard countAdded > 0, let albumsSection = viewModel.sectionIndexFor(type: .albumCollection) else {
            return
        }
       
        let loadingSection = viewModel.numberOfSections
        let startIndex = viewModel.numberOfAlbums - countAdded
        let endIndex = viewModel.numberOfAlbums - 1
        var indexPaths: [IndexPath] = []
        
        collectionView.performBatchUpdates {
            if endIndex >= startIndex {
                
               for index in startIndex...endIndex{
                   indexPaths.append(IndexPath(row: index, section: albumsSection))
               }
               collectionView.insertItems(at: indexPaths)
           }
            
            if !viewModel.albumsLoadState.current.canLoadMore {
                collectionView.deleteSections(IndexSet([loadingSection]))
            }
            
        
        }
        
        
    }
}


// MARK: UICollectionViewDataSource

extension ArtistDetailViewController{
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let loadingOrErrorSection = viewModel.albumsLoadState.current.canLoadMore ? 1 : 0
        
        return viewModel.numberOfSections + loadingOrErrorSection
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section >= viewModel.numberOfSections {
            return 1
        }
        
        let sectionType = viewModel.sectionType(at: section)
        
        switch sectionType {
        case .albumCollection:
            return viewModel.numberOfAlbums
        default:
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.section < viewModel.numberOfSections else{
            return makeLoadingCell(state: viewModel.albumsLoadState.current, collectionView: collectionView, indexPath: indexPath)
        }
        
        let sectionType = viewModel.sectionType(at: indexPath.section)
        
        switch sectionType {
            case .artistInfo:
                return makeArtistInfoCell(collectionView: collectionView, indexPath: indexPath)
            case .albumTitle:
                return makerAlbumsTitleCell(collectionView: collectionView, indexPath: indexPath)
            case .albumsFilterDates:
                return makeAlbumsFilterDatesCell(collectionView: collectionView, indexPath: indexPath)
            case .albumCollection:
                return makeAlbumCell(collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CellPreloadable{
            cell.preload()
        }
        else if indexPath.section == viewModel.numberOfSections {
            viewModel.scrolledToBottom()
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
    
    func makeLoadingCell(state: AlbumsLoadState, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LoadingCollectionViewCell.self), for: indexPath) as! LoadingCollectionViewCell
        
        return cell
    }
    
    func makerAlbumsTitleCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumsHeaderCollectionViewCell.self), for: indexPath) as! AlbumsHeaderCollectionViewCell
        
        cell.setup(viewModel: viewModel.albumsHeaderViewModel())
        
        return cell
    }
}



