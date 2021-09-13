//
//  MessageInfoCell.swift
//
//
//  Created by MV Anand Casp iOS on 16/08/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class MessageInfoCell: UITableViewCell {
    @IBOutlet weak var logo_image:UIImageView!
    @IBOutlet weak var nameLbl:UILabel!
    @IBOutlet weak var time_Lbl:UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        logo_image.layer.cornerRadius = logo_image.frame.size.width/2
        logo_image.clipsToBounds = true
        // Configure the view for the selected state
    }
    
}
