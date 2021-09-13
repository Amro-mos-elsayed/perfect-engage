//
//  NewChatFltrCntctGroupTableViewCell.swift
//
//
//  Created by CASPERON on 28/03/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class NewChatFltrCntctGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var img_View: UIImageView!

    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
