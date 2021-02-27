//
//  AlbumViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class AlbumViewCell: UICollectionViewCell {
    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var albumNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    private func configure(){
        self.contentView.backgroundColor = .red
    }
    
    func set(info: PresentableAlbum){
        albumNameLabel.text = info.name
    }
}
