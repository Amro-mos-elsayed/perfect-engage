//
//  SelectContactTableViewCell.swift
//
//
//  Created by CASPERON on 05/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class SelectContactTableViewCell: UITableViewCell {
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contact_ImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!

    @IBOutlet weak var roundTick: UIImageView!
    @IBOutlet weak var subDecLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
                // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
