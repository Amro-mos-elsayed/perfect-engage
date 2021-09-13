//
//  CallLogCell.swift
//
//
//  Created by MV Anand Casp iOS on 24/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class CallLogCell: UITableViewCell {
    @IBOutlet weak var time_Lbl: UILabel!
    
    @IBOutlet weak var calltype_imgView: UIImageView!
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var callinfo_Btn: UIButton!
    @IBOutlet weak var call_statusLbl: UILabel!
    @IBOutlet weak var user_name_Lbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      user_image.layer.cornerRadius = user_image.frame.size.width/2
        user_image.clipsToBounds = true

        // Configure the view for the selected state
    }
    
}
