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
    private var titleView: UILabel = UILabel()
    private var startDateView: UITextField = UITextField()
    private var endDateView: UITextField = UITextField()
    
    var cellWidth: CGFloat = 200
    
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
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {

            var targetSize = targetSize
            targetSize.width = cellWidth
            targetSize.height = CGFloat.greatestFiniteMagnitude

            let size = super.systemLayoutSizeFitting(
                    targetSize,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )

            return size
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
        
        contentView.addSubview(titleView)
        contentView.addSubview(startDateView)
        contentView.addSubview(endDateView)
        
        datePicker.datePickerMode = .date
        startDateView.inputAccessoryView = inputToolbar
        startDateView.inputView = datePicker
        endDateView.inputAccessoryView = inputToolbar
        endDateView.inputView = datePicker
        
        configureConstraints()
        
        contentView.backgroundColor = .green
        
        titleView.text = "Albums"
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
            
            startDateView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 0),
            startDateView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            startDateView.trailingAnchor.constraint(equalTo: endDateView.leadingAnchor),
            startDateView.widthAnchor.constraint(equalTo: endDateView.widthAnchor),
            
            endDateView.topAnchor.constraint(equalTo: startDateView.topAnchor, constant: 0),
            endDateView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            endDateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
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
