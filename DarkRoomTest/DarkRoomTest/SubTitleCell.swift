//
//  SubTitleCell.swift
//  DarkRoomTest
//
//  Created by 엑소더스이엔티 on 2023/10/20.
//

import UIKit

class SubTitleCell: UITableViewCell {
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subTitleLabel.textColor = .white
    }
    
    func configure(subTitle: String) {
        subTitleLabel.text = subTitle
    }
}
