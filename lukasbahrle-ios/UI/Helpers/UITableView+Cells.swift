//
//  UITableView+Cells.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 06/03/2021.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
