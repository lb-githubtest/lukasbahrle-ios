//
//  ArtistSearchResultCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit
import ArtistBrowser

protocol CellPreloadable{
    func preload()
    func cancelLoad()
}


class ArtistSearchResultCell: UITableViewCell {
    
    private var nameLabel = UILabel()
    private var thumbnailView = UIImageView(frame: .zero)
    
    private var viewModel: SearchArtistResultCellViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func setup(viewModel: SearchArtistResultCellViewModel){
        self.viewModel = viewModel
        
        nameLabel.text = viewModel.artistName
        
        switch viewModel.image.state.current {
        case .loaded(let data):
            thumbnailView.image = UIImage(data: data)
        default:
            viewModel.image.state.valueChanged = { [weak self] state in
                self?.onThumbnailStateChanged(state)
            }
        }
    }
    
    private func configure(){
        contentView.addSubview(thumbnailView)
        contentView.addSubview(nameLabel)
        
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.set(style: .body, numberOfLines: 0)
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            thumbnailView.topAnchor.constraint(equalTo: margins.topAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 100),
            thumbnailView.heightAnchor.constraint(equalTo: thumbnailView.widthAnchor),
            thumbnailView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: thumbnailView.centerYAnchor),
        ])
    }
    
    private func onThumbnailStateChanged(_ state: ImageState){
        
        switch state {
        case .loaded(data: let data):
            onArtistThumbnailDateLoaded(data)
        default:
            break
        }
    }
    
    
    private func reset(){
        thumbnailView.image = nil
        viewModel?.cancel()
        viewModel = nil
    }
    
    private func onArtistThumbnailDateLoaded(_ data: Data){
        thumbnailView.image = UIImage(data: data)
    }
}


extension ArtistSearchResultCell: CellPreloadable{
    func preload() {
        viewModel?.preload()
    }
    
    func cancelLoad() {
        viewModel?.cancel()
    }
}
