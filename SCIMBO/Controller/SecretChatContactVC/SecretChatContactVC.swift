//
//  SecretChatContactVC.swift
//
//
//  Created by Prem Mac on 03/01/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//
import UIKit
import SimpleImageViewer
import GLNotificationBar

protocol  SecretChatContactVCDelegate : class {
    func MovetoSecretChatView(viewcontroller:UIViewController);
}
class SecretChatContactVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate {
    weak var delegate:SecretChatContactVCDelegate?
    var notificationBar:GLNotificationBar=GLNotificationBar()
    @IBOutlet weak var secretChat_tblview: UITableView!
    @IBOutlet weak var no_contacts_view: UIView!
    var favArray:NSMutableArray=NSMutableArray()
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    var searchActive:Bool = false
    var searchArray = [FavRecord]()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        searchActive = false
        searchController.delegate=self
        searchController.searchBar.delegate=self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        //self.definesPresentationContext = true
        secretChat_tblview.tableHeaderView = searchController.searchBar
        let nibName = UINib(nibName: "FavouriteTableViewCell", bundle:nil)
        self.secretChat_tblview.register(nibName, forCellReuseIdentifier: "FavouriteTableViewCell")
        self.secretChat_tblview.estimatedRowHeight = 86
        self.ReloadTable()
        self.searchController.hidesNavigationBarDuringPresentation = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        searchActive = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    @IBAction func did_click_back(_ sender: UIButton) {
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.dismissView(animated: true, completion: nil)
    }
    
    func ReloadTable()
    {
        favArray=NSMutableArray()
        let predicate = NSPredicate(format: "is_fav != %@", "2")
        let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
        if(CheckFav.count > 0)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let p2 = NSPredicate(format: "is_fav = %@", "1")
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            let Fav_Arr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            
            if(Fav_Arr.count > 0)
            {
                for i in 0 ..< Fav_Arr.count {
                    let ResponseDict = Fav_Arr[i] as! NSManagedObject
                    let favRecord:FavRecord=FavRecord()
                    favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                    favRecord.countrycode=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "countrycode"))
                    favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                    favRecord.is_add=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_add"))
                    favRecord.msisdn=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
                    favRecord.phnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber"))
                    favRecord.profilepic=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic"))
                    favRecord.status=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "status"))
                    favRecord.contact_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_id"))
                    favRecord.is_online = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_online"))
                    favRecord.time_stamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "time_stamp"))
                    favRecord.conv_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "conv_id"))
                    favArray.add(favRecord)
                    
                }
            }
            secretChat_tblview.reloadData()
            no_contacts_view.isHidden=true
        }
        else
        {
            no_contacts_view.isHidden=false
        }
        if(favArray.count > 0)
        {
            
            secretChat_tblview.reloadData()
            no_contacts_view.isHidden=true
            
        }
        else
        {
            no_contacts_view.isHidden=false
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive == true){
            return searchArray.count
        }
        return favArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:FavouriteTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "FavouriteTableViewCell") as! FavouriteTableViewCell
        if(searchActive == false){
            let favRecord:FavRecord=favArray.object(at: indexPath.row) as! FavRecord
            cell.selectionStyle = .none
            cell.nameLbl.setNameTxt(favRecord.id, "single")
            cell.profileImage.setProfilePic(favRecord.id, "single")
            cell.profile.tag = indexPath.row
            cell.profile.addTarget(self, action: #selector(self.openImage(sender:)), for: .touchUpInside)
            cell.statusLbl.setStatusTxt(favRecord.id)
            cell.statusLbl.isHidden = cell.statusLbl.text == ""
            return cell
        }else{
            let favRecord:FavRecord = searchArray[indexPath.row]
            cell.selectionStyle = .none
            cell.nameLbl.setNameTxt(favRecord.id, "single")
            cell.profileImage.setProfilePic(favRecord.id, "single")
            cell.profile.isUserInteractionEnabled = false
            cell.statusLbl.setStatusTxt(favRecord.id)
            cell.statusLbl.isHidden = cell.statusLbl.text == ""
            return cell
        }
        
    }
    
    @IBAction func openImage(sender:UIButton){
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem:FavouriteTableViewCell? = secretChat_tblview.cellForRow(at: indexpath as IndexPath) as? FavouriteTableViewCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cellItem?.profileImage
        }
        self.presentView(ImageViewerController(configuration: configuration), animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchActive = true
        searchController.obscuresBackgroundDuringPresentation = false
        if (searchController.searchBar.text?.isEmpty == false) {
            searchActive = true
            searchArray.removeAll(keepingCapacity: false)
//            let namesBeginningWithLetterPredicate = NSPredicate(format: "(name BEGINSWITH[cd] $letter)")
//            let phoneBeginningWithLetterPredicate = NSPredicate(format: "(msisdn CONTAINS[c] $letter)")
//            let compundPredicate:NSCompoundPredicate =  NSCompoundPredicate(orPredicateWithSubpredicates: [namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]),phoneBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!])])
            
            let array = (favArray as NSArray).filter{((($0 as? FavRecord)?.name.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false) || (($0 as? FavRecord)?.msisdn.lowercased().contains(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false))}
//            filtered(using: compundPredicate)
            if(searchController.searchBar.text! == ""){
                searchActive = false
            }
            searchArray = array as! [FavRecord]
            secretChat_tblview.reloadData()
        }else{
            searchActive = false;
            secretChat_tblview.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(searchActive == false){
            let favRecord:FavRecord=favArray.object(at: indexPath.row) as! FavRecord
            
            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
            ObjInitiateChatViewController.is_fromSecret = true
            ObjInitiateChatViewController.Chat_type="secret"
            ObjInitiateChatViewController.opponent_id = favRecord.id
            searchController.searchBar.resignFirstResponder()
            searchController.isActive = false
            self.dismissView(animated: true, completion: {
                self.delegate?.MovetoSecretChatView(viewcontroller: ObjInitiateChatViewController)
            })
            
        }else{
                        
            let favRecord:FavRecord = searchArray[indexPath.row] as! FavRecord
            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController            
            ObjInitiateChatViewController.is_fromSecret = true
            ObjInitiateChatViewController.Chat_type="secret"
            ObjInitiateChatViewController.opponent_id=favRecord.id
            searchController.searchBar.resignFirstResponder()
            searchController.isActive = false
            self.dismissView(animated: true, completion: {
                self.delegate?.MovetoSecretChatView(viewcontroller: ObjInitiateChatViewController)
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

