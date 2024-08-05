//
//  ResultCell.swift
//  ios-TextDetectionSample
//
//  Created by Necati Alperen IŞIK on 2.08.2024.
//

import UIKit

class ResultCell: UITableViewCell {
    static let identifier = "ResultTableViewCell"
    
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(resultLabel)
        
        
        NSLayoutConstraint.activate([
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            resultLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        resultLabel.text = text
    }
}

