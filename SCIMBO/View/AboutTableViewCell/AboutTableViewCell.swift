//
//  AboutTableViewCell.swift
//
//
//  Created by CASPERON on 21/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class AboutTableViewCell: UITableViewCell {
    @IBOutlet weak var options_Lbl:UILabel!
    @IBOutlet weak var needHelp_Lbl:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
