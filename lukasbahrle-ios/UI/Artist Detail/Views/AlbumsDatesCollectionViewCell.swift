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
    private var titleView: UILabel = UILabel()
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
        delegate = nil
    }
    
    public func setup(viewModel: AlbumsDatesFilterCellViewModel){
        startDate = viewModel.startDate?.date
        startDateView.text = viewModel.startDate?.text
        
        endDate = viewModel.endDate?.date
        endDateView.text = viewModel.endDate?.text
    }
    
    private func configure(){
        
        contentView.addSubview(titleView)
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
        
        titleView.text = "Albums"
        titleView.set(style: .title3)
        startDateView.placeholder = "Start date"
        endDateView.placeholder = "End date"
    }
    
    
    private func configureConstraints(){
        titleView.translatesAutoresizingMaskIntoConstraints = false
        startDateView.translatesAutoresizingMaskIntoConstraints = false
        endDateView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: margins.topAnchor),
            
            startDateView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            startDateView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
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
