//
//  MainQueueAlbumsLoader.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import ArtistBrowser

class MainQueueAlbumsLoader: AlbumsLoader {
    private let albumsLoader: AlbumsLoader
    
    init(albumsLoader: AlbumsLoader){
        self.albumsLoader = albumsLoader
    }

    func load(loadedItems: Int, completion: @escaping (AlbumsLoader.Result) -> Void) -> CancellableTask {
        return albumsLoader.load(loadedItems: loadedItems) { result in
            if Thread.isMainThread { completion(result) }
            else{
                DispatchQueue.main.async{completion(result)}
            }
        }
    }

}
