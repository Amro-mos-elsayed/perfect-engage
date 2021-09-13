//
//  GroupInfoTableViewCell.swift
//
//
//  Created by CASPERON on 07/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class GroupInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var rightArrow_ImgView: UIImageView!
    @IBOutlet weak var subDesc_Lbl: UILabel!
    @IBOutlet weak var propertyTitle_Lbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
