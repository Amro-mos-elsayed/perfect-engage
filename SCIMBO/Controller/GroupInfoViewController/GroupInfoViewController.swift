
//
//  GroupInfoViewController.swift
//
//
//  Created by CASPERON on 07/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView
import GSImageViewerController
import RSKImageCropper
import Toast_Swift
import Contacts
import ContactsUI

class GroupInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,RSKImageCropViewControllerDelegate,SocketIOManagerDelegate, CNContactViewControllerDelegate {
    
    @IBOutlet weak var base_view_height: NSLayoutConstraint!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var info_table_height: NSLayoutConstraint!
    @IBOutlet weak var action_table_height: NSLayoutConstraint!
    @IBOutlet weak var member_table_height: NSLayoutConstraint!
    @IBOutlet weak var groupCreateLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupMembers_TblView: UITableView!
    @IBOutlet weak var Action_TblView: UITableView!
    @IBOutlet weak var created_date_Lbl: UILabel!
    @IBOutlet weak var group_created_Lbl: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var activity_IndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var participant_lbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var groupProperties_tblView: UITableView!
    var msg_lbl : UILabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    var GroupDetailRec:GroupDetail=GroupDetail()
    var propertyNameArray:NSArray = NSArray()
    var selectDescription:NSArray = NSArray()
    var getContactRec = [NSObject]()
    var cutomColor = CustomColor()
    var common_id:String=String()
    var Group_DetailArr:NSMutableArray=NSMutableArray()
    var picker = UIImagePickerController()
    var fullImage:NSArray = NSArray()
    var group_ID:String =  String()
    var group_convId:String = String()
    var imageName:String = String()
    var isUpdated:Bool = Bool()
    var Starmessagecount:String = String()
    var isAdmin : Bool = Bool()
    var is_you_removed : Bool = Bool()
    var Action_Array : NSArray = NSArray()
    private var propertyImgArray = [UIImage]()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var image_view: UIImageView!
    @IBOutlet weak var image_btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        isAdmin = false
        activity_IndicatorView.isHidden = true
        activity_IndicatorView.hidesWhenStopped = true
        self.editBtn.isHidden = true
        propertyNameArray = ["Media,Links and Docs".localized(),"Tasks".localized(),"Mute".localized(), "Save to Camera Roll".localized()]
        propertyImgArray = [#imageLiteral(resourceName: "media"),#imageLiteral(resourceName: "star"),#imageLiteral(resourceName: "infomute"),#imageLiteral(resourceName: "gallery_ic")]
        GetStarmessageCount()
        getRecord()
        let nibName = UINib(nibName: "GroupInfoTableViewCell", bundle: nil)
        groupProperties_tblView.register(nibName, forCellReuseIdentifier: "GroupInfoTableViewCell")
        groupProperties_tblView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        let nibNameForMemTblView = UINib(nibName: "GroupInfoGroupMemTableCell", bundle: nil)
        groupMembers_TblView.register(nibNameForMemTblView, forCellReuseIdentifier: "GroupInfoGroupMemTableCell")
        groupMembers_TblView.estimatedRowHeight=80
        groupMembers_TblView.tableFooterView=UIView()
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.sharedInstance.Delegate = self
        self.ReloadView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, userInfo: nil)
        }
    }
    
    func updateGroupInfo()
    {
    }
    
    func GetStarmessageCount()
    {
        
        let predicate1:NSPredicate =  NSPredicate(format: "user_common_id == %@", common_id)
        let predicate2:NSPredicate =  NSPredicate(format: "isStar == 1")
        let compunPred = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
        let fetchstarRecordArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: nil, predicate: compunPred, Limit: 0) as! NSArray
        Starmessagecount = "\(fetchstarRecordArr.count)"
    }
    func ReloadView()
    {
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        let time = Themes.sharedInstance.muteOption(id: self.group_convId, type: "group")
        let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + self.group_convId
        
        let saveGallery = Themes.sharedInstance.saveToGallryOption(id: user_common_id)
        selectDescription = ["","\(Starmessagecount)",time,saveGallery]

        Group_DetailArr.removeAllObjects()
        let checkGroupinfo:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: common_id)
        if(checkGroupinfo)
        {
            let groupinfoArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", Predicatefromat: "==", FetchString: common_id, Limit: 1, SortDescriptor: nil) as NSArray
            for i in 0..<groupinfoArr.count
            {
                let ReponseDict=groupinfoArr[i] as! NSManagedObject
                GroupDetailRec.displayName=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "displayName") as! String)
                GroupDetailRec.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "id") as! String)
                GroupDetailRec.group_created_time=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "group_created_time") as! String)
                var from:String = String()
                let checkOtherMessages:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "group_id", FetchString: GroupDetailRec.id)
                if(checkOtherMessages)
                {
                    let MessageInfoArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "group_id", FetchString: GroupDetailRec.id, SortDescriptor: nil) as! NSArray
                    if(MessageInfoArr.count > 0)
                    {
                        for i in 0..<MessageInfoArr.count
                        {
                            let messageDict=MessageInfoArr[i] as! NSManagedObject
                            from = Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "from"))
                        }
                    }
                }
                let Check_FavContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                if(GroupDetailRec.group_created_time != "" && GroupDetailRec.group_created_time != nil)
                {
                    let time:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: GroupDetailRec.group_created_time))
                    let date:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamptodate(timestamp: GroupDetailRec.group_created_time))
                    created_date_Lbl.text = "Created on \(date) at \(time)"
                    
                }
                else
                {
                    created_date_Lbl.text = ""
                    
                }
                if(from == Themes.sharedInstance.Getuser_id())
                {
                    group_created_Lbl.text = "Group created by you"
                }
                else
                {
                    
                    if(Check_FavContact)
                    {
                        group_created_Lbl.text = "Group created by \(Themes.sharedInstance.setNameTxt(from, "single"))"
                        
                    }
                    else
                        
                    {
                        group_created_Lbl.text = ""
                        groupCreateLabelHeightConstraint.constant = 0
                    }
                }
                group_ID = GroupDetailRec.id
                GroupDetailRec.displayavatar=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "displayavatar") as! String)
                
                self.image_view.setProfilePic(group_ID, "group")
                
                GroupDetailRec.Group_userid=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "id") as! String)
                GroupDetailRec.TimeStamp=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp") as! String)
                GroupDetailRec.is_archived=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "is_archived") as! String)
                GroupDetailRec.is_marked=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "is_marked") as! String)
                GroupDetailRec.isAdmin=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "isAdmin") as! String)
                GroupDetailRec.msg=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "msg") as! String)
                let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                if(groupData != nil)
                {
                    GroupDetailRec.groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                }
                for j in 0..<GroupDetailRec.groupUsers.count
                {
                    let Dict:NSDictionary=GroupDetailRec.groupUsers[j] as! NSDictionary
                    let Grouppeoplerecord:Group_people_record=Group_people_record()
                    Grouppeoplerecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "id") as! String) as NSString
                    
                    Grouppeoplerecord.Name = Themes.sharedInstance.setNameTxt(Grouppeoplerecord.id as String, "single") as NSString
                    Grouppeoplerecord.avatar = Themes.sharedInstance.setProfilePic(Grouppeoplerecord.id as String, "single") as NSString
                    Grouppeoplerecord.Status  = Themes.sharedInstance.setStatusTxt(Grouppeoplerecord.id as String) as NSString

                    Grouppeoplerecord.PhNumber=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "PhNumber") as! String) as NSString
                    
                    Grouppeoplerecord.active=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "active") ) as NSString
                    
                    Grouppeoplerecord.isAdmin=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "isAdmin") as! String) as NSString
                    Grouppeoplerecord.isDeleted=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "isDeleted")  ) as NSString
                    Grouppeoplerecord.isExitsContact=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "isExitsContact")  ) as NSString
                    
                    Grouppeoplerecord.msisdn=Themes.sharedInstance.setPhoneTxt(Grouppeoplerecord.id as String) as NSString
                    Group_DetailArr.add(Grouppeoplerecord)
                }
                //                 participant_lbl.text = "  \(Group_DetailArr.count) of \(Constant.sharedinstance.GroupCount) Participants"
                participant_lbl.text = ""
            }
        }
        for index in Group_DetailArr
        {
            let Grouppeoplerecord : Group_people_record = index as! Group_people_record
            if(Grouppeoplerecord.id as String == Themes.sharedInstance.Getuser_id() && Grouppeoplerecord.isAdmin == "1")
            {
                isAdmin = true
            }
            
        }
        
        var isYou : Bool = false
        for i in 0..<Group_DetailArr.count{
            let peopleRec : Group_people_record = Group_DetailArr[i] as! Group_people_record
            if(peopleRec.id as String == Themes.sharedInstance.Getuser_id())
            {
                isYou = true
                break
            }
        }
        if isYou{
            is_you_removed = false
        }
        else {
            is_you_removed = true
        }
        
        if(is_you_removed){
            Action_Array = [NSLocalizedString("Delete group", comment: "com") ]
        }
        else{
            Action_Array = [NSLocalizedString("Exit group", comment: "com")]
        }
        
        groupProperties_tblView.reloadData()
        groupMembers_TblView.reloadData()
        Action_TblView.reloadData()
        self.SetFrame()
        
        Themes.sharedInstance.RemoveactivityView(View: self.view)
    }
    
    override func viewDidLayoutSubviews()
    {
        
        groupMembers_TblView.reloadData()
        groupMembers_TblView.layoutIfNeeded()
    }
    func getRecord(){
        getContactRec.removeAll()
        
        getContactRec = [NSObject]()
        
        for j  in  0..<contactRec.count{
            let currentSearchArray : NewGroupAdd = contactRec[j] as! NewGroupAdd
            if currentSearchArray.isSelect == true{
                self.getContactRec.append(contactRec[j] as! NewGroupAdd)
            }
        }
        groupMembers_TblView.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
        //        if tableView == Action_TblView{
        //            return Action_Array.count
        //        }
        //        else{
        //
        //        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == groupMembers_TblView{
            if(isAdmin && is_you_removed == false){
                return Group_DetailArr.count+1
            }
            else {
                return Group_DetailArr.count
            }
        }
        else if  tableView ==  groupProperties_tblView{
            return propertyNameArray.count+1
        }
        else{
            return Action_Array.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.view.updateConstraintsIfNeeded()
        let cell:GroupInfoTableViewCell = groupProperties_tblView.dequeueReusableCell(withIdentifier: "GroupInfoTableViewCell") as! GroupInfoTableViewCell
        cell.selectionStyle = .none
        let groupMemCell:GroupInfoGroupMemTableCell = groupMembers_TblView.dequeueReusableCell(withIdentifier: "GroupInfoGroupMemTableCell") as! GroupInfoGroupMemTableCell
        if tableView == groupMembers_TblView{
            member_table_height.constant = groupMembers_TblView.contentSize.height
            if indexPath.row == 0 && isAdmin && is_you_removed == false{
                groupMemCell.nameLbl.text = NSLocalizedString("Add Participant", comment:"Add Participant") 
                groupMemCell.nameLbl.textColor = CustomColor.sharedInstance.themeColor
                groupMemCell.memberImage.image = UIImage(named:"Plusrounded")
                groupMemCell.admin_lbl.isHidden=true
                groupMemCell.Status_lbl.isHidden=true
                
                return groupMemCell
            }
                
            else{
                groupMemCell.nameLbl.textColor = UIColor.black
                
                let Grouppeoplerecord : Group_people_record = Group_DetailArr[(isAdmin && !is_you_removed) ? indexPath.row-1 : indexPath.row] as! Group_people_record
                groupMemCell.Status_lbl.isHidden=false
                if(Grouppeoplerecord.isAdmin == "1")
                {
                    groupMemCell.admin_lbl.text="admin".localized()
                    groupMemCell.admin_lbl.isHidden=false
                }
                else
                {
                    groupMemCell.admin_lbl.isHidden=true
                    
                }
                groupMemCell.nameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id), "single")
                groupMemCell.Status_lbl.setStatusTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id))
                groupMemCell.memberImage.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id), "single")
                groupMemCell.memberImage.layer.cornerRadius=groupMemCell.memberImage.frame.size.width/2
                groupMemCell.memberImage.clipsToBounds=true
                groupMemCell.selectionStyle = .none
                return groupMemCell
                
            }
            
        }
        else if tableView ==  groupProperties_tblView{
            
            
            if indexPath.row == 0{
                cell.propertyTitle_Lbl.setNameTxt(GroupDetailRec.id, "group")
                cell.subDesc_Lbl.isHidden = true
                return cell
            }
            
            let cell:SettingsTableViewCell = groupProperties_tblView.dequeueReusableCell(withIdentifier:"SettingsTableViewCell" ) as! SettingsTableViewCell
            cell.rightArrow_ImgView.isHidden = false
            cell.subDesc_Lbl.isHidden = false
            cell.setting_Lbl.text = propertyNameArray[indexPath.row-1] as? String
            cell.subDesc_Lbl.text = selectDescription[indexPath.row-1] as? String
            cell.setting_Img.image = propertyImgArray[indexPath.row-1]
            cell.setting_Img.layer.cornerRadius = 5.0
            cell.separator.isHidden = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            if(indexPath.row == propertyNameArray.count)
            {
                cell.separator.isHidden = true
            }
            cell.selectionStyle = .none
            return cell
            
        }
        else
        {
            cell.propertyTitle_Lbl.text = Action_Array[indexPath.row] as? String
            cell.subDesc_Lbl.isHidden = true
            cell.rightArrow_ImgView.isHidden = true
            cell.propertyTitle_Lbl.textColor = UIColor.red
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == groupProperties_tblView{
            if indexPath.row == 0{
                if is_you_removed
                {
                    let alertview = JSSAlertView().show(
                        self,
                        title: Themes.sharedInstance.GetAppname(),
                        text: "Unable to change the subject because you aren't a participant",
                        buttonText: "Ok",
                        cancelButtonText: nil
                    )
                    alertview.addAction {
                        
                    }
                }
                else
                {
                    let changeNameVC:ChangeNameViewController=self.storyboard?.instantiateViewController(withIdentifier: "ChangeNameViewController") as! ChangeNameViewController
                    changeNameVC.groupID = group_ID
                    changeNameVC.name =  GroupDetailRec.displayName as String
                    self.pushView(changeNameVC, animated: true)
                    
                }
                return
            }
            
            if indexPath.row == 1
            {
                let  groupVC = storyboard?.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
                groupVC.user_common_id = common_id
                self.pushView(groupVC, animated: true)
            }
            
            if(indexPath.row == 2)
            {
                let  StarredDetailVC = storyboard?.instantiateViewController(withIdentifier: "StarredViewControllerID") as! StarredViewController
                StarredDetailVC.chat_type = "group"
                StarredDetailVC.user_common_id = common_id
                StarredDetailVC.opponent_id = group_convId
                StarredDetailVC.isallStarredmessages = false
                self.pushView(StarredDetailVC, animated: true)
                
            }

            if indexPath.row == 3{
                if(Themes.sharedInstance.CheckNullvalue(Passed_value: selectDescription[indexPath.row - 1]) != "No")
                {
                    let optionMenu = UIAlertController(title: nil, message:  "Choose option", preferredStyle: .actionSheet)
                    
                    // 2
                    let unmuteAction = UIAlertAction(title:  "Unmute", style: .default, handler: {
                        (alert: UIAlertAction!) -> Void in
                        Themes.sharedInstance.Mute_unMutechats(id: self.group_convId, type: "group")
                    })
                    let cancelAction = UIAlertAction(title:  NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: nil)
                    optionMenu.addAction(unmuteAction)
                    optionMenu.addAction(cancelAction)
                    self.presentView(optionMenu, animated: true, completion: nil)
                }
                else
                {
                    Themes.sharedInstance.Mute_unMutechats(id: self.group_convId, type: "group")
                }
            }
            if indexPath.row == 4{
                //let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + self.group_convId
                //Themes.sharedInstance.savetoCameraRollUpdate(user_common_id)
            }

        }
        else if tableView == groupMembers_TblView{
            if  indexPath.row == 0 && isAdmin{
                let  groupVC = storyboard?.instantiateViewController(withIdentifier: "NewGroupViewController") as! NewGroupViewController
                groupVC.fromAddParticipant = true
                groupVC.GroupDetailRec = self.GroupDetailRec
                self.pushView(groupVC, animated: true)
            }
            else
            {
                let Grouppeoplerecord : Group_people_record = Group_DetailArr[(isAdmin && !is_you_removed) ? indexPath.row-1 : indexPath.row] as! Group_people_record
                
                if(Grouppeoplerecord.id as String != Themes.sharedInstance.Getuser_id())
                {
                    let alert : UIAlertController = UIAlertController(title: "", message: NSLocalizedString( "Choose an Option", comment: "comment"), preferredStyle: .actionSheet)
                    
                    let infoAction = UIAlertAction(title: "Info".localized(), style: .default, handler: { (alert: UIAlertAction!) in
                        let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
                        singleInfoVC.user_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id)
                        singleInfoVC.fromGroupInfo = true
                        self.pushView(singleInfoVC, animated: true)
                    })
                    
                    let VoiceCallAction = UIAlertAction(title: NSLocalizedString("Voice Call", comment: "comment") , style: .default, handler: { (alert: UIAlertAction!) in
                        
                            if(SocketIOManager.sharedInstance.socket.status == .connected)
                            {
                                
                                var timestamp:String =  String(Date().ticks)
                                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                
                                if(servertimeStr == "")
                                {
                                    servertimeStr = "0"
                                }
                                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                
                                let docID = "\(Themes.sharedInstance.Getuser_id())-\(Grouppeoplerecord.id)-\(timestamp)"
                                let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id),"type":0,"id":(timestamp as NSString).longLongValue,"toDocId":docID, "roomid" : timestamp]
                                SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                                AppDelegate.sharedInstance.openCallPage(type: "0", roomid: timestamp, id: Grouppeoplerecord.id as String)
                            }
                            else
                            {
                                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
                                
                            }
                    })
                    
                    let VideoCallAction = UIAlertAction(title: NSLocalizedString("Video Call", comment:"com" ) , style: .default, handler: { (alert: UIAlertAction!) in
                        if(SocketIOManager.sharedInstance.socket.status == .connected)
                            {
                                
                                var timestamp:String =  String(Date().ticks)
                                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                
                                if(servertimeStr == "")
                                {
                                    servertimeStr = "0"
                                }
                                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                let docID = "\(Themes.sharedInstance.Getuser_id())-\(Grouppeoplerecord.id)-\(timestamp)"
                                let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id),"type":1,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
                                SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                                AppDelegate.sharedInstance.openCallPage(type: "1", roomid: timestamp, id: Grouppeoplerecord.id as String)
                            } else {
                                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
                            }
                    })
                    
                    let removeAction : UIAlertAction = UIAlertAction(title: NSLocalizedString("Remove from Group", comment:"tesr" ) , style: UIAlertAction.Style.destructive, handler: { (alert: UIAlertAction!) -> Void in
                        
                        let from : String = Themes.sharedInstance.Getuser_id()
                        let to : String = Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id)
                        var timestamp:String =  String(Date().ticks)
                        var servertimeStr:String = Themes.sharedInstance.getServerTime()
                        
                        if(servertimeStr == "")
                        {
                            servertimeStr = "0"
                        }
                        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                        let toDocId : String = "\(from)-\(to)-g-\(timestamp)"
                        let param = ["from" : Themes.sharedInstance.Getuser_id(),"groupType" : "4","groupId" : Themes.sharedInstance.CheckNullvalue(Passed_value:self.GroupDetailRec.id),"removeId" :to,"id" : timestamp, "toDocId" : toDocId] as [String : Any];
                        Themes.sharedInstance.activityView(View: self.view)
                        SocketIOManager.sharedInstance.Groupevent(param: param)
                        
                        
                    })
                    let messageAction : UIAlertAction = UIAlertAction(title:NSLocalizedString("Send Message", comment: "comm") , style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) -> Void in
                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.Chat_type="single"

                        if(Themes.sharedInstance.isChatLocked(id: Grouppeoplerecord.id as String, type: "single")){
                            self.enterToChat(id: Grouppeoplerecord.id as String, type: "single", indexpath: indexPath)
                        }else{
                            ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id)
                            ObjInitiateChatViewController.fromForward = true
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                        
                    })
                    
                    let makeAdminAction : UIAlertAction = UIAlertAction(title: NSLocalizedString("Make Group Admin", comment: "com") , style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) -> Void in
                        let from : String = Themes.sharedInstance.Getuser_id()
                        let to : String = Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id)
                        var timestamp:String =  String(Date().ticks)
                        var servertimeStr:String = Themes.sharedInstance.getServerTime()
                        
                        if(servertimeStr == "")
                        {
                            servertimeStr = "0"
                        }
                        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                        let toDocId : String = "\(from)-\(to)-g-\(timestamp)"
                        let param = ["from" : Themes.sharedInstance.Getuser_id(),"groupType" : "7","groupId" : Themes.sharedInstance.CheckNullvalue(Passed_value:self.GroupDetailRec.id),"adminuser" :to,"id" : timestamp, "toDocId" : toDocId] as [String : Any];
                        Themes.sharedInstance.activityView(View: self.view)
                        SocketIOManager.sharedInstance.Groupevent(param: param)
                    })
                    
                    let AddtoContactsAction : UIAlertAction = UIAlertAction(title: NSLocalizedString("Add to Contacts", comment: "com") , style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) -> Void in
                        
                        var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
                        phone_num.append(CNLabeledValue(label:"Home" , value:CNPhoneNumber(stringValue:Grouppeoplerecord.Name as String)))
                        
                        let contact = CNMutableContact()
                        
                        if(phone_num.count > 0){
                            
                            contact.phoneNumbers = phone_num
                        }
                        
                        let controller = CNContactViewController(forNewContact: contact)
                        controller.delegate = self
                        
                        let navigationController = UINavigationController(rootViewController: controller)
                        self.presentView(navigationController, animated: true)
                    })
                    let cancelAction : UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "com") , style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) -> Void in
                    })
                    if(isAdmin == false || is_you_removed == true)
                    {
                        alert.addAction(infoAction)
                        alert.addAction(VoiceCallAction)
                        alert.addAction(VideoCallAction)
                        alert.addAction(messageAction)
                        
                        let CheckFav:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id))
                        if(!CheckFav)
                        {
                            alert.addAction(AddtoContactsAction)
                        }
                        alert.addAction(cancelAction)
                        self.presentView(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        alert.addAction(infoAction)
                        alert.addAction(VoiceCallAction)
                        alert.addAction(VideoCallAction)
                        alert.addAction(messageAction)
                        let CheckFav:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id))
                        if(!CheckFav)
                        {
                            alert.addAction(AddtoContactsAction)
                        }
                        if(Grouppeoplerecord.isAdmin == "0")
                        {
                            alert.addAction(makeAdminAction)
                        }
                        alert.addAction(removeAction)
                        alert.addAction(cancelAction)
                        self.presentView(alert, animated: true, completion: nil)
                    }
                }
                
            }
        }
        else if tableView == Action_TblView
        {
            let cell = self.Action_TblView.cellForRow(at: indexPath) as? GroupInfoTableViewCell
            if(cell?.propertyTitle_Lbl.text == NSLocalizedString( "Clear chat", comment: "Clear chat"))
            {
                let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose Option", comment: "com") , preferredStyle: .actionSheet)
                
                // 2
                let deleteStarredAction = UIAlertAction(title:NSLocalizedString("Delete all except flagged", comment: "com") , style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    print("File Deleted")
                    Themes.sharedInstance.executeClearChat("1", self.GroupDetailRec.id, false)
                })
                let deleteMessageAction = UIAlertAction(title: NSLocalizedString("Delete all messages", comment: "com") , style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    print("File Saved")
                    Themes.sharedInstance.executeClearChat("0", self.GroupDetailRec.id, false)
                })
                //
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "com") , style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    print("Cancelled")
                })
                
                
                // 4
                optionMenu.addAction(deleteStarredAction)
                optionMenu.addAction(deleteMessageAction)
                optionMenu.addAction(cancelAction)
                
                // 5
                self.presentView(optionMenu, animated: true, completion: nil)
            }else if(cell?.propertyTitle_Lbl.text ==  NSLocalizedString("Export Chat", comment: "Clear chat") ){
                self.exportChat(id: common_id)
            }
            else if(cell?.propertyTitle_Lbl.text ==  NSLocalizedString("Exit group", comment: "Exit group") )
            {
                let optionMenu = UIAlertController(title: nil, message: "Choose option".localized(), preferredStyle: .actionSheet)
                
                // 2
                let  exitGroupAction = UIAlertAction(title: NSLocalizedString( "Exit group", comment: "Exit group"), style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let from : String = Themes.sharedInstance.Getuser_id()
                    let to : String = Themes.sharedInstance.CheckNullvalue(Passed_value: self.GroupDetailRec.id)
                    var timestamp:String =  String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                    let toDocId : String = "\(from)-\(to)-g-\(timestamp)"
                    let param = ["from" : Themes.sharedInstance.Getuser_id(),"groupType" : "8","groupId" : Themes.sharedInstance.CheckNullvalue(Passed_value:self.GroupDetailRec.id), "id" : timestamp, "toDocId" : toDocId] as [String : Any];
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.Groupevent(param: param)
                    let param_removeuser = ["_id":Themes.sharedInstance.CheckNullvalue(Passed_value:self.GroupDetailRec.id)]
                    SocketIOManager.sharedInstance.Removeuser(param: param_removeuser)

                })
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel") , style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    print("Cancelled")
                })
                
                
                // 4
                optionMenu.addAction(exitGroupAction)
                optionMenu.addAction(cancelAction)
                
                // 5
                self.presentView(optionMenu, animated: true, completion: nil)
            }
            else if(cell?.propertyTitle_Lbl.text == NSLocalizedString("Delete group", comment: "com"))
            {
                Themes.sharedInstance.executeClearChat("0", self.GroupDetailRec.id, true)
                DispatchQueue.main.async {
                    self.popToRoot(animated: true)
                }
            }
        }
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        
        viewController.dismissView(animated: true, completion: nil)
        
    }
    
    func chatLocked(id:String) -> Bool{
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "opponent_id", FetchString: id)
        var isLocked:Bool = false
        if(checkBool){
            let chatArray:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "opponent_id", FetchString: id, SortDescriptor: nil) as! NSArray
            if(chatArray.count > 0){
                for i in 0..<chatArray.count{
                    let check_Chat_array:NSManagedObject = chatArray[i] as! NSManagedObject
                    let isLock:String = Themes.sharedInstance.CheckNullvalue(Passed_value: check_Chat_array.value(forKey: "is_locked"))
                    if(isLock == "1"){
                        isLocked = true
                    }
                }
            }
        }else{
            isLocked = false
        }
        return isLocked
    }
    
    func enterToChat(id:String,type:String,indexpath:IndexPath){
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let Grouppeoplerecord : Group_people_record = self.Group_DetailArr[(self.isAdmin && !self.is_you_removed) ? indexpath.row-1 : indexpath.row] as! Group_people_record
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Grouppeoplerecord.id)
                ObjInitiateChatViewController.fromForward = true
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    func exportChat(id:String){
        let sheet_action: UIAlertController = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        let MediaAction: UIAlertAction = UIAlertAction(title: "Attach Media", style: .default) { action -> Void in
            self.attach_media_group(id: id)
        }
        let noMediaAction: UIAlertAction = UIAlertAction(title: "Without Media", style: .default) { action -> Void in
            self.attach_without_media_group(id: id)
        }
        let CancelAction: UIAlertAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { action -> Void in
            
        }
        sheet_action.addAction(MediaAction)
        sheet_action.addAction(noMediaAction)
        sheet_action.addAction(CancelAction)
        self.presentView(sheet_action, animated: true, completion: nil)
    }
    func attach_media_group(id:String){
        let chatprerecord:GroupDetail = GroupDetail()
        let picture_path:NSMutableArray = NSMutableArray()
        let contact_path:NSMutableArray = NSMutableArray()
        var save_msg:String = String()
        let User_chat_id=id
        var to_name:String = String()
        var place:String = ""
        var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: User_chat_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
        if(ChatArr.count > 0)
        {
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
            ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
        }
        for i in 0 ..< ChatArr.count {
            let ResponseDict = ChatArr[i] as! NSManagedObject
            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
            let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
            let message_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"))
            let thumbnail:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail"))
            let doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
            var temp_msg:String = String()
            var attachment_name:String = ""
            let checkOtherMessages:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id)
            if(checkOtherMessages){
                let MessageInfoArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id, SortDescriptor: nil) as! NSArray
                
                if(MessageInfoArr.count > 0)
                {
                    for i in 0..<MessageInfoArr.count
                    {
                        let messageDict=MessageInfoArr[i] as! NSManagedObject
                        let GrounInfo=Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "group_type"))
                        let CreatedUserID = Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "from"))
                        message = Themes.sharedInstance.returnOtherMessages(CreatedUserID, Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "person_id")), GrounInfo)
                    }
                }
            }
            let GroupDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: User_chat_id, SortDescriptor: "timestamp") as! NSArray
            if(GroupDetailArr.count > 0)
            {
                for j in 0..<GroupDetailArr.count
                {
                    let ReponseDict:NSManagedObject = GroupDetailArr[j] as! NSManagedObject
                    let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                    
                    if(groupData != nil)
                    {
                        chatprerecord.groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                    }
                }
            }
            
            let groupNameArr:NSMutableArray=NSMutableArray()
            let groupIdArr:NSMutableArray = NSMutableArray()
            if(chatprerecord.groupUsers.count > 0)
            {
                for j in 0..<chatprerecord.groupUsers.count
                {
                    let Dict:NSDictionary=chatprerecord.groupUsers[j] as! NSDictionary
                    let Grouppeoplerecord:Group_people_record=Group_people_record()
                    Grouppeoplerecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "id") as! String) as NSString
                    Grouppeoplerecord.Name = Themes.sharedInstance.setNameTxt(Grouppeoplerecord.id as String, "single") as NSString
                    groupNameArr.add("\(Grouppeoplerecord.Name)")
                    groupIdArr.add("\(Grouppeoplerecord.id)")
                    
                }
            }
            let index = groupIdArr.index(of: from)
            to_name = groupNameArr[index] as! String
            let path_array:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: "\(Constant.sharedinstance.Upload_Details)", attribute: "upload_data_id", FetchString: thumbnail, SortDescriptor: nil) as! NSArray
            if(path_array.count > 0){
                for i in 0..<path_array.count{
                    let ResponseDict = path_array[i] as! NSManagedObject
                    let upload_path = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "upload_Path"))
                    if(upload_path != "") {
                        let splittedStringsArray = upload_path.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                        let first_split = splittedStringsArray[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                        let second_split = first_split[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                        attachment_name = second_split[1]
                        picture_path.add(upload_path)
                    }
                }
            }
            if(type == "14"){
                let ChekLocation:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                if(ChekLocation)
                {
                    let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! NSArray
                    for i in 0..<LocationArr.count
                    {
                        let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                        let title_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                        let Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "stitle"))
                        place = "\(title_place),\(Stitle_place)"
                    }
                }
            }
            if(type == "5"){
                let contact_details:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                if(contact_details.count > 0){
                    for i in 0..<contact_details.count{
                        let ResponseDict = contact_details[i] as! NSManagedObject
                        let contact_details:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_details"))
                        let contact_name:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_name"))
                        var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
                        
                        var email:[CNLabeledValue<NSString>] = []
                        var address:[CNLabeledValue<CNPostalAddress>] = []
                        
                        let contact = CNMutableContact()
                        contact.givenName = contact_name
                        attachment_name = contact_name
                        let data = contact_details.data(using:.utf8)
                        
                        do {
                            
                            var jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                            let contact_address = CNMutablePostalAddress()
                            // Parse JSON data
                            if(jsonResult == nil)
                            {
                                jsonResult = []
                            }
                            for jsonL in jsonResult! {
                                
                                let value_p:NSDictionary = jsonL as! NSDictionary
                                let type = value_p.value(forKey:"type") as! String
                                let value_ph = value_p.value(forKey:"value") as! String
                                
                                let label = value_p.value(forKey:"label") as! String
                                if(type == "phone_number"){
                                    let values = CNLabeledValue(label:label , value:CNPhoneNumber(stringValue:value_ph))
                                    phone_num.append(values)
                                }else if(type == "email"){
                                    let values = CNLabeledValue(label:label , value:value_ph as NSString)
                                    email.append(values)
                                }else if(type == "street"){
                                    contact_address.street = value_ph
                                }else if(type == "city"){
                                    contact_address.city = value_ph
                                }else if(type == "state"){
                                    contact_address.state = value_ph
                                }else if(type == "postalCode"){
                                    contact_address.postalCode = value_ph
                                }else if(type == "country"){
                                    contact_address.country = value_ph
                                }
                            }
                            
                            let values = CNLabeledValue<CNPostalAddress>(label:"home" , value:contact_address)
                            address.append(values)
                            
                            
                            
                        } catch {
                            
                        }
                        
                        if(phone_num.count > 0){
                            
                            contact.phoneNumbers = phone_num
                            contact.emailAddresses = email
                            contact.postalAddresses = address
                            
                        }
                        contact_path.add(contact)
                    }
                }
            }
            
            if(type == "1"){
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
            }else if(type == "2"){
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
            }else if(type == "6" || type == "20"){
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
            }else if(type == "3"){
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
            }else if(type == "5"){
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name).vcf<attached> \n"
            }
            else if(type == "14"){
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(place) \n"
            }else{
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \n"
            }
            
            save_msg = save_msg + temp_msg
        }
        
        Filemanager.sharedinstance.zipMediaFiles(file: save_msg, pics: picture_path, contacts: contact_path)
        Themes.sharedInstance.activityView(View: self.view)
        let dir = CommondocumentDirectory()
        let fileURL = dir.appendingPathComponent("chats")
        SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if(entryNumber == total){
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
            })
        })
        self.share()
    }
    func attach_without_media_group(id:String){
        var save_msg:String = String()
        let User_chat_id=id
        var to_name:String = String()
        let chatprerecord:GroupDetail = GroupDetail()
        var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: User_chat_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
        if(ChatArr.count > 0)
        {
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
            ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
        }
        for i in 0 ..< ChatArr.count {
            let ResponseDict = ChatArr[i] as! NSManagedObject
            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
            let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
            //let message_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
            let message_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"))
            let checkOtherMessages:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id)
            if(checkOtherMessages){
                let MessageInfoArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id, SortDescriptor: nil) as! NSArray
                
                if(MessageInfoArr.count > 0)
                {
                    for i in 0..<MessageInfoArr.count
                    {
                        let messageDict=MessageInfoArr[i] as! NSManagedObject
                        let GrounInfo=Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "group_type"))
                        let CreatedUserID = Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "from"))
                        
                        message = Themes.sharedInstance.returnOtherMessages(CreatedUserID, Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "person_id")), GrounInfo)
                    }
                }
                
            }
            var temp_msg:String = String()
            let GroupDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: User_chat_id, SortDescriptor: "timestamp") as! NSArray
            if(GroupDetailArr.count > 0)
            {
                for j in 0..<GroupDetailArr.count
                {
                    let ReponseDict:NSManagedObject = GroupDetailArr[j] as! NSManagedObject
                    let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                    
                    if(groupData != nil)
                    {
                        chatprerecord.groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                    }
                }
            }
            
            let groupNameArr:NSMutableArray=NSMutableArray()
            let groupIdArr:NSMutableArray = NSMutableArray()
            if(chatprerecord.groupUsers.count > 0)
            {
                for j in 0..<chatprerecord.groupUsers.count
                {
                    let Dict:NSDictionary=chatprerecord.groupUsers[j] as! NSDictionary
                    let Grouppeoplerecord:Group_people_record=Group_people_record()
                    Grouppeoplerecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "id") as! String) as NSString
                    Grouppeoplerecord.Name = Themes.sharedInstance.setNameTxt(Grouppeoplerecord.id as String, "single") as NSString
                    groupNameArr.add("\(Grouppeoplerecord.Name)")
                    groupIdArr.add("\(Grouppeoplerecord.id)")
                    
                }
            }
            let index = groupIdArr.index(of: from)
            to_name = groupNameArr[index] as! String
            if(type == "0"){
                
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \n"
                
                save_msg =  save_msg + temp_msg
            }
            
        }
        Filemanager.sharedinstance.convertTextFile(file: save_msg)
        Themes.sharedInstance.activityView(View: self.view)
        let dir = CommondocumentDirectory()
        let fileURL = dir.appendingPathComponent("chats")
        SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if(entryNumber == total){
                    Themes.sharedInstance.RemoveactivityView(View: self.view)
                }
            })
        })
        self.share()
    }
    
    func share(){
        let dir = CommondocumentDirectory()
        let objectsToShare = [dir.appendingPathComponent("chats.zip")]
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
        
        activityController.excludedActivityTypes = excludedActivities
        self.presentView(activityController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == groupProperties_tblView{
            if indexPath.row == 5{
                return 85
            }
        }
        if tableView == groupMembers_TblView{
            if indexPath.row == 0 && isAdmin && !is_you_removed{
                return 50
            }
            else
            {
                return 74
            }
            //            else if indexPath.row == 1{
            //
            //                return 50
            //
            //            }
        }
        else {
            return 50
        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(tableView == groupMembers_TblView)
            
        {
            return  (Group_DetailArr.count == 0) ? "\(Group_DetailArr.count) \("PARTICIPANT".localized())" : "\(Group_DetailArr.count) \("PARTICIPANTS".localized())"
        }
        return nil
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15)!
        header.textLabel?.textColor = UIColor.black
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if(tableView == groupMembers_TblView)
            
        {
            return 30
        }
        return CGFloat.leastNormalMagnitude
        //        if(tableView == Action_TblView) {
        //
        //        }
        //        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return CGFloat.leastNormalMagnitude
    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //
    //        if tableView == groupMembers_TblView{
    //
    //            self.scrollViewHeight.constant = baseView.frame.height + groupMembers_TblView.frame.height
    //
    //            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height:1000)
    //            self.view.updateConstraintsIfNeeded()
    //
    //        }
    //        // check text and do something
    //    }
    
    
    
    
    @IBAction func editBtn_Action(_ sender: UIButton) {
        
        let alert:UIAlertController=UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Photo", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            
            
            SocketIOManager.sharedInstance.Delegate = self
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let toDocID = "\(Themes.sharedInstance.Getuser_id())-\(self.group_ID)-g-\(timestamp)"
            SocketIOManager.sharedInstance.changeGroupImage(toDocID: toDocID, from: Themes.sharedInstance.Getuser_id(), groupId: self.group_ID, image:"")
            let Dict:[String:Any]=["displayavatar":""]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_details, FetchString: self.group_ID, attribute: "id", UpdationElements: Dict as NSDictionary?)
            self.image_view.setProfilePic(self.group_ID, "group")
            
            self.editBtn.isHidden = false
            
            self.dissmissViewController()
        }
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Choose Photo", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        picker.delegate = self
        alert.addAction(deleteAction)
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(alert, animated: true, completion: nil)
        }
        else
        {
        }
    }
    
    func dissmissViewController(){
        
        
        
        if let activeController = self.navigationController?.visibleViewController{
            
            if activeController.isKind(of: GSImageViewerController.self){
                UIView.animate(withDuration: 5, animations: {
                    
                    self.editBtn.isHidden = true
                    
                    // self.headerTitle.text = "Edit Profile"
                    
                })
                self.dismissView(animated: true, completion: nil)
            }
        }
        // self.setUserDetails()
    }
    @IBAction func groupImg_Action(_ sender: UIButton) {
        
        
        if is_you_removed
        {
            let alertview = JSSAlertView().show(
                self,
                title: Themes.sharedInstance.GetAppname(),
                text: "Unable to update the group icon because you aren't a participant",
                buttonText: "Ok",
                cancelButtonText: nil
            )
            alertview.addAction {
                
            }
        }
        else
        {
            if  (image_view.image?.isEqual(UIImage(named: "groupavatar")))!
            {
                let alert:UIAlertController=UIAlertController(title: "Choose Image".localized(), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                
                let cameraAction = UIAlertAction(title: "Camera".localized(), style: UIAlertAction.Style.default)
                {
                    
                    UIAlertAction in
                    self.openCamera()
                }
                
                let gallaryAction = UIAlertAction(title: "Gallery".localized(), style: UIAlertAction.Style.default)
                {
                    UIAlertAction in
                    self.openGallary()
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertAction.Style.cancel)
                {
                    UIAlertAction in
                    
                    
                }
                // Add the actions
                picker.delegate = self
                alert.addAction(cameraAction)
                alert.addAction(gallaryAction)
                alert.addAction(cancelAction)
                // Present the controller
                if UIDevice.current.userInterfaceIdiom == .phone
                {
                    self.presentView(alert, animated: true, completion: nil)
                }
                else
                {
                }
                
            }
                
            else{
                
                let imageInfo   = GSImageInfo(image:image_view.image! , imageMode: .aspectFit)
                
                let transitionInfo = GSTransitionInfo(fromView: image_view)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                self.editBtn.isHidden = false
                self.presentView(imageViewer, animated: true)
                
            }
        }
        
    }
    
    func openCamera()
    {     if let activeController = self.navigationController?.visibleViewController{
        if activeController.isKind(of: GSImageViewerController.self){
            
            self.dismissView(animated: true, completion: {
                if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
                {
                    self.picker.sourceType = UIImagePickerController.SourceType.camera
                    
                    if let activeController = self.navigationController?.visibleViewController{
                        
                        if activeController.isKind(of: GSImageViewerController.self){
                            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(self.picker, animated: true)
                            
                            
                        }
                        else{
                            self.presentView(self.picker, animated: true)
                        }
                    }
                }
                else
                {
                    self.openGallary()
                }
            })
        }
        else
        {
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                self.picker.sourceType = UIImagePickerController.SourceType.camera
                
                if let activeController = self.navigationController?.visibleViewController{
                    
                    if activeController.isKind(of: GSImageViewerController.self){
                        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(self.picker, animated: true)
                        
                        
                    }
                    else{
                        self.presentView(self.picker, animated: true)
                    }
                }
            }
            else
            {
                self.openGallary()
            }
        }
        }
        
    }
    
    func openGallary()
    {
        
        if let activeController = self.navigationController?.visibleViewController{
            if activeController.isKind(of: GSImageViewerController.self){
                
                self.dismissView(animated: true, completion: {
                    self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    if UIDevice.current.userInterfaceIdiom == .phone
                    {
                        
                        if let activeController = self.navigationController?.visibleViewController{
                            
                            if activeController.isKind(of: GSImageViewerController.self){
                                
                                UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(self.picker, animated: true)
                                
                                
                            }
                            else{
                                self.presentView(self.picker, animated: true)
                            }
                        }
                        
                    }
                    else
                    {
                    }
                })
            }
            else
                
            {
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                if UIDevice.current.userInterfaceIdiom == .phone
                {
                    
                    if let activeController = self.navigationController?.visibleViewController{
                        
                        if activeController.isKind(of: GSImageViewerController.self){
                            
                            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(picker, animated: true)
                            
                            
                        }
                        else{
                            self.presentView(picker, animated: true)
                        }
                    }
                    
                }
                else
                {
                }
            }
        }
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        if let activeController = self.navigationController?.visibleViewController{
            
            if activeController.isKind(of: GSImageViewerController.self){
                self.dismissView(animated: true, completion: nil)
            }
        }
        DispatchQueue.main.async
            {
                let image : UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
                let compressedimg = image.jpegData(compressionQuality: 0.3)
//                UIImageJPEGRepresentation(image, 0.3)
                
                let imageCropVC = RSKImageCropViewController(image: UIImage(data: compressedimg!)!)
                imageCropVC.delegate = self
                self.pushView(imageCropVC, animated: true)
        }
        
        picker.dismissView(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismissView(animated: true, completion: nil)
    }
    
    func ReloadMessageIfexist()
    {
        let user_common_id = common_id
        
        let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", FetchString: user_common_id)
        if(CheckinitiatedDetails)
        {
            
        }
        else
        {
            
        }
        
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        //   self.imageView_Detail?.image = croppedImage
        self.pop(animated: true)
    }
    
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.pop(animated: true)
        splitImage(image: croppedImage)
        self.editBtn.isHidden = true
        
        
    }
    
    
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to YES.
        // SVProgressHUD.show()
        
        isUpdated=false
        editBtn.isHidden = true
        activity_IndicatorView.isHidden=false
        activity_IndicatorView.startAnimating()
        //         HeaderWrapperView.bringSubview(toFront: activity_IndicatorView)
        
        self.perform(#selector(FavouritesViewController.DismissLoader), with: nil, afterDelay: TimeInterval(Constant.sharedinstance.UploadImageDelayTime))
        
        
    }
    
    func DismissLoader() {
        if(!isUpdated)
        {
            activity_IndicatorView.stopAnimating()
            self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
            isUpdated=true
            activity_IndicatorView.isHidden=true
        }
    }
    
    func splitImage(image:UIImage){
        let imageForSplit = image
        let imageData = imageForSplit.jpegData(compressionQuality: 0.3)
        getArrayOfBytesFromImage(imageData!)
    }
    
    func getArrayOfBytesFromImage(_ imageData:Data) {
        let count = imageData.count / MemoryLayout<UInt8>.size
        var bytes = [UInt8](repeating: 0, count: count)
        let byteArray:NSMutableArray = NSMutableArray()
        (imageData as NSData).getBytes(&bytes, length:count * MemoryLayout<UInt8>.size)
        for i in 0 ..< count {
            byteArray.add(NSNumber(value: bytes[i]))
        }
        let NewArr=NSArray(array: byteArray)
        let endMarker = NSData(bytes:NewArr as! [UInt8] , length: byteArray.count)
        
        fullImage = NSArray(array: byteArray)
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        imageName = "\(Themes.sharedInstance.Getuser_id())-\(group_ID)-g-\(timestamp).jpg"
        
        SocketIOManager.sharedInstance.Delegate = self
        SocketIOManager.sharedInstance.uploadImage(from:Themes.sharedInstance.Getuser_id(),imageName:imageName,uploadType:"group",bufferAt:"0",imageByte:endMarker,file_end: "1" )
    }
    
    @IBAction func changeName_Action(_ sender: UIButton) {
        if is_you_removed
        {
            let alertview = JSSAlertView().show(
                self,
                title: Themes.sharedInstance.GetAppname(),
                text: "Unable to change the subject because you aren't a participant",
                buttonText: "Ok",
                cancelButtonText: nil
            )
            alertview.addAction {
                
            }
        }
        else
        {
            let changeNameVC:ChangeNameViewController=self.storyboard?.instantiateViewController(withIdentifier: "ChangeNameViewController") as! ChangeNameViewController
            changeNameVC.groupID = group_ID
            changeNameVC.name =  GroupDetailRec.displayName as String
            self.pushView(changeNameVC, animated: true)
        }
        
    }
    
    @IBAction func exportChatAction(_ sender: UIButton) {
        _ = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "Do you  export that all chat messages ",buttonText: "OK",color: cutomColor.alertColorForJss)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getRecord()
        groupMembers_TblView.reloadData()
        self.ReloadView()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.updateConstraintsIfNeeded()
    }
    
    func SetFrame()
    {
        if(is_you_removed)
        {
            info_table_height.constant = 20
            groupProperties_tblView.isHidden = true
            
            msg_lbl.frame = CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 20)
            msg_lbl.text = "You're no longer a participant in this group"
            msg_lbl.font = UIFont(name: "AvenirNext-Medium", size: 16)
            msg_lbl.textAlignment = NSTextAlignment.center
            msg_lbl.textColor = UIColor.black
            msg_lbl.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 219/255, alpha: 1.0)
            if(!baseView.subviews.contains(msg_lbl)) {
                baseView.addSubview(msg_lbl)
            }
            member_table_height.constant = groupMembers_TblView.contentSize.height
            action_table_height.constant =  Action_TblView.contentSize.height
        }
        else
        {
            info_table_height.constant = groupProperties_tblView.contentSize.height
            groupProperties_tblView.isHidden = false
            
            msg_lbl.removeFromSuperview()
            
            member_table_height.constant = groupMembers_TblView.contentSize.height
            action_table_height.constant =  Action_TblView.contentSize.height
        }
        
        //imageBottomConstraint.constant = created_date_Lbl.frame.maxY - groupProperties_tblView.frame.minY
        self.view.updateConstraintsIfNeeded()
        self.perform(#selector(self.updateScrollview), with: nil, afterDelay: 0.5)
    }
    
    @objc func updateScrollview()
    {
        base_view_height.constant = created_date_Lbl.frame.origin.y + created_date_Lbl.frame.size.height + 10
        //        baseView.frame = CGRect(x: 0, y: 0, width: baseView.frame.size.width, height: created_date_Lbl.frame.origin.y + created_date_Lbl.frame.size.height + 10)
        scrollView.contentSize = CGSize(width: baseView.frame.size.width, height: baseView.frame.size.height)
    }
    @IBAction func backAction(_ sender: UIButton) {
        
        if let activeController = self.navigationController?.visibleViewController{
            
            if activeController.isKind(of: GSImageViewerController.self){
                UIView.animate(withDuration: 5, animations: {
                    self.editBtn.isHidden = true
                    
                    //self.headerTitle.text = "Edit Profile"
                    
                })
                
                self.dismissView(animated: true, completion: nil)
                
                
            }
            else{
                self.pop(animated: true)
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.updateGroupInfo()
            weak.ReloadView()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}

extension GroupInfoViewController:UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if(scrollView.contentOffset.y > 0)
        {
            imageBottomConstraint.constant = -(scrollView.contentOffset.y)
        }
        else
        {
            imageBottomConstraint.constant = 0
            //            imageviewbottomlayout.constant = tableViewHeight.constant
        }
    }
}

extension GroupInfoViewController : AppDelegateDelegates {
    
    func ReceivedBuffer(Status: String, imagename: String) {
        if Status == "Updated"{
            isUpdated=true
            SocketIOManager.sharedInstance.Delegate = self
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let toDocID = "\(Themes.sharedInstance.Getuser_id())-\(group_ID)-g-\(timestamp)"
            SocketIOManager.sharedInstance.changeGroupImage(toDocID: toDocID, from: Themes.sharedInstance.Getuser_id(), groupId: group_ID, image:imagename)
            var image_Url = imagename
            if(image_Url.substring(to: 1) == ".")
            {
                image_Url.remove(at: image_Url.startIndex)
            }
            let imageURL=("\(ImgUrl)\(image_Url)")
            let Dict:[String:Any]=["displayavatar":imageURL]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_details, FetchString: group_ID, attribute: "id", UpdationElements: Dict as NSDictionary?)
            activity_IndicatorView.stopAnimating()
            activity_IndicatorView.isHidden=true
            self.image_view.setProfilePic(group_ID, "group")
        }
        else  if Status == "notconnected"{
            isUpdated=false
            self.DismissLoader()
        }
    }
}
