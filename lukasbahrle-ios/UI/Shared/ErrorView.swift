//
//  ErrorView.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 07/03/2021.
//

import UIKit
import ArtistBrowser

class ErrorView: UIView {
    private var infoLabel: UILabel = UILabel()
    private var retryLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func didMoveToSuperview() {
        configure()
    }
    
    func setup(viewModel: ErrorViewModel) {
        infoLabel.text = viewModel.info
        retryLabel.text = viewModel.retry
    }
    
    private func configure(){
        self.addSubview(infoLabel)
        self.addSubview(retryLabel)
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.set(style: .body)
        infoLabel.textAlignment = .center
        retryLabel.translatesAutoresizingMaskIntoConstraints = false
        retryLabel.set(style: .body)
        retryLabel.textAlignment = .center
        
        let margins = self.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            infoLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8),
            infoLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            retryLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            retryLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 4),
            retryLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            retryLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }


}

