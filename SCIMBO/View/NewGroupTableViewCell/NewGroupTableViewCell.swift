//
//  NewGroupTableViewCell.swift
//
//
//  Created by CASPERON on 30/01/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class NewGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var check_Btn: UIButton!
    @IBOutlet weak var contact_Image: UIImageView!
    @IBOutlet weak var name_Lbl_Cell: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
