//
//  SearchArtistViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 25/02/2021.
//

import Foundation

public protocol SearchArtistViewModelObserver {
    func onLoadingStateChange(isLoading: Bool)
    func onArtistsLoaded(artists: ArtistList)
    func onErrorStateChange(message: String?)
}


public class SearchArtistViewModel{
    private let loader: SearchArtistLoader
    
    public init(loader: SearchArtistLoader) {
        self.loader = loader
    }
    
    public var title: String {
        "Artist Browser"
    }
    
    public var observer: SearchArtistViewModelObserver?
    
    public func searchArtist(input: String){
        observer?.onLoadingStateChange(isLoading: true)
        observer?.onErrorStateChange(message: nil)
        
        loader.load { [weak self] result in
            guard let self = self else {return}
         
            switch result {
            case let .success(artists):
                self.observer?.onArtistsLoaded(artists: artists)
                case .failure(_):
                    self.observer?.onErrorStateChange(message: "Error")
            }
            
            self.observer?.onLoadingStateChange(isLoading: false)
        }
    }
}
