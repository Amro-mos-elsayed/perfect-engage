//
//  GroupincommonVC.swift
//
//
//  Created by MV Anand Casp iOS on 10/11/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import SDWebImage

class GroupincommonVC: UIViewController {
    var opponentUserid:String = String()
    var GroupRecordArr:NSMutableArray = NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        if(GroupRecordArr.count > 0)
        {
            let nibName = UINib(nibName: "GroupCell", bundle:nil)
            self.tableView.register(nibName, forCellReuseIdentifier: "GroupCellID")
            self.tableView.delegate = self
            self.tableView.dataSource = self
            tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func Didclickback(_ sender: Any) {
        self.pop(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GroupincommonVC:UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupRecordArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GroupCell = tableView.dequeueReusableCell(withIdentifier: "GroupCellID", for: indexPath) as! GroupCell
        let chatprerecord:GroupDetail=GroupRecordArr[indexPath.row] as! GroupDetail
        cell.user_image.layer.cornerRadius = cell.user_image.frame.size.width/2
        cell.user_image.clipsToBounds = true
        cell.user_image.setProfilePic(chatprerecord.id, "group")
        cell.accessoryType = .disclosureIndicator
        cell.group_name.setNameTxt(chatprerecord.id, "group")
        let stringValue = chatprerecord.groupUsers.componentsJoined(by: ",")
        let attrString = NSMutableAttributedString(string: stringValue)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.minimumLineHeight = 6
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: stringValue.count))
        cell.group_detail.attributedText = attrString
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatprerecord:GroupDetail=GroupRecordArr[indexPath.row] as! GroupDetail
        let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group")
        if(chatLocked == true){
            self.enterToChat(id: chatprerecord.id, type: "group", indexpath: indexPath)
        }else{
            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
            ObjInitiateChatViewController.Chat_type="group"
            ObjInitiateChatViewController.opponent_id = chatprerecord.id
            self.pushView(ObjInitiateChatViewController, animated: true)
        }
        
        
    }
    
    func enterToChat(id:String,type:String,indexpath:IndexPath){
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = id
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
}

