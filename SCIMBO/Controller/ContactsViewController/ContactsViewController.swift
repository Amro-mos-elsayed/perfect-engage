//
//  ContactsViewController.swift
//
//
//  Created by CASPERON on 16/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import JSSAlertView
import Social
import MessageUI

protocol contactShare : class {
    func share(rec:NSMutableArray)
    func setBool(view:Bool)
}

class ContactsViewController:  UIViewController,TableViewIndexDelegate,TableViewIndexDataSource,ExampleContainer,UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate, UISearchResultsUpdating,CNContactViewControllerDelegate,UISearchBarDelegate{
    
    var example: Example!
    fileprivate var hasSearchIndex = true
    fileprivate var data_Source: DataSource!
    fileprivate var indexDataSource: TableViewIndexDataSource!
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    weak var delegate: contactShare!
    @IBOutlet weak var table_bottom: NSLayoutConstraint!
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    @IBOutlet weak var contacts_TblView:UITableView!
    @IBOutlet weak var contactsLbl:UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var baseheight: NSLayoutConstraint!
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var goback: UIButton!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var is_from_group:Bool = false
    var multiple_contacts:NSMutableArray = NSMutableArray()
    var contacts_ArrObj = [Contact_add]()
    var favContacts_ArrObj = [Favourite_Contact]()
    var searchArray = [FilterContact]()
    var searchActive:Bool = false
    var oppponent_id:String = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        ContactHandler.sharedInstance.GetPermission()
        ContactHandler.sharedInstance.getPhoneContact()

