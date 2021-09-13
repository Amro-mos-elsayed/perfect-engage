//
//  CallsTableViewCell.swift
//
//
//  Created by CASPERON on 16/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class CallsTableViewCell: UITableViewCell {
    @IBOutlet  var name_Lbl:UILabel!
    @IBOutlet  var time_Lbl:UILabel!
    @IBOutlet  var exclamatory_Img:UIImageView!
    @IBOutlet weak var user_Image:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        user_Image.layer.cornerRadius = 26
        user_Image.layer.borderWidth = 1
        user_Image.layer.borderColor = UIColor.lightGray.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
