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
    
    private var widthConstraint: NSLayoutConstraint!
    
    private lazy var inputToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
        toolbar.setItems([space, doneBtn], animated: true)
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
    
    public func setup(viewModel: AlbumsDatesFilterCellViewModel, width: CGFloat){
        self.viewModel = viewModel
        
        startDate = viewModel.startDate?.date
        startDateView.placeholder = viewModel.startDatePlaceholder
        startDateView.text = viewModel.startDate?.text
        
        endDate = viewModel.endDate?.date
        endDateView.placeholder = viewModel.endDatePlaceholder
        endDateView.text = viewModel.endDate?.text
        
        widthConstraint.constant = width
    }
    
    private func configure(){
        configure(textfield: startDateView)
        configure(textfield: endDateView)
        
        configure(datePicker: datePicker)
        configureConstraints()
    }
    
    
    private func configureConstraints(){
        startDateView.translatesAutoresizingMaskIntoConstraints = false
        endDateView.translatesAutoresizingMaskIntoConstraints = false
        
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 200)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint
            ])
        
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
    
    private func configure(datePicker: UIDatePicker){
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *){
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    private func configure(textfield: UITextField){
        contentView.addSubview(textfield)
        textfield.inputAccessoryView = inputToolbar
        textfield.inputView = datePicker
        textfield.borderStyle = .roundedRect
        textfield.set(style: .footnote)
        textfield.adjustsFontForContentSizeCategory = true
        textfield.delegate = self
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


extension AlbumsDatesCollectionViewCell: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // only allow editing through the date picker
        return false
    }
}
