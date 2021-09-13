//
//  CountryList.swift
//  User
//
//  Created by casperonIOS on 2/22/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class CountryList: UITableViewCell {

    @IBOutlet weak var imageCountry: UIImageView!
    @IBOutlet weak var nameCountry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
