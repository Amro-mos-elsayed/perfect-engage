//
//  NewGroupViewController.swift
//
//
//  Created by CASPERON on 30/01/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView


protocol NewGroupViewControllerDelegate : class {
    func Privacy_Update(_ records : [NewGroupAdd],_ isExceptContact : Bool)
}


class NewGroupViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,LoadTableView{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var tableViewTopView_Ratio: NSLayoutConstraint!
    @IBOutlet weak var collection_View: UICollectionView!
    @IBOutlet weak var newGroup_TableView: UITableView!
    var tagArray:NSMutableArray = NSMutableArray()
    var getId:String = String()
    var  getBoolVal:Bool!
    var collectionImageArray:NSMutableArray = NSMutableArray()
    var searchActive:Bool = false
    // var contactRec : [NewGroup1] = []
    //    var searchArray = [String]()
    var searchArray = [NSObject]()
    var imageArryObj = [NSObject]()
    // var contactRec = Array<NewGroup1>()
    //var searchArray = [AnyObject]()
    var checkString:String = String()
    var checkTable:String = String()
    var searchText:String = String()
    var fromAddParticipant : Bool = Bool()
    var GroupDetailRec:GroupDetail=GroupDetail()
    var fromStatusPrivacy : Bool = Bool()
    var isExceptContact : Bool = Bool()
    weak var delegate : NewGroupViewControllerDelegate?
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        let nibName = UINib(nibName: "NewGroupTableViewCell", bundle: nil)
        self.newGroup_TableView.register(nibName, forCellReuseIdentifier: "NewGroupTableViewCell")
        print(newGroup.contactName_Array.count)
        print(newGroup.imageData_Array.count)
        checkString = "uncheck"
        addObj()
        if(fromStatusPrivacy)
        {
            nextBtn.setTitle("Done", for: .normal)
            if(isExceptContact)
            {
                TitleLabel.text = "My Contacts Except..."
            }
            else
            {
                TitleLabel.text = "Only Share With..."
            }
        }
        else
        {
            nextBtn.setTitle(NSLocalizedString("Next", comment:"Next"), for: .normal)
            TitleLabel.text = NSLocalizedString("Add Participant", comment:"Add Participant")
        }
        nextBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        self.newGroup_TableView.delegate = self
        self.newGroup_TableView.dataSource = self
        searchActive = false
        searchBar.delegate  = self
    }
    
    func updateGroupInfo()
    {
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        self.pop(animated: true);
    }
    
    func addObj(){
        if(fromAddParticipant)
        {
            nextBtn.isHidden = true
            contactRec.removeAllObjects()
            let groupFavArr : NSArray =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: "\(Constant.sharedinstance.Group_details)", attribute: "id", FetchString: self.GroupDetailRec.id, SortDescriptor: nil) as! NSArray
            
            let userIds = NSMutableArray()
            for index in groupFavArr
            {
                var usersList = NSArray()
                let ResponseDict = index as! NSManagedObject
                let groupData:NSData?=ResponseDict.value(forKey: "groupUsers") as? NSData
                if(groupData != nil)
                {
                    usersList = NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                }
                for user in usersList{
                    let getVal = user as! NSDictionary
                    if(getVal["id"] as! String != Themes.sharedInstance.Getuser_id())
                    {
                        userIds.add(getVal["id"] as! String)
                    }
                }
                
            }
            let duplicateCheck  = NSMutableArray()
            let predicate = NSPredicate(format: "is_fav != %@", "2")
            let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
            if(CheckFav.count > 0)
            {
                let predicate1 = NSPredicate(format: "user_id == %@", Themes.sharedInstance.Getuser_id())
                let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate1])
                let FavArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: compound, Limit: 0) as! NSArray
                if(FavArr.count > 0)
                {
                    for i in 0 ..< FavArr.count {
                        let ResponseDict = FavArr[i] as! NSManagedObject
                        if(!userIds.contains(ResponseDict.value(forKey: "id") as! NSString))
                        {
                            let id:NSString = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")) as NSString
                            let newContactObject = NewGroupAdd(name: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")) as NSString, phoneNo: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber")) as NSString, image:  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic")) as NSString ,bool:false,id:id)
                            if(id as String != Themes.sharedInstance.Getuser_id())
                            {
                                if(!duplicateCheck.contains(id))
                                {
                                    duplicateCheck.add(id)
                                    contactRec.add(newContactObject)
                                }
                            }
                        }
                    }
                    
                }
                
            }
        }
        else
        {
            contactRec.removeAllObjects()
            let duplicateCheck  = NSMutableArray()
            let predicate = NSPredicate(format: "is_fav != %@", "2")
            let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
            if(CheckFav.count > 0)
            {
                let predicate1 = NSPredicate(format: "user_id == %@", Themes.sharedInstance.Getuser_id())
                let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate1])
                let FavArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: compound, Limit: 0) as! NSArray
                if(FavArr.count > 0)
                {
                    for i in 0 ..< FavArr.count {
                        let ResponseDict = FavArr[i] as! NSManagedObject
                        let id:NSString = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")) as NSString
                        
                        var newContactObject : NewGroupAdd?
                        
                        if(fromStatusPrivacy)
                        {
                            if(isExceptContact)
                            {
                                var isSelected = false
                                let FetchUserArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
                                if(FetchUserArr.count > 0)
                                {
                                    let userObj : NSManagedObject = FetchUserArr[0] as! NSManagedObject
                                    let viewedArray = userObj.value(forKey: "status_except")
                                    if(viewedArray != nil)
                                    {
                                        if((viewedArray as! NSArray).contains(id))
                                        {
                                            isSelected = true
                                        }
                                        
                                    }
                                }
                                
                                newContactObject = NewGroupAdd(name: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")) as NSString, phoneNo: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber")) as NSString, image:  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic")) as NSString ,bool:isSelected,id:Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")) as NSString)
                                
                            }
                            else
                            {
                                
                                var isSelected = false
                                let FetchUserArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
                                if(FetchUserArr.count > 0)
                                {
                                    let userObj : NSManagedObject = FetchUserArr[0] as! NSManagedObject
                                    let viewedArray = userObj.value(forKey: "status_only_with")
                                    if(viewedArray != nil)
                                    {
                                        if((viewedArray as! NSArray).contains(id))
                                        {
                                            isSelected = true
                                        }
                                        
                                    }
                                }
                                newContactObject = NewGroupAdd(name: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")) as NSString, phoneNo: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber")) as NSString, image:  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic")) as NSString ,bool:isSelected,id:Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")) as NSString)
                            }
                        }
                        else
                        {
                            newContactObject = NewGroupAdd(name: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")) as NSString, phoneNo: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber")) as NSString, image:  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic")) as NSString ,bool:false,id:Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")) as NSString)
                            
                        }
                        if(id as String != Themes.sharedInstance.Getuser_id())
                        {
                            if(!duplicateCheck.contains(id))
                            {
                                duplicateCheck.add(id)
                                contactRec.add(newContactObject!)
                            }
                        }
                        
                        
                    }
                    
                }
                
            }
            
        }
        newGroup_TableView.reloadData()
        getImageArray()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == true{
            if(searchArray.count > 0)
            {
                return searchArray.count
            }else if(contactRec.count > 0 && searchText == ""){
                return contactRec.count
            }
            else
            {
                return 1;
            }
        }
        else
        {
            if(contactRec.count > 0)
            {
                return contactRec.count
            }
            else
            {
                return 1;
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NewGroupTableViewCell = newGroup_TableView.dequeueReusableCell(withIdentifier: "NewGroupTableViewCell") as! NewGroupTableViewCell
        cell.contact_Image.image = nil
        if searchActive == true{
            if(searchArray.count > 0)
            {
                let currentSearchArray : NewGroupAdd = searchArray[indexPath.row] as! NewGroupAdd
                cell.name_Lbl_Cell.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: currentSearchArray.id), "single")
                cell.contact_Image.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: currentSearchArray.id), "single")
                cell.contact_Image.layer.cornerRadius=cell.contact_Image.frame.size.width/2
                cell.contact_Image.clipsToBounds=true
                let getid = currentSearchArray.id as String
                getBoolVal = phoneNoPredicate(ID: getid)
            }else if(searchText == ""){
                let contactRecArray : NewGroupAdd = contactRec[indexPath.row] as! NewGroupAdd
                
                cell.name_Lbl_Cell.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: contactRecArray.id), "single")
                cell.contact_Image.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: contactRecArray.id), "single")
                cell.contact_Image.layer.cornerRadius=cell.contact_Image.frame.size.width/2
                cell.contact_Image.clipsToBounds=true
                let getid = contactRecArray.id as String
                getBoolVal = phoneNoPredicate(ID: getid)
            }
            else if(searchText == "nil")
            {
                let cell : UITableViewCell = UITableViewCell.init(style: UITableViewCell.CellStyle.default , reuseIdentifier: "Cell")
                cell.textLabel?.text = "No Contacts"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            }
        }
        else{
            if(contactRec.count > 0)
            {
                let contactRecArray : NewGroupAdd = contactRec[indexPath.row] as! NewGroupAdd
                cell.name_Lbl_Cell.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: contactRecArray.id), "single")
                cell.contact_Image.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: contactRecArray.id), "single")
                cell.contact_Image.layer.cornerRadius=cell.contact_Image.frame.size.width/2
                cell.contact_Image.clipsToBounds=true
                let getid = contactRecArray.id as String
                getBoolVal = phoneNoPredicate(ID: getid)
                
            }
            else
            {
                let cell : UITableViewCell = UITableViewCell.init(style: UITableViewCell.CellStyle.default , reuseIdentifier: "Cell")
                cell.textLabel?.text = "No Contacts"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            }
            
        }
        
        if getBoolVal == true{
            
            if(isExceptContact)
            {
                cell.check_Btn.setImage(#imageLiteral(resourceName: "cross"), for: UIControl.State.normal)
            }
            else
            {
                cell.check_Btn.setImage(#imageLiteral(resourceName: "roundtick"), for: UIControl.State.normal)
            }
            return cell
        }
        else{
            
            cell.check_Btn.setImage(#imageLiteral(resourceName: "uncheckround"), for: UIControl.State.normal)
        }
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = ""
        //let getRec : NewGroup1 = contactRec[indexPath.row] as! NewGroup1
        var personName:String = ""
        if searchActive == true{
            if(searchArray.count > 0)
            {
                searchActive = false
                searchBar.resignFirstResponder()
                let currentSearchAry : NewGroupAdd = searchArray[indexPath.row] as! NewGroupAdd
                personName = currentSearchAry.name as String
                getId = currentSearchAry.id as String
                changeSelecFrmSearch(ID: getId)
            }
            
        }
        else{
            if(contactRec.count > 0)
            {
                let getBoolVal = (contactRec[indexPath.row] as! NewGroupAdd).isSelect
                
                if getBoolVal ==  true{
                    
                    (contactRec[indexPath.row] as! NewGroupAdd).isSelect = false
                }
                else{
                    (contactRec[indexPath.row] as! NewGroupAdd).isSelect  = true
                    
                }
                personName = (contactRec[indexPath.row] as! NewGroupAdd).name as String
                
                newGroup_TableView.reloadData()
                getImageArray()
            }
            
        }
        
        if(fromAddParticipant)
        {
            if imageArryObj.count != 0{
                
                
                let alertview = JSSAlertView().show(
                    self,
                    title: Themes.sharedInstance.GetAppname(),
                    text: "Add \(personName) to \"\(GroupDetailRec.displayName)\" group?",
                    buttonText: "Ok".localized(),
                    cancelButtonText: "Cancel".localized(),
                    color: CustomColor.sharedInstance.themeColor
                )
                alertview.addAction {
                    for person in contactRec
                    {
                        if((person as! NewGroupAdd).isSelect == true)
                        {
                            var timestamp:String =  String(Date().ticks)
                            var servertimeStr:String = Themes.sharedInstance.getServerTime()
                            
                            if(servertimeStr == "")
                            {
                                servertimeStr = "0"
                            }
                            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                            let add_id : String = (person as! NewGroupAdd).id as String
                            let from : String = Themes.sharedInstance.Getuser_id()
                            let param = ["groupType" : "5", "from" : from, "id" : timestamp, "groupId" : Themes.sharedInstance.CheckNullvalue(Passed_value:self.GroupDetailRec.id),"newuser" :add_id] as [String : Any];
                            Themes.sharedInstance.activityView(View: self.view)
                            SocketIOManager.sharedInstance.Groupevent(param: param)
                        }
                        
                    }
                }
                alertview.addCancelAction {
                    self.pop(animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if  imageArryObj.count != 0{
            self.tableViewTopView_Ratio.constant = self.collection_View.frame.height+6
            
            self.nextBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        else{
            self.tableViewTopView_Ratio.constant = 0
            self.nextBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        }
        
        return imageArryObj.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //  let collection_Cell:NewGroupCollectionViewCell = collection_View.dequeueReusableCell(withIdentifier: "NewGroupCollectionViewCell") as! NewGroupCollectionViewCell
        
        let collection_Cell = collection_View.dequeueReusableCell(withReuseIdentifier: "NewGroupCollectionViewCell", for: indexPath as IndexPath) as! NewGroupCollectionViewCell
        collection_Cell.delete_Button.tag = indexPath.row
        collection_Cell.delete_Button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        let contactRecImage : NewGroupAdd = imageArryObj[indexPath.row] as! NewGroupAdd
        collection_Cell.imageView.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: contactRecImage.id), "single")
        collection_Cell.name_lbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: contactRecImage.id), "single")
        collection_Cell.imageView.layer.cornerRadius=collection_Cell.imageView.frame.size.width/2
        collection_Cell.imageView.clipsToBounds=true
        self.collection_View?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        return collection_Cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    
    
    @objc func deleteAction(sender:UIButton){
        
        searchActive = false
        let getObj = imageArryObj[sender.tag] as! NewGroupAdd
        getId = getObj.id as String
        imageArryObj.remove(at: sender.tag)
        if imageArryObj.count == 0{
            self.nextBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        }
        else{
            self.nextBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        collection_View.reloadData()
        changeSelecFrmColl(ID: getId, from: "self")
        
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.pop(animated: true)
    }
    
    @IBAction func NextBtn_Action(_ sender: UIButton) {
        
        
        if imageArryObj.count != 0{
            if(fromStatusPrivacy)
            {
                if(isExceptContact)
                {
                    self.delegate?.Privacy_Update(imageArryObj as! [NewGroupAdd], true)
                }
                else
                {
                    self.delegate?.Privacy_Update(imageArryObj as! [NewGroupAdd], false)
                }
                self.pop(animated: true)
            }
            else
            {
                let setNameVC = storyboard?.instantiateViewController(withIdentifier:"NewGroupSetNameViewController" ) as! NewGroupSetNameViewController
                setNameVC.collectionArray = imageArryObj
                setNameVC.tagCpyArry = tagArray
                setNameVC.delegate = self
                self.pushView(setNameVC, animated: true)
                
            }
        }
    }
    
    
    func getImageArray(){
        imageArryObj.removeAll()
        for j  in  0..<contactRec.count{
            
            let currentSearchArray : NewGroupAdd = contactRec[j] as! NewGroupAdd
            
            let getID = currentSearchArray.id as String
            
            getBoolVal = phoneNoPredicate(ID:getID )
            if getBoolVal == true{
                self.imageArryObj.append(contactRec[j] as! NewGroupAdd)
                // collectionImageArray.add(currentSearchArray.image)
                
            }
            else{
                
                
            }
            
        }
        if imageArryObj.count != 0{
            UIView.animate(withDuration: 6, animations: {
                
                self.tableViewTopView_Ratio.constant = self.collection_View.frame.height+6
                self.view.updateConstraintsIfNeeded()
                
                //  tableView.frame.origin.y = self.collection_View.frame.origin.y + self.collection_View.frame.height
                
            })
        }
        else{
            UIView.animate(withDuration: 6, animations: {
                
                self.tableViewTopView_Ratio.constant = 0
                self.view.updateConstraintsIfNeeded()
                
                //  tableView.frame.origin.y = self.collection_View.frame.origin.y + self.collection_View.frame.height
                
            })
        }
        
        collection_View.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText != ""){
            searchActive = true
            searchArray.removeAll(keepingCapacity: false)
            checkTable = "changeTblView"
            
//            let resultPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            
            let array = (contactRec as NSArray).filter{(($0 as? NewGroupAdd)?.name.contains(searchText) ?? false)}
//            filtered(using: resultPredicate)
            searchArray = array as! [NSObject]
            if(searchArray.count == 0){
                self.searchText = "nil"
            }
            newGroup_TableView.reloadData()
        }else{
            searchActive = false
            newGroup_TableView.reloadData()
        }
    }
    
    //    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    //        searchActive = true
    //        searchArray.removeAll(keepingCapacity: false)
    //        checkTable = "changeTblView"
    //        let NewText = (searchBar.text! as NSString).replacingCharacters(in: range, with:text)
    //        print(NewText)
    //        searchText = NewText
    //        let range = (NewText as String).startIndex ..< (NewText as String).endIndex
    //        var searchString = String()
    //        (NewText as String).enumerateSubstrings(in: range, options: .byComposedCharacterSequences,{(substring, substringRange, enclosingRange, success) in
    //            searchString.append(substring!)
    //                     })
    //         let resultPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
    //        let array =   (contactRec as NSArray).filtered(using: resultPredicate)
    //         searchArray = array as! [NSObject]
    //        newGroup_TableView.reloadData()
    //        return true
    //
    //    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchActive = false
            
        }
        self.view.endEditing(true)
        newGroup_TableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchActive = false
        }
        self.view.endEditing(true)
        newGroup_TableView.reloadData()
    }
    
    func phoneNoPredicate(ID:String) -> Bool
    {
//        let resultPredicates = NSPredicate(format: "id CONTAINS[c] %@", ID)
        let getObjectArray =  contactRec.filter{($0 as? NewGroupAdd != nil)}.map{($0 as! NewGroupAdd)}.filter{($0.id as String == ID)}
//        let getObjectArray =  (contactRec as NSArray).filtered(using: resultPredicates)
//        var IDArray = [NSObject]()
//        IDArray = getObjectArray as [NSObject]
        let newGroupObj:NewGroupAdd = getObjectArray[0]
        let getBoolVal = newGroupObj.isSelect as Bool
        if getBoolVal == false
        {
            return false
        }
        else
        {
            return true
        }
    }
    func changeSelecFrmColl(ID:String ,from:String){
        for e in 0..<contactRec.count{
            let currentSearchArray : NewGroupAdd = contactRec[e] as! NewGroupAdd
            let get_id = currentSearchArray.id as String
            if ID == get_id
            {
                (contactRec[e] as! NewGroupAdd).isSelect = false
            }
            else
            {
                
            }
        }
        if imageArryObj.count != 0
        {
            UIView.animate(withDuration: 6, animations:
                {
                    self.tableViewTopView_Ratio.constant = self.collection_View.frame.height+6
                    self.view.updateConstraintsIfNeeded()
            })
        }
        else
        {
            UIView.animate(withDuration: 6, animations: {
                self.tableViewTopView_Ratio.constant = 0
                self.view.updateConstraintsIfNeeded()
            })
        }
        if from == "self" {
            
        }
        else{
            removeImageObjArr(id: ID)
            // collection_View.reloadData()
        }
        newGroup_TableView.reloadData()
    }
    func removeImageObjArr(id:String){
        
        for q in 0..<imageArryObj.count{
            let currentSearchArry : NewGroupAdd = imageArryObj[q] as! NewGroupAdd
            let getid = currentSearchArry.id as String
            if id == getid{
                imageArryObj.remove(at: q)
                collection_View.reloadData()
                break
            }
            else
            {
                
            }
        }
    }
    func changeSelecFrmSearch(ID:String){
        
        
        for e in 0..<contactRec.count{
            
            let currentSearchArray : NewGroupAdd = contactRec[e] as! NewGroupAdd
            
            let getID = currentSearchArray.id as String
            if ID == getID{
                if currentSearchArray.isSelect == false{
                    (contactRec[e] as! NewGroupAdd).isSelect = true
                    
                }
                else{
                    (contactRec[e] as! NewGroupAdd).isSelect = false
                }
            }
            else{
                
            }
            
            
        }
        //        if imageArryObj.count != 0{
        //            UIView.animate(withDuration: 6, animations: {
        //
        //                self.tableViewTopView_Ratio.constant = self.collection_View.frame.height
        //                self.view.updateConstraintsIfNeeded()
        //
        //                //  tableView.frame.origin.y = self.collection_View.frame.origin.y + self.collection_View.frame.height
        //
        //            })
        //        }
        //        else{
        //            UIView.animate(withDuration: 6, animations: {
        //
        //                self.tableViewTopView_Ratio.constant = 0
        //                self.view.updateConstraintsIfNeeded()
        //
        //                //  tableView.frame.origin.y = self.collection_View.frame.origin.y + self.collection_View.frame.height
        //
        //            })
        //        }
        //
        newGroup_TableView.reloadData()
        getImageArray()
        
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        checkTable = "ReloadTagArry"
        newGroup.checkReldFrmSetName = "Reload"
        searchBar.text = ""
        searchActive = false
        newGroup_TableView.reloadData()
        //self.pop(animated: true)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchActive = false
        checkTable = "NochangeTblView"
        checkString = "uncheck"
        if newGroup.checkReldFrmSetName == "Reload"{
            print(imageArryObj)
            
            
            //            self.newGroup_TableView.reloadData()
            self.collection_View.reloadData()
        }
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchActive = false
        let cancelButtonAttributes: NSDictionary = [NSAttributedString.Key.foregroundColor: CustomColor.sharedInstance.themeColor]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [NSAttributedString.Key : AnyObject], for: UIControl.State.normal)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
        searchActive = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.updateGroupInfo_add), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.updateGroupInfo()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.collection_View.reloadData()
            weak.newGroup_TableView.reloadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}


