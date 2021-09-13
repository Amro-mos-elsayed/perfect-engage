//
//  ChatsTableViewCell.swift
//
//
//  Created by CASPERON on 20/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class GroupChatTableViewCell: MGSwipeTableCell {
    @IBOutlet weak var name_Lbl:UILabel!
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var message_Lbl:UILabel!
    @IBOutlet weak var sender_nameLbl:UILabel!
    @IBOutlet weak var user: UIButton!
    @IBOutlet weak var user_Images: UIImageView!
    
    @IBOutlet weak var is_locked: UIButton!
    @IBOutlet weak var chat_status: UIButton!
    @IBOutlet weak var time_Lbl:UILabel!
    @IBOutlet weak var messageCount_Lbl:UILabel!
    var typingTimer:Timer?
    var objRecordSingle:Chatpreloadrecord = Chatpreloadrecord()
    let objRecordGroup:GroupDetail = GroupDetail()
    var chat_type:String = String()
    var istartTyping:Bool = Bool()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageCount_Lbl.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9)
        messageCount_Lbl.layer.cornerRadius = messageCount_Lbl.frame.size.width/2
        messageCount_Lbl.clipsToBounds = true
        unreadView.layer.cornerRadius = unreadView.frame.size.width/2
        unreadView.clipsToBounds = true
        user_Images.layer.cornerRadius = user_Images.frame.size.width/2
        user_Images.clipsToBounds = true
        istartTyping = false
    }
    
    func startTyping(chat_type:String,objRecord:Any)
    {
       
            if(!istartTyping)
            {
            if(typingTimer != nil)
            {
                typingTimer = nil
                typingTimer?.invalidate()
            }
                if(chat_type == "single")
                {
                  message_Lbl.text = "typing"
                }
            else
            {

                
            }
          istartTyping = true
          typingTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.stopTyping), userInfo: nil, repeats: false)

            }

 
    }
    deinit {
	typingTimer = nil
        typingTimer?.invalidate()
     }
    @objc func stopTyping()
    {
        if(typingTimer != nil)
        {
            typingTimer = nil
            typingTimer?.invalidate()
        }
        istartTyping = false
        
        if(chat_type == "single")
        {
            objRecordSingle.isTyping = false
            message_Lbl.text = objRecordSingle.opponentlastmessage
            
        }
        else
        {
            objRecordGroup.isStartTyping = false
         }
      }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        name_Lbl.text = ""
        message_Lbl.text = ""
        user_Images.image = nil
        time_Lbl.text = ""
        messageCount_Lbl.text = ""
    }
    
    
}
