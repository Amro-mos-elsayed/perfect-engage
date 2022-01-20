//
//  ShareDetailViewController.swift
//
//
//  Created by casperon_macmini on 10/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SWMessages
class ShareDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var shareTableView: UITableView!
    var contctID:String = String()
    var chckContact_OrgDtl:Bool = Bool()
    var chat_type:NSMutableArray = NSMutableArray()
    
    var passingFromSelect:FavRecord = FavRecord()
    var toChat:[FavRecord] = [FavRecord]()
    
    var name:String = String()
    var phNum:String = String()
    
    var contactDtlDic = [String: Any]()
    var detailDic:NSMutableArray = NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        let nibName = UINib(nibName: "ShareDetailTableViewCell", bundle:nil)
        self.shareTableView.register(nibName, forCellReuseIdentifier: "ShareDetailTableViewCell")
        self.shareTableView.estimatedRowHeight = 120
        self.shareTableView.rowHeight = UITableView.automaticDimension
        self.shareTableView.tableFooterView = UIView()
        chckContact_OrgDtl = false
        print(contctID)
        getContactDetail()
        
        // Do any additional setup after loading the view.
    }
    
    func getContactDetail(){
        let contactStore = CNContactStore()
        let contactNo_ID:String = Themes.sharedInstance.removeUniqueContactID(ID: contctID)
        let predicate = CNContact.predicateForContacts(withIdentifiers : [contactNo_ID])
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey,CNContactViewController.descriptorForRequiredKeys()] as [Any]
        var contacts = [CNContact]()
        do {
            contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys as! [CNKeyDescriptor])
            if contacts.count > 0 {
                do {
                    for i in 0..<contacts.count
                    {
                        let currentcontact:CNContact = contacts[i] as CNContact
                        let Phonenumber:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ((currentcontact.phoneNumbers[0].value ).value(forKey: "digits") as! String))
                        
                        print(currentcontact.givenName)
                        print(currentcontact.organizationName)
                        print(currentcontact.jobTitle)
                        let nameDic = ["name":currentcontact.givenName,"isSelect":false] as NSDictionary
                        let depatmetDtl = ["organization":currentcontact.organizationName,"jobtitile":currentcontact.jobTitle,"isSelect":false] as [String : Any]
                        if currentcontact.organizationName != "" || currentcontact.jobTitle != ""{
                            
                            chckContact_OrgDtl = true
                        }else{
                            chckContact_OrgDtl = false
                        }
                        
                        let phno = ["phone":Phonenumber,"isSelect":false] as [String : Any]
                        detailDic.add(nameDic)
                        detailDic.add(depatmetDtl)
                        detailDic.add(phno)
                    }
                    shareTableView.reloadData()
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return detailDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ShareDetailTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "ShareDetailTableViewCell") as! ShareDetailTableViewCell
        _ = contactDtlDic as NSDictionary
        let getValDet = detailDic[indexPath.row] as! NSDictionary
        let isSelect = getValDet.value(forKey: "isSelect") as! Bool
        
        cell.nameLbl.font = UIFont.systemFont(ofSize: 16.0)
        
        cell.chkBoxView.isHidden = false
        cell.nameLbl.isHidden  = false
        
        cell.anotherDtl.isHidden = false
        cell.anotherDtl.sizeToFit()
        
        if indexPath.row == 0{
            
            cell.chkBoxView.isHidden = true
            cell.nameLbl.text = getValDet.value(forKey: "name") as! String?
            //cell.nameLbl.font = UIFont.systemFont(ofSize: 16.0)
            
            //cell.topConstraintLbl.constant = 18
            //cell.leadingConstraintLbl.constant = 50
            //cell.heightConstrnt_AnotherLbl.constant = 0
            
            if isSelect{
                cell.chkBoxView.image = #imageLiteral(resourceName: "roundtick")
            }
            else{
                cell.chkBoxView.image = #imageLiteral(resourceName: "uncheckround")
            }
            
            cell.anotherDtl.isHidden = true
            
            //self.shareTableView.separatorColor = UIColor.white
            //tableView.separatorColor = UIColor.clear
            
            return cell
            
        }
            
        else if indexPath.row == 1{
            
            let chkOrganistn = getValDet.value(forKey: "organization") as! String
            let jobTitle =   getValDet.value(forKey: "jobtitile") as! String
            
            if chkOrganistn == "" && jobTitle == ""{
                
                cell.chkBoxView.isHidden = true
                cell.nameLbl.isHidden  = true
                cell.anotherDtl.isHidden = true
                return cell
                
            }
            else{
                if isSelect{
                    cell.chkBoxView.image = #imageLiteral(resourceName: "roundtick")
                }
                else{
                    cell.chkBoxView.image = #imageLiteral(resourceName: "uncheckround")
                }
                
                if chkOrganistn != ""{
                    
                    cell.nameLbl.text = "company"
                    cell.nameLbl.textColor = UIColor.blue
                    //cell.nameLbl.font = UIFont.systemFont(ofSize: 14.0)
                    //cell.anotherDtl.numberOfLines = 0
                    cell.anotherDtl.text = "\(chkOrganistn)\n\(jobTitle)"
                    cell.chkBoxView.isHidden = false
                    
                    //cell.anotherDtl.text = chkOrganistn
                    //cell.anotherDtl.text =   getValDet.value(forKey: "jobtitile") as! String?
                    
                    return cell
                    
                }
                
            }
        }
        
        //   else if indexPath.row  == 2{
        if isSelect{
            cell.chkBoxView.image = #imageLiteral(resourceName: "roundtick")
        }
        else{
            cell.chkBoxView.image = #imageLiteral(resourceName: "uncheckround")
        }
        
        cell.nameLbl.text = "mobile"
        cell.nameLbl.font = UIFont.systemFont(ofSize: 14.0)
        cell.nameLbl.textColor = UIColor.blue
        cell.anotherDtl.text = getValDet.value(forKey: "phone") as! String?
        
        cell.chkBoxView.isHidden = false
        return cell
        
        // }
        
        //  else if indexPath.row == 2{
        
        // }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let getVal = contactDtlDic as NSDictionary
        var getValDet = detailDic[indexPath.row] as! [String:Any]
        // let isSelect = getValDet.value(forKey: "isSelect") as! Bool
        let isSelect = getValDet["isSelect"] as! Bool
        print(isSelect)
        print(getValDet)
        if isSelect {
            
            //getValDet.value(forKey: "isSelect")
            getValDet["isSelect"] = false
            detailDic.removeObject(at: indexPath.row)
            detailDic.insert(getValDet, at: indexPath.row)
            print(detailDic)
            //getValDet.setValue(false, forKey: "isSelect")
            
        }
        else{
            
            getValDet["isSelect"] = true
            detailDic.removeObject(at: indexPath.row)
            detailDic.insert(getValDet, at: indexPath.row)
        }
        shareTableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            if chckContact_OrgDtl == false{
                return 0
            }
            else{
                return 100
            }
        }
        return 80
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        
        
        self.pop(animated: true)
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        
        let pass:NSMutableArray = NSMutableArray()
        pass.add(passingFromSelect)
        if(toChat.count == 1){
            let chatLocked = Themes.sharedInstance.isChatLocked(id: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.CheckNullvalue(Passed_value: toChat[0].id)), type: "single")
            if(chatLocked == true){
                self.enterToChat(id: Themes.sharedInstance.CheckNullvalue(Passed_value: toChat[0].id), type: "single",toChat: toChat[0])
            }else{
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = chat_type[0] as! String
                ObjInitiateChatViewController.opponent_id = toChat[0].id
                ObjInitiateChatViewController.appear = false
                ObjInitiateChatViewController.goBack = true
                ObjInitiateChatViewController.go = true
                ObjInitiateChatViewController.share(rec:pass)
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
            
            
        }else{
            
            
            for i in 0..<toChat.count{
                Themes.sharedInstance.shareContacttoMultiple(rec: pass, opponent_id: toChat[i].id, Chat_type: chat_type[i] as! String)
            }
            Themes.sharedInstance.ShowNotification("Contact details successfully shared", true)            
            self.popToRoot(animated: true)
            
        }
        
        
    }
    
    func enterToChat(id:String,type:String,toChat:FavRecord){
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let pass:NSMutableArray = NSMutableArray()
                pass.add(self.passingFromSelect)
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = id
                ObjInitiateChatViewController.appear = false
                ObjInitiateChatViewController.goBack = true
                ObjInitiateChatViewController.go = true
                print(self.passingFromSelect.profilepic)
                ObjInitiateChatViewController.share(rec:pass)
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

