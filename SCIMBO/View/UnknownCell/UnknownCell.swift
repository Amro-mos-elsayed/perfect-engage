//
//  UnknownCell.swift
//
//
//  Created by Casperon iOS on 18/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

protocol unKnownPerson : class {
    func Add_To_Conacts()
}

class UnknownCell: UITableViewCell {
    weak var delegate: unKnownPerson!
    var user_id:String! = String()

    @IBOutlet weak var btn_block: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func block(_ sender: Any) {
        Themes.sharedInstance.showBlockalert(id: user_id)
    }
    @IBAction func report_spam(_ sender: Any) {
        Themes.sharedInstance.showBlockalert(id: user_id)
    }
    @IBAction func add_to_contacts(_ sender: Any) {
        delegate.Add_To_Conacts()
    }
    func updateUI()
    {
        btn_block.setTitle(Themes.sharedInstance.checkBlock(id: user_id) ? NSLocalizedString("Unblock", comment:"Unblock" )  : NSLocalizedString("Block", comment: "Block") , for: UIControl.State.normal)
    }
    
}
