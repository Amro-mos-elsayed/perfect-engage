//
//  NewChatViewController.swift
//
//
//  Created by Casp iOS on 08/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import SDWebImage
class NewChatViewController: UIViewController,TableViewIndexDelegate,TableViewIndexDataSource,ExampleContainer,UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchResultsUpdating, UISearchBarDelegate {
    
    fileprivate var hasSearchIndex = true
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    var favArray:NSMutableArray=NSMutableArray()
    var groupListArray:NSMutableArray =  NSMutableArray()
    fileprivate var indexDataSource: TableViewIndexDataSource!
    var example: Example!
    fileprivate var data_Source: DataSource!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate var tableViewIndex: TableViewIndex!
    @IBOutlet weak var Header_lbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var dataSourceObject:NSArray=NSArray()
    var searchArray = [NSObject]()
    var searchGroupArr = [NSObject]()
    var searchActive:Bool = false
    var checkTable:String = String()
    var customClr = CustomColor()
    // var favContacts_ArrObj = [NSObject]()
    //var groupInfoList = [NSObject]()
    var favContArray:NSMutableArray = NSMutableArray()
    var favRec = NSMutableArray()
    var headerTitle:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        headerTitle = ["Contacts","Groups"]
        searchController.delegate=self
        searchController.searchBar.delegate=self
        searchController.searchResultsUpdater = self
        hasSearchIndex = example.hasSearchIndex
        indexDataSource = example.indexDataSource
        data_Source = example.dataSource
        CheckBool = true
        data_Source.initwithData()
        tableViewIndex.delegate = self
        tableViewIndex.dataSource = self
        tableView.tableHeaderView = searchController.searchBar
        setNativeIndexHidden(true)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        setNativeIndexHidden(true)
        getFavContacts()
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.dismissView(animated:true, completion:nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        data_Source.initwithData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchActive == true{
            return 1
        }
        print("The section is \(data_Source.numberOfSections())")
        return data_Source.numberOfSections()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive == true{
            if section == 0 {
                return searchArray.count
            }
                
            else if section == 1 {
                return searchGroupArr.count
            }
            
        }
        
        if data_Source.numberOfItemsInSection(section) == 0
        {
            return 0
        }
        
        return data_Source.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if data_Source.numberOfItemsInSection(section) == 0
        {
            
            return nil
            
        }
        
        if searchActive == true{
            return ""
        }
        
        //        if searchActive == true{
        //            return headerTitle[section] as! String
        //        }
        
        return data_Source.titleForHeaderInSection(section)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchActive == true{
            if section == 0{
                if searchArray.count == 0{
                    return 0
                }
                else{
                    return 30
                }
            }
            else if  section == 1{
                if searchGroupArr.count == 0
                {
                    return 0
                }
                else{
                    return 30
                }
            }
        }
        
        if data_Source.numberOfItemsInSection(section) == 0
        {
            
            return 0
            
        }else{
            return 30
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        
        if searchActive == true{
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
            header.textLabel?.textColor = UIColor.lightGray
        }
            
        else{
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
            header.textLabel?.textColor = UIColor.black
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchActive == true{
            if indexPath.section == 0{
                let nib = UINib(nibName: "NewChatFltrCntctGroupTableViewCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "NewChatFltrCntctGroupTableViewCell")
                let searchCell = tableView.dequeueReusableCell(withIdentifier: "NewChatFltrCntctGroupTableViewCell") as! NewChatFltrCntctGroupTableViewCell
                //searchCell.textLabel?.text = ""
                let currentSearchArray : FavRecord = searchArray[indexPath.row] as! FavRecord
                searchCell.nameLbl.setNameTxt(currentSearchArray.id, "single")
                searchCell.statusLbl.setStatusTxt(currentSearchArray.id)
                searchCell.img_View.setProfilePic(currentSearchArray.id, "single")
            
                searchCell.img_View.layer.cornerRadius =  searchCell.img_View.frame.size.width/2
                searchCell.img_View.clipsToBounds=true
                return searchCell
            }
                
            else if indexPath.section  == 1 {
                let nib = UINib(nibName: "NewChatFltrCntctGroupTableViewCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "NewChatFltrCntctGroupTableViewCell")
                let searchCell = tableView.dequeueReusableCell(withIdentifier: "NewChatFltrCntctGroupTableViewCell") as! NewChatFltrCntctGroupTableViewCell
                
                let currentSearch_GroupArray : GroupDetail = searchGroupArr[indexPath.row] as! GroupDetail
                searchCell.nameLbl.setNameTxt(currentSearch_GroupArray.id, "group")
                searchCell.img_View.setProfilePic(currentSearch_GroupArray.id, "group")
                searchCell.img_View.layer.cornerRadius =  searchCell.img_View.frame.size.width/2
                searchCell.img_View.clipsToBounds=true
                var nameColl:String = String()
                for i in 0..<currentSearch_GroupArray.groupUsers.count{
                    let getVal = currentSearch_GroupArray.groupUsers[i] as! NSDictionary
                    // print(getVal["ContactName"])
                    let name = getVal["ContactName"] as! String
                    if i != 0{
                        nameColl.append(",")
                    }
                    nameColl.append(name)
                    
                    searchCell.statusLbl.text = nameColl
                }
                return searchCell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data_Source.itemAtIndexPath(indexPath) as? String
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if title == UITableView.indexSearch {
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
            return NSNotFound
        } else {
            let sectionIndex = hasSearchIndex ? index - 1 : index
            return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: sectionIndex)
        }
    }
    
    func enterToChat(id:String,type:String,indexpath:IndexPath){
        self.searchController.dismissView(animated:true, completion:nil)
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let favRecord:FavRecord = self.favArray.object(at: indexpath.row) as! FavRecord
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = favRecord.id
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.isActive = false
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchActive == false {
            let DataArr=data_Source.returnFavArr()[indexPath.section] as! NSMutableArray
            if(DataArr.count > 0)
            {
                
                let favRecord:FavRecord=DataArr.object(at: indexPath.row) as! FavRecord
                if(favRecord.name == ""){
                    favRecord.name = favRecord.msisdn
                }
                let chatLocked = Themes.sharedInstance.isChatLocked(id: favRecord.id, type: "single")
                if(chatLocked == true){
                    self.enterToChat(id: favRecord.id, type: "single", indexpath: indexPath)
                }else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = favRecord.id;
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    searchController.dismissView(animated: true, completion: nil);
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
                
            }
        }
        else{
            if(searchArray.count > 0)
            {
                
                let favRecord:FavRecord=searchArray[indexPath.row] as! FavRecord
                
                let chatLocked = Themes.sharedInstance.isChatLocked(id: favRecord.id, type: "single")
                if(chatLocked == true){
                    self.enterToChat(id: favRecord.id, type: "single", indexpath: indexPath)
                }else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = favRecord.id;
                    searchController.dismissView(animated: true, completion: nil);
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
                
            }
        }
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles = UILocalizedIndexedCollation.current().sectionIndexTitles
        if hasSearchIndex {
            titles.insert(UITableView.indexSearch, at: 0)
        }
        return titles
    }
    
    // MARK: - TableViewIndex
    
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        var items = UILocalizedIndexedCollation.current().sectionIndexTitles.map{ title -> UIView in
            return StringItem(text: title)
        }
        if hasSearchIndex {
            
            items.insert(SearchItem(), at: 0)
            
        }
        return items
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) {
        
        if item is SearchItem {
            
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
            
        } else {
            
            let sectionIndex = hasSearchIndex ? index - 1 : index
            let rowCount = tableView.numberOfRows(inSection: sectionIndex)
            let indexPath = IndexPath(row: rowCount > 0 ? 0 : NSNotFound, section: sectionIndex)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            
        }
        
    }
    
    
    
    func getFavContacts(){
        let predicate = NSPredicate(format: "is_fav != %@", "2")
        let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
        if(CheckFav.count > 0)
        {
            let FavArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
            if(FavArr.count > 0)
            {
                for i in 0 ..< FavArr.count {
                    let ResponseDict = FavArr[i] as! NSManagedObject
                    let favRecord:FavRecord=FavRecord()
                    favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                    favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                    favRecord.phnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber"))
                    favArray.add(favRecord)
                }
                
            }
            
        }
        getGroupList()
    }
    
    func getGroupList(){
                
        let groupinfoArr:NSArray=DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: Constant.sharedinstance.Group_details)
        
        if groupinfoArr.count>0{
            
            for i in 0..<groupinfoArr.count
            {
                let ReponseDict=groupinfoArr[i] as! NSManagedObject
                let GroupDetailRec:GroupDetail=GroupDetail()
                GroupDetailRec.displayName=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "displayName") as! String)
                GroupDetailRec.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "id") as! String)
                GroupDetailRec.displayavatar=Themes.sharedInstance.CheckNullvalue(Passed_value:  ReponseDict.value(forKey: "displayavatar") as! String )
                
                
                let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                if(groupData != nil)
                {
                    GroupDetailRec.groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                }
                GroupDetailRec.Group_userid=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "id") as! String)
                GroupDetailRec.TimeStamp=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp") as! String)
                GroupDetailRec.is_archived=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "is_archived") as! String)
                GroupDetailRec.is_marked=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "is_marked") as! String)
                GroupDetailRec.isAdmin=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "isAdmin") as! String)
                GroupDetailRec.msg=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "msg") as! String)
                groupListArray.add(GroupDetailRec)
            }
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // searchController.responds(to: )
        // searchController.dimsBackgroundDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchActive = true
        if (searchController.searchBar.text?.count)! > 0 {
            searchActive = true
            searchArray.removeAll(keepingCapacity: false)
            searchGroupArr.removeAll(keepingCapacity: false)
            
            
            let array = (favArray as NSArray).filter{(($0 as? FavRecord)?.name.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false)}
//            let namesBeginningWithLetterPredicate = NSPredicate(format: "(name BEGINSWITH[cd] $letter)")
//            let array = (favArray as NSArray).filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]))
            
            if array.count>0{
                
            }
            else{
                
//                let resultPredicate = NSPredicate(format: "phnumber  contains[c] %@",searchController.searchBar.text!)
                _ =   (favArray as NSArray).filter{(($0 as? FavRecord)?.phnumber.contains(searchController.searchBar.text!) ?? false)}
            }
            
//            let searchPredicate = NSPredicate(format: "displayName contains[c]  %@", searchController.searchBar.text!)
            
            let groupFiltArray = (groupListArray as NSArray).filter{(($0 as? GroupDetail)?.displayName.contains(searchController.searchBar.text!) ?? false)}
            
            searchArray = array as! [NSObject]
            searchGroupArr = groupFiltArray as! [NSObject]
            tableView.reloadData()
            
        }
        else {
            searchActive = false
            tableView.reloadData()
        }
        
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Keyboard
    
    func handleKeyboardNotification(_ note: Notification){
        
        guard let userInfo = note.userInfo else {
            return
        }
        
        if let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            
            _ = view.convert(frame, from: nil)
            
            UIView.animate(withDuration: duration, animations: {
                UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: curve)!)
                //                tableView.frame = convertedFrame
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    // MARK: - Helpers
    
    fileprivate func setNativeIndexHidden(_ hidden: Bool) {
        tableView.sectionIndexColor = hidden ? UIColor.clear : nil
        tableView.sectionIndexBackgroundColor = hidden ? UIColor.clear : nil
        tableView.sectionIndexTrackingBackgroundColor = hidden ? UIColor.clear : nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    
    
    @IBAction func DidclickBack(_ sender: UIButton) {
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.pop(animated: true)
        self.searchController.view.removeFromSuperview()
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.handleKeyboardNotification(notify)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.handleKeyboardNotification(notify)
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
