//
//  GroupInfoGroupMemTableCell.swift
//
//
//  Created by CASPERON on 07/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class GroupInfoGroupMemTableCell: UITableViewCell {
     @IBOutlet weak var admin_lbl: UILabel!

//    @IBOutlet weak var imagewidth: NSLayoutConstraint!
//    @IBOutlet weak var Imageheight: NSLayoutConstraint!
    @IBOutlet weak var Status_lbl: UILabel!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        imagewidth.constant=30
//        Imageheight.constant=30

        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        Status_lbl.text = ""
        memberImage.image = nil
        nameLbl.text = ""
        admin_lbl.text = ""
    }
    
}
