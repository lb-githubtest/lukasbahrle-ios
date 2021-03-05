//
//  AlbumsFilter.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 05/03/2021.
//

import Foundation


public enum AlbumsFilter{
    case date(start: Date?, end: Date?)
    
    func filter(album: Album) -> Bool{
        switch self {
        case let .date(start: startDate, end: endDate):
            return filterByDates(album: album, start: startDate, end: endDate)
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
