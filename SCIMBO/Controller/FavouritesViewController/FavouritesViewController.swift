 //
 //  FavouritesViewController.swift
 //
 //
 //  Created by CASPERON on 16/12/16.
 //  Copyright © 2016 CASPERON. All rights reserved.
 //
 
 import UIKit
 import SDWebImage
 import ContactsUI
 import SimpleImageViewer
 protocol  FavouritesViewControllerDelegate : class {
    func MovetoChatView(viewcontroller:UIViewController);
    func newgroup()
 }
 
 class FavouritesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ContactHandlerDelegate,CNContactViewControllerDelegate,UIGestureRecognizerDelegate,UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate{
    
    weak var delegate:FavouritesViewControllerDelegate?
    var favArray:NSMutableArray=NSMutableArray()
    static let sharedinstance=FavouritesViewController()
    var refreshControl: UIRefreshControl!
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var background_view: UIView!
    var encryption =  StringEncryption()
    var searchArray = [FavRecord]()
    var searchActive:Bool = false
    @IBOutlet weak var NocontactView: UIView!
    @IBOutlet weak var NocontactView1: UIView!
    @IBOutlet weak var RefreshBtn: CustomBtnThemeTxtColor!
    @IBOutlet weak var NoContact_Btn:UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var favouriteTblView: UITableView!
    @IBOutlet weak var editBtn:UIButton!
    @IBOutlet weak var total_contact: UILabel!
    @IBOutlet weak var favouritesLbl:UILabel!
    @IBOutlet weak var refreshBtn1: UIButton!
    @IBOutlet weak var no_contact_lbl: CustomLblFont!
    var timer : Timer?
    @IBOutlet weak var secret_chat_btn: UIButton!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        searchActive = false
        searchController.delegate=self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        //self.definesPresentationContext = true
        favouriteTblView.tableHeaderView = searchController.searchBar
        let nibName = UINib(nibName: "FavouriteTableViewCell", bundle:nil)
        self.favouriteTblView.register(nibName, forCellReuseIdentifier: "FavouriteTableViewCell")
        self.favouriteTblView.estimatedRowHeight = 66
        //        favouritesLbl.text = Themes.sharedInstance.setLang(title: "favourite")
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FavouritesViewController.refresh
            ), for: .valueChanged)
        favouriteTblView.addSubview(refreshControl)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        editBtn.addTarget(self, action: #selector(self.DismissView), for: .touchUpInside)
    }
    
    func startrotateView()
    {
        self.refreshBtn1.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.refreshBtn1.transform = self.refreshBtn1.transform.rotated(by: CGFloat(.pi/4))
        }) { completed in
            if(self.no_contact_lbl.text != NSLocalizedString(" Unable to load contacts. Kindly tap on 🔃 icon to try again.", comment: "note") && self.no_contact_lbl.text != " No Contacts")
            {
                self.startrotateView()
            }
        }
    }
    
    @objc func stoprotateView()
    {
        if(favArray.count == 0)
        {
            no_contact_lbl.text = NSLocalizedString(" Unable to load contacts. Kindly tap on 🔃 icon to try again.", comment: "note")
        }
        self.refreshBtn1.isUserInteractionEnabled = true
        timer?.invalidate()
        self.refreshBtn1.layer.removeAllAnimations()
    }
    
    
    
    //    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    //            self.searchController.searchBar.showsCancelButton = false;
    //    }
    
    
    @objc func DismissView()
    {
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        
        self.dismissView(animated: true, completion: nil)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }

    func callBackfavContact() {
        
        self.ReloadTable()
    }
    
    @IBAction func go_to_secret(_ sender: UIButton) {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        let singleInfoVC:SecretChatsController=self.storyboard?.instantiateViewController(withIdentifier: "SecretChatsControllerID") as! SecretChatsController
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.dismissView(animated: true, completion: {
            self.delegate?.MovetoChatView(viewcontroller: singleInfoVC)
        })
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ContactHandler.sharedInstance.Delegate?=self
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        searchActive = false
        self.ReloadTable()
        // favouriteTblView.contentOffset = CGPoint(x: 0, y: 60);
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
    func ReloadTable()
    {
        RefreshBtn.isUserInteractionEnabled=true
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        refreshControl.endRefreshing()
        favArray=NSMutableArray()
        //let predicate = NSPredicate(format: "is_fav != %@", "2")
        let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: nil, Limit: 0) as! NSArray
        if(CheckFav.count > 0)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            //let p2 = NSPredicate(format: "is_fav = %@", "1")
            //let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            let Fav_Arr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: p1,Limit:0) as! NSArray
            
            if(Fav_Arr.count > 0)
            {
                for i in 0 ..< Fav_Arr.count {
                    let ResponseDict = Fav_Arr[i] as! NSManagedObject
                    let favRecord:FavRecord=FavRecord()
                    favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                    favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                    favRecord.msisdn=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
                    favRecord.phnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber"))
                    favRecord.isEmployee = (ResponseDict as! Favourite_Contact).isUserTypeEmployee
                    favArray.add(favRecord)
                    
                }
            }
            let sortedArray = (favArray as! [FavRecord]).sorted { $0.name.lowercased() < $1.name.lowercased()}
            favArray.removeAllObjects()
            favArray.addObjects(from: sortedArray)
            
        }
        else
        {
            NocontactView.isHidden=true
            NocontactView1.isHidden=false
        }
        if(favArray.count > 0)
        {
            
            favouriteTblView.reloadData()
            //secret_chat_btn.isHidden = false
            NocontactView.isHidden=true
            NocontactView1.isHidden=true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.stoprotateView()
            })
        }
        else
        {
            //secret_chat_btn.isHidden = true
            NocontactView.isHidden=true
            NocontactView1.isHidden=false
            if(timer == nil)
            {
                self.startrotateView()
                self.no_contact_lbl.text = "Loading contacts..."
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(Constant.sharedinstance.SocketWaitDelaytime), target: self, selector: #selector(self.stoprotateView), userInfo: nil, repeats: true)
            }
//            if(!ContactHandler.sharedInstance.StorecontactInProgress)
//            {
                ContactHandler.sharedInstance.StoreContacts()
//            }
        }
        total_contact.text = NSLocalizedString("Friends ", comment: "note") + "(" + "\(favArray.count)" + ")"
        RefreshBtn.setTitle("   Refresh Favourite Contact", for: .normal)
        NoContact_Btn.setTitle("   Invite friends to \(Themes.sharedInstance.GetAppname())", for: .normal)
    }
    
    @IBAction func openImage(sender:UIButton){
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem:FavouriteTableViewCell? = favouriteTblView.cellForRow(at: indexpath as IndexPath) as? FavouriteTableViewCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cellItem?.profileImage
        }
        self.presentView(ImageViewerController(configuration: configuration), animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive == true){
            return searchArray.count
        }
        return favArray.count
        
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
            cell.isEmployeeImage.image = favRecord.isEmployee ? #imageLiteral(resourceName: "employee-icon") : #imageLiteral(resourceName: "guest-icon")
            cell.profile.tag = indexPath.row
            cell.profile.addTarget(self, action: #selector(self.openImage(sender:)), for: .touchUpInside)
            cell.statusLbl.setStatusTxt(favRecord.id)
            cell.profileImage.contentMode = .scaleAspectFill
            cell.nameLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
            return cell
        }else{
            let favRecord:FavRecord=searchArray[indexPath.row]
            cell.selectionStyle = .none
            cell.nameLbl.setNameTxt(favRecord.id, "single")
            cell.profileImage.setProfilePic(favRecord.id, "single")
            cell.isEmployeeImage.image = favRecord.isEmployee ? #imageLiteral(resourceName: "employee-icon") : #imageLiteral(resourceName: "guest-icon")
            cell.profile.tag = indexPath.row
            cell.profile.addTarget(self, action: #selector(self.openImage(sender:)), for: .touchUpInside)
            cell.statusLbl.setStatusTxt(favRecord.id)
            
            cell.profileImage.contentMode = .scaleAspectFill
            cell.nameLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
            return cell
        }
        
    }
    
    func enterToChat(id:String,type:String,indexpath:IndexPath){
        self.searchController.dismissView(animated: true, completion: nil)
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.dismissView(animated: true, completion: {
            Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
                if(success)
                {
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type = type
                    ObjInitiateChatViewController.opponent_id = id
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.delegate?.MovetoChatView(viewcontroller: ObjInitiateChatViewController)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //searchController.isActive = false
        if(searchActive == false){
            let favRecord:FavRecord=favArray.object(at: indexPath.row) as! FavRecord
            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
            let chatLocked = Themes.sharedInstance.isChatLocked(id: favRecord.id, type: "single")
            if(chatLocked == true){
                self.enterToChat(id: favRecord.id, type: "single", indexpath: indexPath)
            }else{
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = favRecord.id
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.isActive = false
                self.dismissView(animated: true, completion: {
                    self.delegate?.MovetoChatView(viewcontroller: ObjInitiateChatViewController)
                })
            }
        }else{
            let favRecord:FavRecord = searchArray[indexPath.row]
            let chatLocked = Themes.sharedInstance.isChatLocked(id: favRecord.id, type: "single")
            if(chatLocked == true){
                self.enterToChat(id: favRecord.id, type: "single", indexpath: indexPath)
            }else{
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = favRecord.id
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.isActive = false
                self.dismissView(animated: true, completion: {
                    self.delegate?.MovetoChatView(viewcontroller: ObjInitiateChatViewController)
                })
            }
        }
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        Themes.sharedInstance.saveLanguage(str:Themes.sharedInstance.kLanguage as NSString)
        Themes.sharedInstance.SetLanguageToApp()
        //        favouritesLbl.text = Themes.sharedInstance.setLang(title: "favourite")
        print("view appeared")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func DidclickInvite(_ sender: Any) {
        let indexDic = ["index":2]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.getPageIndex), object: nil, userInfo: indexDic)
    }
    @IBAction func DidclickRefresh(_ sender: Any) {
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            Themes.sharedInstance.activityView(View: self.view)
            self.refresh()
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
    }
    
    @IBAction func DidclickRefreshButton(_ sender: Any) {
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            
            let predicate = NSPredicate(format: "is_fav != %@", "2")
            let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
            if(CheckFav.count > 0)
            {
                self.ReloadTable()
            }
            else
            {
                self.no_contact_lbl.text = "Loading contacts..."
                self.startrotateView()
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(Constant.sharedinstance.SocketWaitDelaytime), target: self, selector: #selector(self.stoprotateView), userInfo: nil, repeats: true)
                ContactHandler.sharedInstance.Delegate?=self
                RefreshBtn.isUserInteractionEnabled=false
                ContactHandler.sharedInstance.StoreContacts()
            }
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
            self.stoprotateView()
        }
        
    }
    
    
    
    @objc func refresh()
    {
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            self.perform(#selector(FavouritesViewController.DismissLoader), with: nil, afterDelay: TimeInterval(Constant.sharedinstance.SocketWaitDelaytime))
            ContactHandler.sharedInstance.Delegate?=self
            RefreshBtn.isUserInteractionEnabled=false
            ContactHandler.sharedInstance.StoreContacts()
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
        
    }
    
    @objc func DismissLoader() {
        RefreshBtn.isUserInteractionEnabled=true
        //
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        if(self.isModal()  || AppDelegate.sharedInstance.isVideoViewPresented)
        {
            self.ReloadTable()
        }
    }
    
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismissView(animated: true, completion: nil)
    }
    
    @IBAction func DidClickContact(_ sender: Any) {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            let controller = CNContactViewController(forNewContact: nil)
            //controller.editButtonItem.tintColor = UIColor.blue
            controller.delegate = self
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.isNavigationBarHidden = false
            navigationController.navigationBar.tintColor = CustomColor.sharedInstance.themeColor
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.presentView(navigationController, animated: true)
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
        
    }
    
    @IBAction func DidClickNewGroup(_ sender: Any) {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        self.dismissView(animated: true, completion: {
            self.delegate?.newgroup()
        })
    }

    
    
    func updateSearchResults(for searchController: UISearchController) {
        searchActive = true
        searchController.obscuresBackgroundDuringPresentation = false
        if (searchController.searchBar.text?.isEmpty == false) {
            searchActive = true
            searchArray = []
//            let namesBeginningWithLetterPredicate = NSPredicate(format: "(name CONTAINS[c] $letter)")
//            let phoneBeginningWithLetterPredicate = NSPredicate(format: "(msisdn CONTAINS[c] $letter)")
//            let compundPredicate:NSCompoundPredicate =  NSCompoundPredicate(orPredicateWithSubpredicates: [namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]),phoneBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!])])
            let array = (favArray as NSArray).filter{((($0 as? FavRecord)?.name.contains(searchController.searchBar.text!) ?? false) || (($0 as? FavRecord)?.msisdn.contains(searchController.searchBar.text!) ?? false))}
//            let array = (favArray as NSArray).filtered(using: compundPredicate)
            if(searchController.searchBar.text! == ""){
                searchActive = false
            }
            
            searchArray = array as! [FavRecord]
            DispatchQueue.main.async {
                self.favouriteTblView.reloadData()
             }
            
        }else{
            
            searchActive = false;
            favouriteTblView.reloadData()
            
        }
    }
    
    @IBAction func Didclickuser_img(_ sender: Any) {
        
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.ReloadTable()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.NoContacts), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            if(weak.favArray.count == 0)
            {
                weak.no_contact_lbl.text = NSLocalizedString(" No Contacts", comment:"no" ) 
            }
            weak.refreshBtn1.isUserInteractionEnabled = true
            weak.timer?.invalidate()
            weak.refreshBtn1.layer.removeAllAnimations()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
