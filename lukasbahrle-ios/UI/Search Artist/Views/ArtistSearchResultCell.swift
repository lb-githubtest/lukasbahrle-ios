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
    
    @IBOutlet private var label: UILabel!
    @IBOutlet private var thumbnail: UIImageView!
    
    private var viewModel: SearchArtistResultCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func setup(viewModel: SearchArtistResultCellViewModel){
        self.viewModel = viewModel
        
        label.text = viewModel.artistName
        
        viewModel.artistThumbnailState.valueChanged = { [weak self] thumbnailState in
            self?.onThumbnailStateChanged(thumbnailState)
        }
    }
    
    private func onThumbnailStateChanged(_ state: SearchArtistResultCellViewModel.ArtistThumbnailState){
        
        switch state {
        case .loaded(data: let data):
            onArtistThumbnailDateLoaded(data)
        default:
            break
        }
    }
    
    
    private func reset(){
        thumbnail.image = nil
        viewModel?.cancel()
        viewModel = nil
    }
    
    private func onArtistThumbnailDateLoaded(_ data: Data){
        thumbnail.image = UIImage(data: data)
    }
    
    
    
    
//    func onImageLoadResult(result: Result<Data, Error>){
//        switch result {
//        case .success(let data):
//            UIView.transition(with: self.thumbnail,
//                          duration:0.5,
//                          options: .transitionCrossDissolve,
//                          animations: { [weak self] in self?.thumbnail.image = UIImage(data: data) },
//                          completion: nil)
//
//        default:
//            break
//        }
//    }

}


extension ArtistSearchResultCell: CellPreloadable{
    func preload() {
        viewModel?.preload()
    }
    
    func cancelLoad() {
        viewModel?.cancel()
    }
}
