//
//  AlbumsDatesCollectionViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import UIKit

protocol AlbumsFilterDatesViewDelegate: class{
    func onAlbumsFilterStartDateChange(_ date: Date)
    func onAlbumsFilterEndDateChange(_ date: Date)
}

class AlbumsDatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var titleView: UILabel!
    @IBOutlet private var startDateView: UITextField!
    @IBOutlet private var endDateView: UITextField!
    
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForReuse() {
        delegate = nil
    }
    
    public func set(start: (text: String, date: Date)?, end: (text: String, date: Date)?){
        startDate = start?.date
        startDateView.text = start?.text
        
        
        endDate = end?.date
        endDateView.text = end?.text
    }
    
    private func configure(){
        datePicker.datePickerMode = .date
        startDateView.inputAccessoryView = inputToolbar
        startDateView.inputView = datePicker
        endDateView.inputAccessoryView = inputToolbar
        endDateView.inputView = datePicker
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
