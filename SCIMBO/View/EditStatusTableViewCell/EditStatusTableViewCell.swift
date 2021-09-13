//
//  EditStatusTableViewCell.swift
//
//
//  Created by CASPERON on 14/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class EditStatusTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var menuBtn: UIButton!

    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