        showPhoneContactsPermissionIfneeded()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        searchActive = false
        searchController.delegate=self
        searchController.searchBar.delegate=self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        if let exampleType = ExampleType(rawValue: "comparison") {
            example = exampleByType(exampleType)
        }
        let nib = UINib(nibName: "ContactsTableViewCell", bundle: nil)
        contacts_TblView.register(nib, forCellReuseIdentifier: "ContactsTableViewCell")
        setNativeIndexHidden(true)
        contacts_TblView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let bottomBorder = CALayer()
        let bottomWidth = CGFloat(2.0)
        bottomBorder.borderColor = UIColor.blue.cgColor
        bottomBorder.frame = CGRect(x: 0, y:  bottomView.frame.minY+4, width: contacts_TblView.frame.size.width, height: 1)
        bottomBorder.borderWidth = bottomWidth
        bottomView.layer.addSublayer(bottomBorder)
        bottomView.layer.masksToBounds = true
        bottomView.isHidden = true //false
        goback.isHidden = false
        contactsLbl.text = "Select Contacts".localized()
    }
    
    func showPhoneContactsPermissionIfneeded() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
    }
    @IBAction func go_backAct(_ sender: UIButton) {
        searchController.dismissView(animated:true, completion:nil)
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.navigationController?.pop(animated:true)
    }
    
    @IBAction func share_contact(_ sender: UIButton) {
        
        self.delegate.share(rec:self.multiple_contacts)
        self.delegate.setBool(view: true)
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.pop(animated: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if(data_Source != nil)
        {
            data_Source.initwithData()
        }

    }
    
    func getContacts(){
        
        let contactsArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [Contact_add]
        contacts_ArrObj = contactsArray
        getFavContacts()
    }
    
    
    
    func getFavContacts(){
        
        favContacts_ArrObj = []
        let Predicate:NSPredicate = NSPredicate(format: "is_fav != 2")
        let favContacts_Array = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: Predicate, Limit: 0) as! [Favourite_Contact]
        favContacts_ArrObj = favContacts_Array
        filterContact()
        contacts_TblView.reloadData()
    }
    
    func filterContact(){
        
        filter_ContactRec = []
        if(contacts_ArrObj.count>0)
        {
            for i in 0..<contacts_ArrObj.count{
                var checkVal = "Not Exits"
                let getCon_PhNo = Themes.sharedInstance.CheckNullvalue(Passed_value: contacts_ArrObj[i].contact_mobilenum)
                for j in 0..<favContacts_ArrObj.count{
                    
                    let getFav_PhNo = Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].phnumber)
                    let getFav_PhNoMsisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].msisdn)
                    
                    if  getFav_PhNo  == getCon_PhNo || getFav_PhNoMsisdn == getCon_PhNo {
                        
                        let filterContactObj = FilterContact(name: Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].name),
                                                             id: Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].id),
                                                             status: Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].status),
                                                             phoneNo: Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].phnumber),
                                                             profile: Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].profilepic),
                                                             msisdn: Themes.sharedInstance.CheckNullvalue(Passed_value: favContacts_ArrObj[j].msisdn))
                        filter_ContactRec.add(filterContactObj)
                        checkVal = "Value Exits"
                    }
                }
                if(getCon_PhNo.count >= 10 && Themes.sharedInstance.GetMyPhonenumber().contains(getCon_PhNo)) {
                    let filterContactObj = FilterContact(name: Themes.sharedInstance.CheckNullvalue(Passed_value: contacts_ArrObj[i].contact_name),
                                                         id: Themes.sharedInstance.Getuser_id(),
                                                         status: Themes.sharedInstance.setStatusTxt(Themes.sharedInstance.Getuser_id()),
                                                         phoneNo: Themes.sharedInstance.GetMyPhonenumber(),
                                                         profile: Themes.sharedInstance.setProfilePic(Themes.sharedInstance.Getuser_id(), "single"),
                                                         msisdn: Themes.sharedInstance.GetMyPhonenumber())
                    filter_ContactRec.add(filterContactObj)
                    checkVal = "Value Exits"
                }
                if checkVal == "Not Exits"{
                    
                    let filterContactObj = FilterContact(name: Themes.sharedInstance.CheckNullvalue(Passed_value: contacts_ArrObj[i].contact_name),
                                                         id: "",
                                                         status: "",
                                                         phoneNo: Themes.sharedInstance.CheckNullvalue(Passed_value: contacts_ArrObj[i].contact_mobilenum),
                                                         profile: "",
                                                         msisdn: "")
                    filter_ContactRec.add(filterContactObj)
                    
                }
            }
            if let exampleType = ExampleType(rawValue: "comparison") {
                example = exampleByType(exampleType)
            }
            
            hasSearchIndex = example.hasSearchIndex
            indexDataSource = example.indexDataSource
            data_Source = example.dataSource
            CheckBool = false
            
            data_Source.initwithData()
            tableViewIndex.delegate = self
            tableViewIndex.dataSource = self
            contacts_TblView.tableHeaderView = searchController.searchBar
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchActive == true{
            return 1
        }
        
        if contacts_ArrObj.count == 0{
            return 0
        }
        
        return data_Source.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if (data_Source.numberOfItemsInSection(section) == 0)
        {
            return nil
        }
        
        if searchActive == true{
            return ""
        }
        
        if contacts_ArrObj.count == 0{
            return ""
        }
        
        return data_Source.titleForHeaderInSection(section)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == true{
            return searchArray.count
        }
        if  contacts_ArrObj.count == 0{
            return 18
        }
        return data_Source.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        
        if searchActive == true{
            let currentSearchArray = searchArray[indexPath.row]
            cell.name_Lbl.text = Themes.sharedInstance.setNameTxt(currentSearchArray.id, "single") == "" ? (currentSearchArray.name == "" ? currentSearchArray.phoneNo.parseNumber : currentSearchArray.name) : Themes.sharedInstance.setNameTxt(currentSearchArray.id, "single")
            cell.user_ImageView.setProfilePic(currentSearchArray.id, "single")
            cell.status_Lbl.setStatusTxt(currentSearchArray.id)
            cell.status_Lbl.isHidden = cell.status_Lbl.text == "" ? true : false
            cell.phone_Lbl.text = currentSearchArray.phoneNo
            cell.phone_Lbl.isHidden = currentSearchArray.name == ""
            return cell
        }
        if  contacts_ArrObj.count == 0{
            
            if indexPath.row == 4{
                cell.name_Lbl.textAlignment = .center
                cell.name_Lbl.text = "No Contacts"
            }
            else{
                cell.name_Lbl.text = ""
            }
            return cell
        }
        
        let getFilterVal:FilterContact = data_Source.itemAtIndexPathFilter(indexPath) as!  FilterContact
        let phoneNo = getFilterVal.phoneNo
        cell.name_Lbl.text = Themes.sharedInstance.setNameTxt(getFilterVal.id, "single") == "" ? (getFilterVal.name == "" ? getFilterVal.phoneNo.parseNumber : getFilterVal.name) : Themes.sharedInstance.setNameTxt(getFilterVal.id, "single")
        cell.user_ImageView.setProfilePic(getFilterVal.id, "single")
        cell.status_Lbl.setStatusTxt(getFilterVal.id)
        cell.status_Lbl.isHidden = cell.status_Lbl.text == "" ? true : false
        cell.phone_Lbl.text = phoneNo
        cell.phone_Lbl.isHidden = getFilterVal.name == ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if(searchActive == true) {
            let currentSearchArray = searchArray[indexPath.row]
            let favRecord:FavRecord=FavRecord()
            favRecord.name=currentSearchArray.name
            favRecord.id = currentSearchArray.id == "" ? (is_from_group ? Themes.sharedInstance.Getuser_id() : oppponent_id) : currentSearchArray.id
            favRecord.profilepic = currentSearchArray.profile == "" ? "nil" : currentSearchArray.profile
            favRecord.phnumber = currentSearchArray.phoneNo
            favRecord.status = currentSearchArray.status
            favRecord.msisdn = currentSearchArray.msisdn
            multiple_contacts.add(favRecord)

        }
        else {
            let getFilterVal:FilterContact = data_Source.itemAtIndexPathFilter(indexPath) as!  FilterContact
            let favRecord:FavRecord=FavRecord()
            favRecord.name=getFilterVal.name
            favRecord.id = getFilterVal.id == "" ? (is_from_group ? Themes.sharedInstance.Getuser_id() : oppponent_id) : getFilterVal.id
            favRecord.profilepic = getFilterVal.profile == "" ? "nil" : getFilterVal.profile
            favRecord.phnumber = getFilterVal.phoneNo
            favRecord.status = getFilterVal.status
            favRecord.msisdn = getFilterVal.msisdn
            multiple_contacts.add(favRecord)
        }
        self.delegate.setBool(view: true)
        self.delegate.share(rec: multiple_contacts)
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        self.pop(animated: true)
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
            contacts_TblView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
        } else {
            let sectionIndex = hasSearchIndex ? index - 1 : index
            
            let rowCount = contacts_TblView.numberOfRows(inSection: sectionIndex)
            let indexPath = IndexPath(row: rowCount > 0 ? 0 : NSNotFound, section: sectionIndex)
            contacts_TblView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(self.contactsReceivedNotification(notification:)), name: NSNotification.Name(rawValue: Constant.sharedinstance.contactPermissionIsGiven), object: nil)

        super.viewWillAppear(animated)
    }
    
    @objc func contactsReceivedNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.getContacts()
        }
    }
    
    fileprivate func setNativeIndexHidden(_ hidden: Bool) {
        
        contacts_TblView.sectionIndexColor = hidden ? UIColor.clear : nil
        contacts_TblView.sectionIndexBackgroundColor = hidden ? UIColor.clear : nil
        contacts_TblView.sectionIndexTrackingBackgroundColor = hidden ? UIColor.clear : nil
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchActive = true
        
        if (searchController.searchBar.text?.isEmpty == false) {
            searchActive = true
            searchArray.removeAll(keepingCapacity: false)
            let searchTxt = searchController.searchBar.text?.lowercased()
            let array = (filter_ContactRec as! [FilterContact]).filter({($0.name.lowercased()).contains(searchTxt!)})

            if(searchController.searchBar.text! == ""){
                searchActive = false
            }
            searchArray = array
            contacts_TblView.reloadData()
        }
        else {
            searchActive = false
            contacts_TblView.reloadData()
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        let cc = 44
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        viewController.dismissView(animated: true, completion: nil)
    }
    
    @IBAction func DidclickContact(_ sender: Any) {
        if(ContactHandler.sharedInstance.checkPhoneContactsPermission())
        {
            let controller = CNContactViewController(forNewContact: nil)
            controller.delegate = self
            let navigationController = UINavigationController(rootViewController: controller)
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.presentView(navigationController, animated: true)
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
    }
}



