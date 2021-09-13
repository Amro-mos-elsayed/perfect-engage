//
//  GroupCell.swift
//
//
//  Created by MV Anand Casp iOS on 10/11/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    @IBOutlet weak var group_name:UILabel!
    @IBOutlet weak var group_detail:UILabel!
    @IBOutlet weak var user_image:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
