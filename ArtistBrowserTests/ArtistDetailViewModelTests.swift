//
//  ArtistDetailViewModelTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import XCTest
import ArtistBrowser

class ArtistDetailViewModelTests: XCTestCase {

    func test_initialState(){
        let (sut, _, _) = makeSUT()
        
        XCTAssertEqual(sut.albumsLoadState.current, ContentLoadState.notLoaded)
        XCTAssertEqual(sut.numberOfAlbums, 0)
    }
    
    
    func test_viewDidLoad_requestsFirstPage(){
        let (sut, albumsLoader, imageLoader) = makeSUT()
        
        sut.viewDidLoad()
        
        XCTAssertEqual(albumsLoader.requests, [0])
        XCTAssertEqual(imageLoader.requests, [])
    }
    
    func test_successAlbumLoad_updatesStateChange(){
        let (sut, albumsLoader, _) = makeSUT()
        
        sut.viewDidLoad()
        
        let albums: [Album] = [
            makeAlbum(id: "1", name: "name 1"),
            makeAlbum(id: "2", name: "name 2"),
            makeAlbum(id: "3", name: "name 3")
        ]
        
        let albumList = AlbumList(items: albums, canLoadMore: true)
        
        albumsLoader.complete(result: albumList)
        
        XCTAssertEqual(sut.albumsLoadState.current, ContentLoadState.loaded(canLoadMore: true, countAdded: 3))
        XCTAssertEqual(sut.numberOfAlbums, 3)
    }
    
    func test_dateFilterChange_updatesNumberOfVisibleAlbums(){
        let (sut, albumsLoader, _) = makeSUT()
        
        sut.viewDidLoad()
        
        let today = Date()
        
        let albums: [Album] = [
            makeAlbum(id: "1", name: "name 1", releaseDate: today.adding(days: -5)),
            makeAlbum(id: "2", name: "name 2", releaseDate: today.adding(days: -3)),
            makeAlbum(id: "3", name: "name 3", releaseDate: today.adding(days: -1))
        ]
        
        let albumList = AlbumList(items: albums, canLoadMore: true)
        
        albumsLoader.complete(result: albumList)
        
        XCTAssertEqual(sut.numberOfAlbums, 3)
        
        sut.updateAlbumsFilterEndDateChange(today.adding(days: -2))
        
        XCTAssertEqual(sut.numberOfAlbums, 2)
        
        sut.updateAlbumsFilterStartDateChange(today.adding(days: -4))
        
        XCTAssertEqual(sut.numberOfAlbums, 1)
    }
    
    // MARK: Helpers
    
    private func makeSUT(artist: Artist = Artist.any()) -> (ArtistDetailViewModel, AlbumsLoaderSpy, ImageDataLoaderSpy){
       
        let albumsLoader = AlbumsLoaderSpy()
        
        let imageDataLoader = ImageDataLoaderSpy()
        
        let sut = ArtistDetailViewModel(artist: artist, albumsLoader: albumsLoader, imageDataLoader: imageDataLoader)
        return (sut, albumsLoader, imageDataLoader)
    }
    
    private func makeArtist(id: String, name:String, thumbnail: URL?, genres: [String]) -> Artist{
        Artist(id: id, name: name, thumbnail: thumbnail, genres: genres)
    }
    
    private func makeAlbum(id: String, name: String, url: URL = URL.any(), releaseDate: Date = Date()) -> Album{
        Album(id: id, name: name, thumbnail: url, releaseDate: releaseDate)
    }
    

}


private extension Artist{
    static func any()  -> Artist{
        Artist(id: UUID().uuidString, name: "any name", thumbnail: URL.any(), genres: [])
    }
}


private class AlbumsLoaderSpy: AlbumsLoader {
    private struct Task: CancellableTask {
        func cancel() { }
    }
    
    private var messages = [(loadedItems: Int, completion: (AlbumsLoader.Result) -> Void)]()
    
    var requests: [Int] {
        return messages.map { $0.loadedItems }
    }
    
    func complete(result: AlbumList, at index: Int = 0) {
        messages[index].completion(.success((result)))
    }
    
    func load(loadedItems: Int, completion: @escaping (AlbumsLoader.Result) -> Void) -> CancellableTask {
        messages.append((loadedItems, completion))
        return Task()
    }
}


private class ImageDataLoaderSpy: ImageDataLoader {
    private struct Task: CancellableTask {
        func cancel() { }
    }
    
    private var messages = [(url: URL, completion: (Result<Data, Error>) -> Void)]()
    
    var requests: [URL] {
        return messages.map { $0.url }
    }
    
    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> CancellableTask {
        messages.append((url, completion))
        return Task()
    }
}


extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
