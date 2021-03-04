//
//  AlbumsTitleCollectionViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 04/03/2021.
//

import UIKit
import ArtistBrowser

class AlbumsHeaderCollectionViewCell: UICollectionViewCell {
    private var titleLabel = UILabel()
    
    func setup(viewModel:AlbumsHeaderCellViewModel){
        titleLabel.text = viewModel.title
    }
}
