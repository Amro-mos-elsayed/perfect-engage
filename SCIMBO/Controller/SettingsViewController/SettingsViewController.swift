//
//  SettingsViewController.swift
//
//
//  Created by CASPERON on 16/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import JSSAlertView
import Social
import MessageUI


class SettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var settings_TblView:UITableView!
    @IBOutlet weak var settingLbl:UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    var starredMess_Arry:NSArray = NSArray()
    var accountDeta_Arr:NSArray = NSArray()
    var aboutHelp_Arr:NSArray = NSArray()
    
    var starredImag_Arry:NSArray = NSArray()
    var accountImg_Arr:NSArray = NSArray()
    var aboutHelpImg_Arr:NSArray = NSArray()
    var customClr = CustomColor()
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()

        changeArray()
        
        
        let nibName = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        self.settings_TblView.register(nibName, forCellReuseIdentifier: "SettingsTableViewCell")
        
        let nibNameHeader = UINib(nibName: "SettingHeaderTableViewCell", bundle: nil)
        self.settings_TblView.register(nibNameHeader, forCellReuseIdentifier: "SettingHeaderTableViewCell")
        
        settings_TblView.tableFooterView = UIView()
        settings_TblView.separatorColor = UIColor.clear
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        settings_TblView.estimatedRowHeight =  40
        let mediaType:AVMediaType = AVMediaType.video;
        
        AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (isGivenpermission
            :Bool) in
        })
    }
    
    
    func changeArray(){
        //let web = NSLocalizedString("Web/Desktop", comment: "oo")
        starredMess_Arry = [NSLocalizedString("Starred Messages", comment: "note"),
                            NSLocalizedString("Privacy", comment: "note"),
                            NSLocalizedString("Chats", comment: "note"),
                            NSLocalizedString("Notifications", comment: "note"),
                            NSLocalizedString("Data Usage", comment: "note"),
                            //NSLocalizedString("Email Settings", comment: "note"),
                            NSLocalizedString("About and Help", comment: "note"),
                            NSLocalizedString("Log out", comment: "note")]//,NSLocalizedString("Tell a Friend", comment: "note")]//"Web Logout"
        
        starredImag_Arry = ["star","account","chats","notification","datausage"/*,"mail"*/,"about","logout",]//,"tellafriend"]//,"logout"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 150
        }
        
        return 54
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.contentView.layer.borderWidth = 1
        header.contentView.layer.borderColor = customClr.lightgrayColor.cgColor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }
        if section == 1{
            return starredImag_Arry.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SettingsTableViewCell = settings_TblView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        
        if indexPath.section == 0{
            let cellHeader:SettingHeaderTableViewCell = settings_TblView.dequeueReusableCell(withIdentifier: "SettingHeaderTableViewCell") as! SettingHeaderTableViewCell
            cellHeader.userImage.setProfilePic(Themes.sharedInstance.Getuser_id(), "single")
            cellHeader.userName.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
            cellHeader.userStatus.setStatusTxt(Themes.sharedInstance.Getuser_id())
            cellHeader.accessoryType = .none
            return cellHeader
            
        }
        if indexPath.section == 1{
            cell.setting_Lbl.text = starredMess_Arry[indexPath.row] as? String
            cell.setting_Img.image = UIImage(named:starredImag_Arry[indexPath.row] as! String)
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0{
            
            let editProfileVC = storyboard?.instantiateViewController(withIdentifier:"EditProfileViewController" ) as! EditProfileViewController
            self.pushView(editProfileVC, animated: true)
            
        }
        else if indexPath.section == 1{
            
            if indexPath.row == 0{
                
                let  StarredDetailVC = storyboard?.instantiateViewController(withIdentifier: "StarredViewControllerID") as! StarredViewController
                StarredDetailVC.isallStarredmessages = true
                self.pushView(StarredDetailVC, animated: true)
                
            }
            else if indexPath.row == 122{
                
                let mediaType:AVMediaType = AVMediaType.video;
                let avStatus:AVAuthorizationStatus=AVCaptureDevice.authorizationStatus(for: mediaType)
                
                if(avStatus == AVAuthorizationStatus.authorized)
                {
                    let QrcodeVC = storyboard?.instantiateViewController(withIdentifier:"QrcodeViewControllerID" ) as! QrcodeViewController
                    self.pushView(QrcodeVC, animated: true)
                }
                if(avStatus == AVAuthorizationStatus.notDetermined)
                {
                    AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (isGivenpermission
                        :Bool) in
                        
                        if(!isGivenpermission)
                        {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                })
                            }
                        }
                        else
                        {
                            print("asda")
                            let QrcodeVC = self.storyboard?.instantiateViewController(withIdentifier:"QrcodeViewControllerID" ) as! QrcodeViewController
                            self.pushView(QrcodeVC, animated: true)
                            
                            
                        }
                    })
                    
                }
                if(avStatus == AVAuthorizationStatus.denied)
                {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }
                
                if(avStatus == AVAuthorizationStatus.restricted)
                {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }
                
                
            }
            else if indexPath.row == 1{
                
                let  privacyVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyViewController") as! PrivacyViewController
                self.pushView(privacyVC, animated: true)
            }
            else if indexPath.row == 2
            {
                let chatVC  = self.storyboard?.instantiateViewController(withIdentifier: "ChatVCID") as! ChatVC
                self.pushView(chatVC, animated: true)
            }
            else if indexPath.row == 3{
                let notificationVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVCID") as! NotificationVC
                self.pushView(notificationVC, animated: true)
                
            }
            else if indexPath.row == 4{
                let datausageVC = self.storyboard?.instantiateViewController(withIdentifier: "DataUsageID") as! DataUsageViewController
                self.pushView(datausageVC, animated: true)
                
            }
