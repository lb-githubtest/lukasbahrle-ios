//
//  LoadingTableViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    @IBOutlet private var indicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()

    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator.startAnimating()
    }
    
    private func configure(){
        selectionStyle = .none
    }
}
