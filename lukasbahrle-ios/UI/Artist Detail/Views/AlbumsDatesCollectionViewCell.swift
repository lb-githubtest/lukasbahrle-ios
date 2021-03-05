//
//  AlbumsDatesCollectionViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import UIKit
import ArtistBrowser

protocol AlbumsFilterDatesViewDelegate: class{
    func onAlbumsFilterStartDateChange(_ date: Date)
    func onAlbumsFilterEndDateChange(_ date: Date)
}

class AlbumsDatesCollectionViewCell: UICollectionViewCell {
    private var startDateView: UITextField = UITextField()
    private var endDateView: UITextField = UITextField()
    
    private var viewModel: AlbumsDatesFilterCellViewModel?
    
    private let datePicker = UIDatePicker()
    public weak var delegate: AlbumsFilterDatesViewDelegate?
    
    private var startDate: Date?
    private var endDate: Date?
    
    private lazy var inputToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
        toolbar.setItems([doneBtn], animated: true)
        return toolbar
    }()
    
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
        delegate = nil
    }
    
    public func setup(viewModel: AlbumsDatesFilterCellViewModel){
        self.viewModel = viewModel
        
        startDate = viewModel.startDate?.date
        startDateView.text = viewModel.startDate?.text
        
        endDate = viewModel.endDate?.date
        endDateView.text = viewModel.endDate?.text
    }
    
    private func configure(){
        contentView.addSubview(startDateView)
        contentView.addSubview(endDateView)
        
        datePicker.datePickerMode = .date
        startDateView.inputAccessoryView = inputToolbar
        startDateView.inputView = datePicker
        startDateView.borderStyle = .roundedRect
        endDateView.inputAccessoryView = inputToolbar
        endDateView.inputView = datePicker
        endDateView.borderStyle = .roundedRect
        
        configureConstraints()
        
        startDateView.placeholder = "Start date"
        endDateView.placeholder = "End date"
        
        startDateView.adjustsFontForContentSizeCategory = true
        endDateView.adjustsFontForContentSizeCategory = true
    }
    
    
    private func configureConstraints(){
        startDateView.translatesAutoresizingMaskIntoConstraints = false
        endDateView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            startDateView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
            startDateView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            startDateView.trailingAnchor.constraint(equalTo: endDateView.leadingAnchor, constant: -10),
            startDateView.widthAnchor.constraint(equalTo: endDateView.widthAnchor),
            
            endDateView.topAnchor.constraint(equalTo: startDateView.topAnchor, constant: 0),
            endDateView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
        ])
    }
    
    
    @objc private func doneEditing(){
        if startDateView.isEditing {
            delegate?.onAlbumsFilterStartDateChange(datePicker.date)
        }
        else if endDateView.isEditing {
            delegate?.onAlbumsFilterEndDateChange(datePicker.date)
        }
        
        self.endEditing(true)
    }
}
