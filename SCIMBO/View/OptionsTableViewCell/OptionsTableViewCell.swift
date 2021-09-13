//
//  OptionsTableViewCell.swift
//
//
//  Created by CASPERON on 26/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var options_Name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 4
        backView.layer.shadowColor = UIColor.darkGray.cgColor
        backView.layer.shadowOffset = CGSize(width: 1, height: 3)
        backView.layer.shadowOpacity = 0.5
       // backView.layer.shadowColor =  UIColor(red: 1.0/255.0, green: 169.0/255.0, blue: 230/255.0, alpha: 1).cgColor

        backView.layer.shadowRadius = 4.0

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
