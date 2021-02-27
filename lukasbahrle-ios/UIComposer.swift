//
//  UIComposer.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class UIComposer{
    static func makeArtistBrowserViewController() -> ArtistBrowserViewController{
        
        let bundle = Bundle(for: ArtistBrowserViewController.self)
        let storyboard = UIStoryboard(name: "ArtistBrowser", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ArtistBrowserViewController
        
        let searchArtistLoader = RemoteSearchArtistLoader(request: { input, loadedItems in
            var builder = SearchArtistRequestBuilder()
            builder.set(input: input, loadedItems: loadedItems)
            let request = SearchArtisRequest(builder: builder)
            
            return request.get()
        }, client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        let imageLoader = RemoteImageDataLoader(client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        let viewModel = SearchArtistViewModel(searchArtistLoader: searchArtistLoader, imageDataLoader: imageLoader, onArtistSelected: { artist in
            print("EOOO:: \(artist.name)")
        })
        
        controller.viewModel = viewModel
        
        return controller
    }
}
