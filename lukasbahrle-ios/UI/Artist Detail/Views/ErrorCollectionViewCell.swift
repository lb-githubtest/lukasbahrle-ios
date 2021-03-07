//
//  ErrorCollectionViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 07/03/2021.
//

import UIKit
import ArtistBrowser

class ErrorCollectionViewCell: UICollectionViewCell {
    
    private var errorView = ErrorView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    func setup(viewModel: ErrorViewModel) {
        errorView.setup(viewModel: viewModel)
    }
    
    private func configure(){
        contentView.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

}
