//
//  FavouriteTableViewCell.swift
//
//
//  Created by CASPERON on 16/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {

    @IBOutlet weak var content_view: UIView!
    @IBOutlet weak var profile: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius=profileImage.frame.size.width/2
        profileImage.clipsToBounds=true
         // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
