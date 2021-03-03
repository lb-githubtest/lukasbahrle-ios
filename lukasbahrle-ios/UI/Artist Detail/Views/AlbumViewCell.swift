//
//  AlbumViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class AlbumViewCell: UICollectionViewCell {
    private var thumbnailView: UIImageView = UIImageView()
    private var nameLabel: UILabel = UILabel()
    
    private var viewModel: AlbumCellViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func configure(){
        contentView.addSubview(thumbnailView)
        contentView.addSubview(nameLabel)
        
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.set(style: .footnote, numberOfLines: 2)
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            thumbnailView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            thumbnailView.topAnchor.constraint(equalTo: margins.topAnchor),
            thumbnailView.heightAnchor.constraint(equalTo: thumbnailView.widthAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 8),
        ])
    }
    
    func setup(viewModel: AlbumCellViewModel){
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
        
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