//            else if indexPath.row == 5{
//                let mailVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateEmailSettingsViewController") as! UpdateEmailSettingsViewController
//                self.pushView(mailVC, animated: true)
//
//            }
            else if indexPath.row == 5{
                let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
                SocketIOManager.sharedInstance.chatSettings(id: Themes.sharedInstance.Getuser_id(), mode: "phone", chat_type: "single")
                self.pushView(aboutVC, animated: true)
            }
            else if indexPath.row == 6{
                logout()
            }
                
//            else if indexPath.row == 9{
//                let alertview = JSSAlertView().show(
//                    self,
//                    title: Themes.sharedInstance.GetAppname(),
//                    text: "Are you sure, you want to Logout?",
//                    buttonText: "Yes",
//                    cancelButtonText: "No"
//                )
//                alertview.addAction(self.Logout)
//            }
            
        }
        
    }
    
    func logout() {
        let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let Logout: UIAlertAction = UIAlertAction(title: NSLocalizedString("Log out", comment: "comment"), style: .default) { action -> Void in
            
            (UIApplication.shared.delegate as! AppDelegate).Logout()
        }
        let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { action -> Void in
        }
        sheet_action.addAction(Logout)
        sheet_action.addAction(CancelAction)
        self.presentView(sheet_action, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismissView(animated: true, completion: nil)
        var message = ""
        switch result {
        case .cancelled:
            message = "Message cancelled"
            break
        case .sent:
            message = "Message sent"
            break
        case .failed:
            message = "Message failed"
            break
        default:
            break
        }
        self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        self.dismissView(animated: true, completion: nil)
        
        var message = ""
        
        if(error != nil) {
            message = "Error Occurred."
        }
        else
        {
            switch result {
            case .cancelled:
                message = "Mail cancelled."
                break
            case .failed:
                message = "Mail failed."
                break
            case .sent:
                message = "Mail sent."
                break
            case .saved:
                message = "Mail saved."
                break
            default:
                break
            }
        }
        self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
    }

    func movetoQRscanVC()
    {
        let QrcodeVC = self.storyboard?.instantiateViewController(withIdentifier:"QrcodeViewControllerID" ) as! QrcodeViewController
        self.pushView(QrcodeVC, animated: true)
        
    }
    func openSetting()
    {
        let alertController = UIAlertController (title: Themes.sharedInstance.GetAppname(), message: "Go to Settings and enable camera", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.presentView(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
            if placemarks == nil {
                return
            }
            let currentLocPlacemark = placemarks![0]
            var code = currentLocPlacemark.isoCountryCode
            let dictCodes : NSDictionary = Themes.sharedInstance.getCountryList()
            code = (dictCodes.value(forKey: code!)as! NSArray)[1] as? String
            Themes.sharedInstance.saveCounrtyphone(countrycode: code!)
            self.locationManager.stopUpdatingLocation()
            
        })
    }
    private func locationManager(manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    
    @IBAction func editProfile_Action(_ sender: UIButton) {
        
        let editProfileVC = storyboard?.instantiateViewController(withIdentifier:"EditProfileViewController" ) as! EditProfileViewController
        self.pushView(editProfileVC, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settings_TblView.reloadData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.settings_TblView.reloadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }
}
