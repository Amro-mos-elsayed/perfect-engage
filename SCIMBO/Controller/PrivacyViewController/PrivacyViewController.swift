//
//  PrivacyViewController.swift
//
//
//  Created by CASPERON on 22/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    @IBOutlet weak var privacyLbl:UILabel!
    @IBOutlet weak var lastSeenLbl:UILabel!
    @IBOutlet weak var profilePhotoLbl:UILabel!
    @IBOutlet weak var statusLbl:UILabel!
    @IBOutlet weak var descriptionSeenLbl: UILabel!

    @IBOutlet weak var  lastSeenTitleLbl:UILabel!
    @IBOutlet weak var  profilePhotoTitleLbl:UILabel!
    @IBOutlet weak var  statusTitleLbl:UILabel!

    @IBOutlet weak var  blockedLbl:UILabel!
    @IBOutlet weak var  listofBlockLbl:UILabel!

    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var scrollView_Height: NSLayoutConstraint!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var  messagingLbl:UIButton!
    @IBOutlet weak var personalInfoBtn:UIButton!
    var setImageString:NSString = NSString()
    var optionsArray:NSArray = NSArray()
    var favArray:NSMutableArray = NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        setImageString = "unchecked"
        let lang = Locale.preferredLanguages[0].substring(to: 2)
             if lang == "ar"{
                 personalInfoBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
                 messagingLbl.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
             }else{
                personalInfoBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                messagingLbl.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
             }
    }
    
    func reloadData(){
        favArray=NSMutableArray()
        let blocks=DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: Constant.sharedinstance.Blocked_user) as! [Blocked_user]
        blockedLbl.text = NSLocalizedString("Blocked Contacts:", comment: "note") + " " + "\(blocks.count)"
    }
    
    @IBAction func blocked_contacts(_ sender: UIButton) {
        let blockedVC = storyboard?.instantiateViewController(withIdentifier:"BlockedContactsViewControllerID" ) as! BlockedContactsViewController
        self.pushView(blockedVC, animated: true)
        
    }
    @IBAction func profileInfo(_ sender: UIButton) {
        
//        if sender.tag == 0
//        {
//            moveToOptionsVC("Last Seen")
//        }
//        else if sender.tag == 1{
//            moveToOptionsVC("Profile")
//        }
//        else if sender.tag == 2{
//            moveToOptionsVC("Status")
//        }
    }
    
    func loadData(){
        
        let GetUserDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:  Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! [User_detail]
        var last_seen:String = ""
        var profile_photo:String = ""
        var show_status:String = ""
        _ = GetUserDetails.map {
            last_seen = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.last_seen)
            profile_photo = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.profile_photo)
            show_status = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.show_status)

        }
        if languageHandler.ApplicationLanguage() == "ar" {
            if last_seen == "everyone"{
                last_seen = "الكل"
            }
            if profile_photo == "everyone"{
                profile_photo = "الكل"
            }
            if show_status == "everyone"{
                show_status = "الكل"
            }
        }else{
            last_seen = last_seen.capitalized
            profile_photo = profile_photo.capitalized
            show_status = show_status.capitalized
        }
        lastSeenLbl.text = (last_seen == "mycontacts") ? "My Contacts" :  last_seen
        profilePhotoLbl.text = (profile_photo == "mycontacts") ? "My Contacts" : profile_photo
        statusLbl.text = (show_status == "mycontacts") ? "My Contacts" : show_status
    }
    
    func moveToOptionsVC(_ title : String) {
        let optionsVC = storyboard?.instantiateViewController(withIdentifier:"OptionsViewController" ) as! OptionsViewController
        optionsVC.option = title
        self.pushView(optionsVC, animated: true)
        
    }
    
    @IBAction func checkBox_Action(_ sender: UIButton) {
        if  setImageString == "unchecked"{
            
            setImageString = "checked"
            checkBoxBtn.setImage(#imageLiteral(resourceName: "checkbox"), for: UIControl.State.normal)
        }
        else if setImageString == "checked"{
            setImageString = "unchecked"
            
            checkBoxBtn.setImage(#imageLiteral(resourceName: "uncheckbox"), for: UIControl.State.normal)
        }
        else{
            
        }
        
        
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.pop(animated: true)
    }    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reloadData()
            weak.loadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }
}
