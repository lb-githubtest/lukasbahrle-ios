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
    
    private var viewModel: AlbumCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func configure(){}
    
    func setup(viewModel: AlbumCellViewModel){
        self.viewModel = viewModel
        albumNameLabel.text = viewModel.name
        
        viewModel.image.state.valueChanged = { [weak self] state in
            self?.onThumbnailStateChanged(state)
        }
    }
    
    private func onThumbnailStateChanged(_ state: ImageState){
        switch state {
        case .loaded(data: let data):
            onArtistThumbnailDateLoaded(data)
        default:
            break
        }
    }
    
    private func onArtistThumbnailDateLoaded(_ data: Data){
        thumbnailView.image = UIImage(data: data)
    }
    
    private func reset(){
        thumbnailView.image = nil
        viewModel?.cancel()
        viewModel = nil
    }
    
}


extension AlbumViewCell: CellPreloadable{
    func preload() {
        viewModel?.preload()
    }
    
    func cancelLoad() {
        viewModel?.cancel()
    }
}
