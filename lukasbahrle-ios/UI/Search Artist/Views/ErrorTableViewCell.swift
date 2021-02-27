//
//  ErrorTableViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class ErrorTableViewCell: UITableViewCell {
    
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var retryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    private func configure(){
        selectionStyle = .none
    }

    func set(model: PresentableSearchArtistError) {
        infoLabel.text = model.info
        retryLabel.text = model.retry
    }

}
