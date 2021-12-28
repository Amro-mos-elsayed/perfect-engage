//
//  DetailtableViewCell.swift

//
//  Created by MV Anand Casp iOS on 06/04/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class DetailtableViewCell: UITableViewCell {
    @IBOutlet weak var audicallBtn: CustomButton!
    @IBOutlet weak var videocallBtn: CustomButton!
    @IBOutlet weak var msgBtn: CustomButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var groupName_TxtField: UILabel!
    var userId: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    func getContactIsActive() {
        let id = Themes.sharedInstance.CheckNullvalue(Passed_value: userId)
        SocketIOManager.sharedInstance.checkUserStatus(from: id)
        NotificationCenter.default.addObserver(self, selector: #selector(activatedUsers(_:)), name: NSNotification.Name.init("chechActive"), object: nil)
    }
    
    @objc func activatedUsers(_ notification: Notification) {
        
        
        guard let isDeleted = notification.userInfo?["isDeleted"] as? String else {
            return
        }
        if isDeleted == "1"{
            audicallBtn.isUserInteractionEnabled = false
            videocallBtn.isUserInteractionEnabled = false
            msgBtn.isUserInteractionEnabled = false
            audicallBtn.backgroundColor = .gray
            videocallBtn.backgroundColor = .gray
            msgBtn.backgroundColor = .gray
        }else {
            audicallBtn.isUserInteractionEnabled = true
            videocallBtn.isUserInteractionEnabled = true
            msgBtn.isUserInteractionEnabled = true
        }
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
