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
    
    func loadMoreAlbumsIfScrolledBottom(dragDropCompleted: Bool? = nil){
        
        if canLoadMoreAlbums &&  isLoadingCellIsVisible{
            onScrolledToBottom(dragDropCompleted: dragDropCompleted)
        }
    }
    
    private var loadingIndexPath: IndexPath {
        return IndexPath(row: 0, section: viewModel.numberOfSections)
    }
    
    private var canLoadMoreAlbums: Bool {
        viewModel.albumsLoadState.current.canLoadMore
    }
    
    private var isLoadingCellIsVisible: Bool {
        self.collectionView.indexPathsForVisibleItems.contains(self.loadingIndexPath)
    }
    
    private var isDragDropActive: Bool{
        collectionView.hasActiveDrag || collectionView.hasActiveDrop
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView.collectionViewLayout = layout
        registerCells()
        
        enableDragDrop()
        
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func bind(){
        self.title = viewModel.title
        
        viewModel.albumsLoadState.valueChanged = { [weak self] state in
            switch state {
            case .loaded(canLoadMore:let canLoadMore, countAdded: let count):
                self?.onAlbumsLoaded(canLoadMore: canLoadMore, countAdded: count)
            default:
                break
            }
        }
        
        viewModel.onAlbumsCollectionUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func registerCells(){
        collectionView.register(AlbumViewCell.self)
        collectionView.register(LoadingCollectionViewCell.self)
        collectionView.register(ArtistDetailInfoCell.self)
        collectionView.register(AlbumsDatesCollectionViewCell.self)
        collectionView.register(AlbumsHeaderCollectionViewCell.self)
    }
    
    private func enableDragDrop(){
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
    }
    
    private func onAlbumsLoaded(canLoadMore: Bool, countAdded: Int){
        guard let albumsSection = viewModel.sectionIndexFor(type: .albumCollection) else {
            return
        }
        
        let loadingSection = viewModel.numberOfSections
        let startIndex = viewModel.numberOfAlbums - countAdded
        let endIndex = viewModel.numberOfAlbums - 1
        var indexPaths: [IndexPath] = []
        
        print("onAlbumsLoaded:: \(countAdded) \(startIndex) \(endIndex)")
        print("viewModel.numberOfAlbums: \(viewModel.numberOfAlbums)")
        
        collectionView.performBatchUpdates {
            if endIndex >= startIndex, endIndex >= 0, startIndex >= 0 {
                
                print("startIndex: \(startIndex) \(endIndex)")
               for index in startIndex...endIndex{
                   indexPaths.append(IndexPath(row: index, section: albumsSection))
               }
               collectionView.insertItems(at: indexPaths)
           }
            
            if !canLoadMore {
                collectionView.deleteSections(IndexSet([loadingSection]))
            }
        } completion: { [weak self] completed in
            guard let self = self else {return}
            self.loadMoreAlbumsIfScrolledBottom()
        }
    }
    
    private func onScrolledToBottom(dragDropCompleted: Bool? = nil){
        
        let dragDropCompleted = dragDropCompleted ?? !isDragDropActive
        
        guard dragDropCompleted else {return}
        self.viewModel.scrolledToBottom()
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
        case .albumsFilters:
            return viewModel.numberOfAlbumFilters
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
            case .albumsFilters:
                guard let filterType = viewModel.albumFilterType(at: indexPath.row) else {
                    fatalError()
                }
                return makeAlbumFilterCell(type: filterType, collectionView: collectionView, indexPath: indexPath)
            case .albumCollection:
                return makeAlbumCell(collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CellPreloadable{
            cell.preload()
        }
        else if indexPath.section == viewModel.numberOfSections {
            onScrolledToBottom()
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
        let cell:ArtistDetailInfoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setup(viewModel: viewModel.artistInfoViewModel())
        return cell
    }
    
    func makeAlbumFilterCell(type: AlbumsFilter, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        switch type{
            case .date(_, _):
                return makeAlbumsFilterDatesCell(collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    func makeAlbumsFilterDatesCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell: AlbumsDatesCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.delegate = self
        cell.setup(viewModel: viewModel.albumsDatesFilterViewModel())
        return cell
    }
    
    func makeAlbumCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        
        guard let albumViewModel = viewModel.album(at: indexPath.row) else {
                fatalError()
                }
        
        let cell:AlbumViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.setup(viewModel: albumViewModel)
        return cell
    }
    
    func makeLoadingCell(state: ContentLoadState, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell: LoadingCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        return cell
    }
    
    func makerAlbumsTitleCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell{
        let cell:AlbumsHeaderCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.setup(viewModel: viewModel.albumsHeaderViewModel())
        
        return cell
    }
}


extension ArtistDetailViewController: AlbumsFilterDatesViewDelegate{
    func onAlbumsFilterStartDateChange(_ date: Date) {
        viewModel.updateAlbumsFilterStartDateChange(date)
    }
    
    func onAlbumsFilterEndDateChange(_ date: Date) {
        viewModel?.updateAlbumsFilterEndDateChange(date)
    }
}


