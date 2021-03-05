//
//  AlbumsDatesFilterCellViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

public class AlbumsDatesFilterCellViewModel{
    public var startDate: (text: String, date:Date)?
    public var endDate: (text: String, date: Date)?
    
//    private var onStartDateChanged: ((Date) -> Void)?
//    private var onEndDateChanged: ((Date) -> Void)?
    
    init(startDate: Date?, endDate: Date?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        if let startDate = startDate {
            self.startDate = (text: formatter.string(from: startDate), date: startDate)
        }
        
        if let endDate = endDate {
            self.endDate = (text: formatter.string(from: endDate), date: endDate)
        }
        
       
//        self.onStartDateChanged = onStartDateChanged
//        self.onEndDateChanged = onEndDateChanged
    }
    
//    public func onInputStartDateChange(_ date:Date){
//        onStartDateChanged?(date)
//    }
//
//    public func onInputEndDateChange(_ date:Date){
//
//        onEndDateChanged?(date)
//    }
}
