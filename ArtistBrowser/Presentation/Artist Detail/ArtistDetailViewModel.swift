//
//  ArtistDetailViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import Foundation


public protocol ArtistDetailViewModelObserver: NSObject {
    func onLoadingStateChange(value: LoadState, previous: LoadState)
    func onAlbumListUpdated()
    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>)
    func onAlbumsFilterDatesChanged(start: (text: String, date:Date)? , end: (text: String, date: Date)?)
}


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
    case albumsFilterDates
    case album
}

protocol ArtistDetailViewModelType {
    var title: String {get}
    
    var numberOfContentItems: Int {get}
    func contentType(at index: Int) -> ArtistDetailContentType
    
    func artistInfoViewModel() -> ArtistInfoCellViewModel
    func albumsDatesFilterViewModel() -> AlbumsDatesFilterCellViewModel
    
    var albumsLoadState: Observable<AlbumsLoadState> {get}
    var numberOfAlbums: Int {get}
    func album(at index: Int) -> AlbumCellViewModel?
    
    var albumsFilterStartDate: Observable<Date?> {get}
    var albumsFilterEndDate: Observable<Date?> {get}
    
    func viewDidLoad()
    func scrolledToBottom()
    
    func reorderAlbum(from: Int, to: Int)
}


public class ArtistDetailViewModel: ArtistDetailViewModelType{
    
    public var title: String = "Detail"
    
    public var numberOfContentItems: Int {contentTypes.count - 1 + numberOfAlbums}
    public func contentType(at index: Int) -> ArtistDetailContentType {
        if index < contentTypes.count {
            return contentTypes[index]
        }
        return .album
    }
    
    public var albumsLoadState: Observable<AlbumsLoadState> = Observable(AlbumsLoadState.notLoaded)
    
    public var numberOfAlbums: Int {
        albumsDataModel.count
    }
    
    public func album(at index: Int) -> AlbumCellViewModel? {
        AlbumCellViewModel(album: albumsDataModel[index - (contentTypes.count - 1)], imageLoader: imageDataLoader)
    }
    
    public func artistInfoViewModel() -> ArtistInfoCellViewModel {
        ArtistInfoCellViewModel(artist: artist, imageLoader: imageDataLoader)
    }
    
    public func albumsDatesFilterViewModel() -> AlbumsDatesFilterCellViewModel {
        AlbumsDatesFilterCellViewModel()
    }
    
    public var albumsFilterStartDate: Observable<Date?> = Observable(nil)
    public var albumsFilterEndDate: Observable<Date?> = Observable(nil)
    
    public func viewDidLoad() {
        loadNextPage()
    }
    
    public func scrolledToBottom() {
        loadNextPage()
    }
    
    public func reorderAlbum(from: Int, to: Int) {
        
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
    
    private let albumsLoader: AlbumsLoader
    private let imageDataLoader: ImageDataLoader
    
    private var contentTypes: [ArtistDetailContentType] = [.artistInfo, .albumsFilterDates, .album]
    
    private var currentAlbumsTask: CancellableTask?
    
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
        albumsDataModel.append(contentsOf: albums.items)
        albumsLoadState.value = .loaded(canLoadMore: albums.canLoadMore, countAdded: albums.items.count)
    }
    
    private func onAlbumListLoadError(error: Error){
        albumsLoadState.value = .failed
        //loadState = .error(PresentableSearchArtistError(info: "Couldn't connect to the server", retry: "Tap to retry"))
    }
}





//public struct PresentableAlbum{
//    public let id: String
//    public let name:String
//    public let thumbnail: URL?
//}

