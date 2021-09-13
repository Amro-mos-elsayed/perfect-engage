//
//  ShareDetailTableViewCell.swift
//
//
//  Created by casperon_macmini on 10/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class ShareDetailTableViewCell: UITableViewCell {
   
    @IBOutlet weak var heightConstrnt_AnotherLbl: NSLayoutConstraint!
    @IBOutlet weak var topConstraintLbl: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraintLbl: NSLayoutConstraint!
    @IBOutlet weak var anotherDtl: CustomLbl!
    @IBOutlet weak var nameLbl: CustomLbl!
    @IBOutlet weak var chkBoxView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
