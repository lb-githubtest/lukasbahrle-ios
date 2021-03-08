//
//  Date+days.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import Foundation

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
