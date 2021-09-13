//
//  ContactsTableViewCell.swift
//
//
//  Created by CASPERON on 20/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    @IBOutlet weak var status_Lbl: UILabel!
    @IBOutlet weak var name_Lbl:UILabel!
    @IBOutlet weak var phone_Lbl:UILabel!
    @IBOutlet weak var user_ImageView:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.user_ImageView.layer.masksToBounds = true
            self.user_ImageView.layer.cornerRadius = self.user_ImageView.frame.width / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
