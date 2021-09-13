//
//  SettingsTableViewCell.swift
//
//
//  Created by CASPERON on 21/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var setting_Lbl:UILabel!
    @IBOutlet weak var setting_Img:UIImageView!
    @IBOutlet weak var rightArrow_ImgView: UIImageView!
    @IBOutlet weak var subDesc_Lbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setting_Img.layer.cornerRadius = 8.0
        setting_Img.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
