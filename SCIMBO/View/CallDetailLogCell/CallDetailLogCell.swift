//
//  CallDetailLogCell.swift
//
//
//  Created by MV Anand Casp iOS on 26/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class CallDetailLogCell: UITableViewCell {
    @IBOutlet weak var time_Lbl: UILabel!
    
    @IBOutlet weak var call_icon: UIImageView!
    @IBOutlet weak var call_status: UILabel!
    @IBOutlet weak var call_duration: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
