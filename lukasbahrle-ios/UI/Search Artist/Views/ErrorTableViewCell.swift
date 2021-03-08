//
//  ErrorTableViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class ErrorTableViewCell: UITableViewCell {
    private var errorView = ErrorView(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(viewModel: ErrorViewModel) {
        errorView.setup(viewModel: viewModel)
    }
    
    private func configure(){
        selectionStyle = .none
        
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
