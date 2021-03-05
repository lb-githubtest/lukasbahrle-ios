//
//  ArtistDetailViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import Foundation


//public protocol ArtistDetailViewModelObserver: NSObject {
//    func onLoadingStateChange(value: LoadState, previous: LoadState)
//    func onAlbumListUpdated()
//    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>)
//    func onAlbumsFilterDatesChanged(start: (text: String, date:Date)? , end: (text: String, date: Date)?)
//}


public enum AlbumsLoadState: Equatable{
    case notLoaded
    case loading
    case failed
    case loaded(canLoadMore: Bool, countAdded: Int)
    
    public var canLoadMore: Bool {
        switch self {
        case .loaded(canLoadMore: let canLoadMore, countAdded: _):
            return canLoadMore
        default:
            return true
        }
    }
}

public enum ArtistDetailContentType{
    case artistInfo
    case albumTitle
    case albumsFilterDates
    case albumCollection
}


public enum AlbumsFilter{
    case date(start: Date?, end: Date?)
    
    func filter(album: Album) -> Bool{
        switch self {
        case let .date(start: startDate, end: endDate):
            return filterByDates(album: album, start: startDate, end: endDate)
        default:
            return true
        }
    }
    
    func filterByDates(album: Album, start: Date?, end: Date?) -> Bool{
        if let start = start, start > album.releaseDate{
            return false
        }
        
        if let end = end, end < album.releaseDate{
            return false
        }
        
        return true
    }
}






protocol ArtistDetailViewModelType {
    var title: String {get}
    
    var numberOfSections: Int {get}
    func sectionType(at index: Int) -> ArtistDetailContentType
    func sectionIndexFor(type: ArtistDetailContentType) -> Int?
    
    func artistInfoViewModel() -> ArtistInfoCellViewModel
    func albumsHeaderViewModel() -> AlbumsHeaderCellViewModel
    func albumsDatesFilterViewModel() -> AlbumsDatesFilterCellViewModel
    
    var albumsLoadState: Observable<AlbumsLoadState> {get}
    var numberOfAlbums: Int {get}
    func album(at index: Int) -> AlbumCellViewModel?
    
    var albumsFilters: [AlbumsFilter] {get}
    
    func viewDidLoad()
    func scrolledToBottom()
    
    func reorderAlbum(from: Int, to: Int)
    
    var onAlbumsCollectionUpdate: (() -> Void)? {get set}
    
    func updateAlbumsFilterStartDateChange(_ date: Date)
    func updateAlbumsFilterEndDateChange(_ date: Date)
}



public class ArtistDetailViewModel: ArtistDetailViewModelType{
    public var title: String = "Detail"
    
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
    
    public var albumsLoadState: Observable<AlbumsLoadState> = Observable(AlbumsLoadState.notLoaded)
    
    public var numberOfAlbums: Int {
        filteredAlbumsDataModel?.count ?? albumsDataModel.count
    }
    
    public func album(at index: Int) -> AlbumCellViewModel? {
        let pos = filteredAlbumsDataModel?[index] ?? index
        return AlbumCellViewModel(album: albumsDataModel[pos], imageLoader: imageDataLoader)
    }
    
    public var albumsFilters: [AlbumsFilter] {
        [AlbumsFilter.date(start: albumsFilterStartDate, end: albumsFilterEndDate)]
    }
    
    
    public func artistInfoViewModel() -> ArtistInfoCellViewModel {
        ArtistInfoCellViewModel(artist: artist, imageLoader: imageDataLoader)
    }
    
    public func albumsHeaderViewModel() -> AlbumsHeaderCellViewModel {
        AlbumsHeaderCellViewModel(title: "Albumssss")
    }
    
    public func albumsDatesFilterViewModel() -> AlbumsDatesFilterCellViewModel {
        AlbumsDatesFilterCellViewModel(startDate: albumsFilterStartDate, endDate: albumsFilterEndDate)
    }
    
    public var onAlbumsCollectionUpdate: (() -> Void)?
    
    public func viewDidLoad() {
        loadNextPage()
    }
    
    public func scrolledToBottom() {
        loadNextPage()
    }
    
    public func reorderAlbum(from: Int, to: Int) {
        let posFrom = filteredAlbumsDataModel?[from] ?? from
        let posTo = filteredAlbumsDataModel?[to] ?? to
        
        let album = albumsDataModel[posFrom]
        albumsDataModel.remove(at: posFrom)
        albumsDataModel.insert(album, at: posTo)
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
    
    private let albumsLoader: AlbumsLoader
    private let imageDataLoader: ImageDataLoader
    
    private var arrSectionTypes: [ArtistDetailContentType] = [.artistInfo, .albumTitle, .albumsFilterDates, .albumCollection]
    
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
}



// MARK: Albums

extension ArtistDetailViewModel{
    private func loadNextPage() {
        
        guard albumsLoadState.value != .loading, albumsLoadState.value.canLoadMore else {return}

        loadAlbums(loadedItems: albumsDataModel.count)
    }
    
    private func loadAlbums(loadedItems: Int){
        albumsLoadState.value = .loading
        currentAlbumsTask?.cancel()

        currentAlbumsTask = albumsLoader.load(loadedItems: loadedItems) { [weak self] (result) in

            DispatchQueue.main.async {
                switch result{
                    case .success(let albumsList):
                        
                        self?.onAlbumListLoaded(albums: albumsList)
                    case .failure(let error):
                        self?.onAlbumListLoadError(error: error)
                }
            }
        }
    }
    
    private func onAlbumListLoaded(albums: AlbumList){
        var countAdded = albums.items.count
        print("onAlbumListLoaded: \(albums)")
        if let _ = filteredAlbumsDataModel {
            
            let numberOfAlbums = albumsDataModel.count
            let filteredIndexes = filter(albums: albums.items, filters: albumsFilters).map{$0 + numberOfAlbums}
            
            self.filteredAlbumsDataModel?.append(contentsOf: filteredIndexes)
            
            countAdded = filteredIndexes.count
        }
        
        albumsDataModel.append(contentsOf: albums.items)
        albumsLoadState.value = .loaded(canLoadMore: albums.canLoadMore, countAdded: countAdded)
        
        print("countAdded: \(countAdded)")
    }
    
    private func onAlbumListLoadError(error: Error){
        albumsLoadState.value = .failed
        //loadState = .error(PresentableSearchArtistError(info: "Couldn't connect to the server", retry: "Tap to retry"))
        print("onAlbumListLoadError: \(error)")
    }
    
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
