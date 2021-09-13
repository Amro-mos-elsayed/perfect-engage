//
//  ContactTableViewCell.swift
//
//  Created by raguraman on 28/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

enum contactTitle:String{
    case msg = "Message"
    case contact = "Save Contact"
    case invite = "Invite"
}

class ContactTableViewCell: CustomTableViewCell {
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImg: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusIcon: UIImageView?
    
    @IBOutlet weak var singleButtonView: UIView!
    
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var singleButton: UIButton!
    
    @IBOutlet weak var seperatorLabel: UILabel!
    @IBOutlet weak var doubleButtonView: UIView!
    @IBOutlet weak var seperatLabel: UILabel!
    
    @IBOutlet weak var bubleImg: UIImageView!
    @IBOutlet weak var saveContactBtn: UIButton!
    
    @IBOutlet weak var inviteContatBtn: UIButton!
    
    @IBOutlet weak var cellMaxWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lineLabel: UILabel!
    
    
    override var RowIndex: IndexPath{
        didSet{
            saveContactBtn.tag = RowIndex.row
            inviteContatBtn.tag = RowIndex.row
            singleButton.tag = RowIndex.row
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        lineLabel.backgroundColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1.0)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        lineLabel.backgroundColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1.0)
    }
    
    override var bubleImage: String{
        didSet{
            let imgName = messageFrame.message.isLastMessage ? bubleImage : bubleImage+"_0"
            bubleImg.image = UIImage(named:imgName)?.renderImg()
            bubleImg.tintColor = statusIcon != nil ? outgoingBubbleColour : incommingBubbleColour
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        singleButtonView.backgroundColor = chatView.backgroundColor
        doubleButtonView.backgroundColor = chatView.backgroundColor
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.contactBtnTapped(sender: sender)
    }
    
    @IBAction func saveContactTapped(_ sender: UIButton) {
        delegate?.saveTarget(sender: sender)
    }
    
    
}
