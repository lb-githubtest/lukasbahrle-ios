//
//  ArtistDetailViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import Foundation

public class ArtistDetailViewModel{
    
    public var title: String = "Detail"
    
    public func viewDidLoad() {
        loadNextPage()
    }
    
    
    // MARK: ViewModels
    
    public var artistInfoViewModel: ArtistInfoCellViewModel{
        ArtistInfoCellViewModel(artist: artist, imageLoader: imageDataLoader)
    }
    
    public var albumsHeaderViewModel: AlbumsHeaderCellViewModel{
        AlbumsHeaderCellViewModel(title: "Albums")
    }
    
    public var albumsDatesFilterViewModel: AlbumsDatesFilterCellViewModel{
        AlbumsDatesFilterCellViewModel(startDate: albumsFilterStartDate, endDate: albumsFilterEndDate)
    }
    
    public var errorViewModel: ErrorViewModel{
        ErrorViewModel(info: "Couldn't connect to the server", retry: "Tap to retry")
    }
    
    public func album(at index: Int) -> AlbumCellViewModel? {
        let pos = filteredAlbumsDataModel?[index] ?? index
        
        let album = albumsDataModel[pos]
        
        if let viewModel = albumsCellViewModels[album.id] {
            return viewModel
        }
        
        let cellViewModel = AlbumCellViewModel(album: album, imageLoader: imageDataLoader)
        albumsCellViewModels[album.id] = cellViewModel
        return cellViewModel
    }
    
    
    // MARK: Sections
    
    public var numberOfSections: Int {arrSectionTypes.count}
    
    public func sectionType(at index: Int) -> ArtistDetailContentType {
        if index < arrSectionTypes.count {
            return arrSectionTypes[index]
        }
        return .albumCollection
    }
    
    public func sectionIndexFor(type: ArtistDetailContentType) -> Int?{
        return arrSectionTypes.firstIndex(of: type)
    }
    
    
    // MARK: Albums
    
    public var onAlbumsCollectionUpdate: (() -> Void)?
    
    public var albumsLoadState: Observable<ContentLoadState> = Observable(ContentLoadState.notLoaded)
    
    public var numberOfAlbums: Int {
        filteredAlbumsDataModel?.count ?? albumsDataModel.count
    }
   
    public func scrolledToBottom() {
        guard albumsLoadState.current != .failed else {return}
        loadNextPage()
    }
    
    public func loadingCellTap(){
        guard albumsLoadState.current == .failed else {return}
        loadNextPage()
    }
    
    // MARK: Reorder
    
    public func reorderAlbum(from: Int, to: Int) {
        let posFrom = filteredAlbumsDataModel?[from] ?? from
        let posTo = filteredAlbumsDataModel?[to] ?? to
        
        let album = albumsDataModel[posFrom]
        albumsDataModel.remove(at: posFrom)
        albumsDataModel.insert(album, at: posTo)
    }
    
    
    // MARK: Filters
    
    public var numberOfAlbumFilters: Int {
        albumsFilters.count
    }
    
    public func albumFilterType(at index: Int) -> AlbumsFilter? {
        albumsFilters[index]
    }
    
    public func updateAlbumsFilterStartDateChange(_ date: Date){
        albumsFilterStartDate = date
    }

    public func updateAlbumsFilterEndDateChange(_ date: Date) {
        albumsFilterEndDate = date
    }
    
    
    public init(artist: Artist, albumsLoader: AlbumsLoader, imageDataLoader: ImageDataLoader){
        self.artist = artist
        self.title = artist.name
        self.albumsLoader = albumsLoader
        self.imageDataLoader = imageDataLoader
    }
    
    // MARK: Private
    
    private let artist: Artist
    private var albumsDataModel = [Album]()
    private var filteredAlbumsDataModel: [Int]?
    private var albumsCellViewModels = [String: AlbumCellViewModel]()
    
    private let albumsLoader: AlbumsLoader
    private let imageDataLoader: ImageDataLoader
    
    private var arrSectionTypes: [ArtistDetailContentType] = [.artistInfo, .albumTitle, .albumsFilters, .albumCollection]
    
    private var currentAlbumsTask: CancellableTask?
    
    private var albumsFilterStartDate: Date? {
        didSet{
            onAlbumsDatesFilterUpdate()
        }
    }
    private var albumsFilterEndDate: Date? {
        didSet{
            onAlbumsDatesFilterUpdate()
        }
    }
    private var albumsFilters: [AlbumsFilter] {
        [AlbumsFilter.date(start: albumsFilterStartDate, end: albumsFilterEndDate)]
    }
}



// MARK: Load Albums

extension ArtistDetailViewModel{
    private func loadNextPage() {
        guard albumsLoadState.value != .loading, albumsLoadState.value.canLoadMore else {return}
        
        loadAlbums(loadedItems: albumsDataModel.count)
    }
    
    private func loadAlbums(loadedItems: Int){
        albumsLoadState.value = .loading
        currentAlbumsTask?.cancel()

        currentAlbumsTask = albumsLoader.load(loadedItems: loadedItems) { [weak self] (result) in
            
            switch result{
                case .success(let albumsList):
                    self?.onAlbumListLoaded(albums: albumsList)
                case .failure(let error):
                    self?.onAlbumListLoadError(error: error)
            }
        }
    }
    
    private func onAlbumListLoaded(albums: AlbumList){
        var countAdded = albums.items.count
        if let _ = filteredAlbumsDataModel {
            
            let numberOfAlbums = albumsDataModel.count
            let filteredIndexes = filter(albums: albums.items, filters: albumsFilters).map{$0 + numberOfAlbums}
            
            self.filteredAlbumsDataModel?.append(contentsOf: filteredIndexes)
            
            countAdded = filteredIndexes.count
        }
        
        albumsDataModel.append(contentsOf: albums.items)
        albumsLoadState.value = .loaded(canLoadMore: albums.canLoadMore, countAdded: countAdded)
    }
    
    private func onAlbumListLoadError(error: Error){
        albumsLoadState.value = .failed
    }
    
   
}


// MARK: Album Filters

extension ArtistDetailViewModel{
    private func onAlbumsDatesFilterUpdate(){
        filteredAlbumsDataModel = filter(albums: albumsDataModel, filters: albumsFilters)
        onAlbumsCollectionUpdate?()
    }
    
    private func filter(albums: [Album], filters: [AlbumsFilter]) -> [Int]{
        var indexes = [Int]()
        
        for (index, album) in albums.enumerated() {
            
            var isOk = true
            
            for filter in filters {
                if !filter.filter(album: album) {
                    isOk = false
                }
            }
            
            if isOk {
                indexes.append(index)
            }
        }
        return indexes
    }
}
