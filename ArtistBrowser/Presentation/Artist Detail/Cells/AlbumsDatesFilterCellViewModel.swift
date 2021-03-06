//
//  AlbumsDatesFilterCellViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

public struct AlbumsDatesFilterCellViewModel{
    public let startDate: (text: String, date:Date)?
    public let endDate: (text: String, date: Date)?
    
    init(startDate: Date?, endDate: Date?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        if let startDate = startDate {
            self.startDate = (text: formatter.string(from: startDate), date: startDate)
        }
        else{
            self.startDate = nil
        }
        
        if let endDate = endDate {
            self.endDate = (text: formatter.string(from: endDate), date: endDate)
        }
        else{
            self.endDate = nil
        }
    }
}
