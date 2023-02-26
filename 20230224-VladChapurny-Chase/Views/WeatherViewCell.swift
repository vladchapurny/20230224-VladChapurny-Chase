//
//  WeatherViewCell.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import UIKit

/*
 * Custom Cell for WeatherTable
 */
class WeatherViewCell: UITableViewCell {
    
    // MARK: Variables
    /// Set title of the cell
    var titleText: String? {
        didSet {
            /// update correct label
            self.title.text = titleText
        }
    }
    
    /// Set info of the cell
    var infoText: String? {
        didSet {
            /// update correct label
            self.info.text = infoText
        }
    }
    
    // MARK: Init
    /// Build the cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        addSubview(title)
        addSubview(info)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            title.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            title.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            info.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            info.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            info.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Views
    /// Title label
    private let title: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.AFFontBold(size: 16)
        return lbl
    }()
    
    /// Info label
    private let info: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.AFFontRegular(size: 16)
        return lbl
    }()
}
