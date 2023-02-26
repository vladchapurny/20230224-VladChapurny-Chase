//
//  WeatherViewCell.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import UIKit

class WeatherViewCell: UITableViewCell {
    
    var titleText: String? {
        didSet {
            self.title.text = titleText
        }
    }
    
    var infoText: String? {
        didSet {
            self.info.text = infoText
        }
    }
    
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
    
    private let title: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.AFFontBold(size: 16)
        return lbl
    }()
    
    private let info: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.AFFontRegular(size: 16)
        return lbl
    }()
}