//
//public class ArtistDetailViewModel: ArtistDetailViewModelType{
//
//    public var observer: ArtistDetailViewModelObserver?
//
//    public var numberOfAlbums: Int {
//        return albumsDataModel.count
//    }
//
//    public func album(at index: Int) -> PresentableAlbum? {
//        guard index < albumsDataModel.count else {return nil}
//        let album = albumsDataModel[index]
//        return PresentableAlbum(id: album.id, name: album.name, thumbnail: album.thumbnail)
//    }
//
//    public var loadState: LoadState = .none
//
//    public var title: String = ""
//
//    public var albumsStartDate: (text: String, date: Date)? {
//        didSet{
//
//            onAlbumsFilterDatesChanged()
//        }
//    }
//    public var albumsEndDate: (text: String, date: Date)? {
//        didSet{
//            onAlbumsFilterDatesChanged()
//        }
//    }
//
//    private let artist: Artist
//    private var albumsDataModel = [Album]()
//
//    private let albumsLoader: AlbumsLoader
//    private let imageDataLoader: ImageDataLoader
//
//    private var currentTask: CancellableTask?
//    private var itemLoadingTasks = [Int: CancellableTask]()
//
//    private lazy var dateFormatter:DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        return formatter
//    }()
//
//    public init(artist: Artist, albumsLoader: AlbumsLoader, imageDataLoader: ImageDataLoader){
//        self.artist = artist
//        self.title = artist.name
//        self.albumsLoader = albumsLoader
//        self.imageDataLoader = imageDataLoader
//    }
//
//    public func viewDidLoad() {
//        loadAlbums(loadedItems: 0)
//    }
//
//    public func scrolledToBottom() {
//        loadNextPage()
//    }
//
//    public func preloadItem(at index: Int) {
//        guard itemLoadingTasks[index] == nil, index < albumsDataModel.count else {
//            return
//        }
//
//        guard let imageURL = albumsDataModel[index].thumbnail else {
//            return
//        }
//
//        itemLoadingTasks[index] = imageDataLoader.load(from: imageURL, completion: { [weak self] result in
//            DispatchQueue.main.async {
//                self?.observer?.onItemPreloadCompleted(index: index, result: result)
//                self?.itemLoadingTasks[index] = nil
//            }
//        })
//    }
//
//    public func cancelItem(at index: Int) {
//        itemLoadingTasks[index]?.cancel()
//        itemLoadingTasks[index] = nil
//    }
//
//    public func retryLoad() {
//
//    }
//
//    public func reorderAlbum(from: Int, to: Int) {
//        let album = albumsDataModel[from]
//        albumsDataModel.remove(at: from)
//        albumsDataModel.insert(album, at: to)
//    }
//
//
//    public func onAlbumsFilterStartDateChange(_ date: Date){
//        albumsStartDate = (text: formattedDate(date: date), date: date)
//    }
//
//    public func onAlbumsFilterEndDateChange(_ date: Date) {
//        albumsEndDate = (text: formattedDate(date: date), date: date)
//    }
//
//
//    private func loadNextPage() {
//        guard loadState != .loading, loadState != .none, albumsDataModel.count > 0 else {return}
//        loadAlbums(loadedItems: albumsDataModel.count)
//    }
//
//    private func loadAlbums(loadedItems: Int){
//        loadState = .loading
//        currentTask?.cancel()
//
//        currentTask = albumsLoader.load(loadedItems: loadedItems) { [weak self] (result) in
//
//            DispatchQueue.main.async {
//                switch result{
//                    case .success(let albumsList):
//                        self?.onAlbumListLoaded(albums: albumsList)
//                    case .failure(let error):
//                        self?.onAlbumListLoadError(error: error)
//                }
//            }
//        }
//    }
//
//    private func onAlbumListLoaded(albums: AlbumList){
//        albumsDataModel.append(contentsOf: albums.items)
//
//        loadState = albums.canLoadMore ? .waiting : .none
//
//        observer?.onAlbumListUpdated()
//    }
//
//    private func onAlbumListLoadError(error: Error){
//        loadState = .error(PresentableSearchArtistError(info: "Couldn't connect to the server", retry: "Tap to retry"))
//
//    }
//
//    private func onAlbumsFilterDatesChanged(){
//
//        observer?.onAlbumsFilterDatesChanged(start: albumsStartDate, end: albumsEndDate)
//    }
//
//    private func formattedDate(date: Date) -> String{
//        let text = dateFormatter.string(from: date)
//        return text
//    }
//
//}
