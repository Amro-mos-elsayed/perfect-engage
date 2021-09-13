//
//  SettingHeaderTableViewCell.swift
//
//
//  Created by CASPERON on 22/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class SettingHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.backgroundColor = .clear
        userImage.layer.cornerRadius =  userImage.frame.width/2
        userImage.clipsToBounds = true
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.lightGray.cgColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
