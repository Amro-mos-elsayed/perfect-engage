//
//  ContactHandler.swift
//
//
//  Created by Casp iOS on 28/01/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import Contacts
@objc  protocol ContactHandlerDelegate : class {
    @objc optional func callBackfavContact()
}

class ContactHandler: NSObject {
    weak var Delegate:ContactHandlerDelegate?
    static let sharedInstance = ContactHandler()
    var contactStore = CNContactStore()
    var PhonenumberArray:NSMutableArray=NSMutableArray()
    var OriginalPhonenumberArray:NSMutableArray=NSMutableArray()
    var ContactNameArr:NSMutableArray=NSMutableArray()
    var contactID_Array:NSMutableArray = NSMutableArray()
    var contactEmail_Array:NSMutableArray = NSMutableArray()
    var contactphone_Array:NSMutableArray = NSMutableArray()
    var contactAddress_Array:NSMutableArray = NSMutableArray()
    var contactDetails_Array:NSMutableArray = NSMutableArray()
    
    var contacts = [CNContact]()
    var callBack: ((Int, Bool)->Void)?
    var StorecontactInProgress : Bool = false
    
    var isRecent = false
    
    func GetPermission()
    {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async()
                    {
                }
                return
            }
        }
    }
    func savenonfavArr(ResponseDict:NSDictionary)
    {
        
        if(ResponseDict.count > 0)
        {
            let message:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "Status"))
            let name:String = "" //Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "Name"))
            let id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
            let msisdn:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
            var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "avatar"))
            
            let privacy = ResponseDict.value(forKey: "privacy") as! [String : String]
            let last_seen:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy["last_seen"])
            let profile_photo:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy["profile_photo"])
            let profile_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy["status"])
            
            if(image_Url != "")
            {
                if(image_Url.substring(to: 1) == ".")
                {
                    image_Url.remove(at: image_Url.startIndex)
                }
                image_Url = ImgUrl + image_Url
                
            }
            image_Url = image_Url == "" ? "photo" : image_Url
            let Checkfav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: id)
            if(!Checkfav)
            {
                if(id != Themes.sharedInstance.Getuser_id())
                {
                    let Dict:Dictionary = ["name":name,"countrycode":"","id":id,"is_add":"","msisdn":msisdn,"phnumber":msisdn,"profilepic":image_Url,"status":message,"user_id":Themes.sharedInstance.Getuser_id(),"is_fav":"2", "last_seen":last_seen, "profile_photo":profile_photo, "show_status":profile_status, "formatted" : msisdn.parseNumber]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Favourite_Contact)
                }
            }
            else
            {
                if(id != Themes.sharedInstance.Getuser_id())
                {
                    let Dict:Dictionary = ["name":name,"countrycode":"","id":id,"is_add":"","msisdn":msisdn,"phnumber":msisdn,"profilepic":image_Url,"status":message,"user_id":Themes.sharedInstance.Getuser_id(),"is_fav":"2", "last_seen":last_seen, "profile_photo":profile_photo, "show_status":profile_status, "formatted" : msisdn.parseNumber]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: id, attribute: "id", UpdationElements: Dict as NSDictionary)
                }
            }
        }
    }
    
    func EmitConvDetails(ConvDict:NSDictionary)
    {
        SocketIOManager.sharedInstance.EmitConvSetting(Dict: ConvDict)
    }
    
    func SaveFavContactFromServer(ResponseArr:NSArray, Index : Int)
    {
        let predicate = NSPredicate(format: "is_fav != %@", "2")
        let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
        if(ResponseArr.count > 0)
        {
            for i in 0..<ResponseArr.count
            {
                let FavDict:NSDictionary=ResponseArr[i] as! NSDictionary
                
                let contactPhno:String=Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "contactPhno"))
                let contactName:String=Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "contactName"))
                let PhnoPred = NSPredicate(format: "contact_mobilenum == %@", contactPhno)
                let NamePred = NSPredicate(format: "contact_name == %@", contactName)
                
                let ChangePred = NSPredicate(format: "is_changed == %@", "1")
                let isChangedPred = NSCompoundPredicate(andPredicateWithSubpredicates: [PhnoPred, NamePred, ChangePred])
                
                let checkRecentArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Contact_add, SortDescriptor: nil, predicate: isChangedPred, Limit: 0) as! NSArray
                if(checkRecentArr.count > 0)
                {
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Contact_add, FetchString: contactPhno, attribute: "contact_mobilenum", UpdationElements: ["is_changed" : "0"] as NSDictionary)
                }
                
                
                var name:String=String()
                var contact_ID:String = String()
                
                let Phonenumber:String=Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "PhNumber"))
                var msisdn: String = Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "msisdn"))
                let _id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "_id"))
                let status1:String = Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.value(forKey: "Status"))
                let privacy_dict:NSDictionary = FavDict.object(forKey: "privacy") as! NSDictionary
                let last_seen:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy_dict.value(forKey: "last_seen"))
                let profile_photo:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy_dict.value(forKey: "profile_photo"))
                let profile_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy_dict.value(forKey: "status"))
                let contactUserList : NSData =  NSData.init()
                
                let security_code:String = Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.value(forKey: "security_code"))
                
                if(_id == Themes.sharedInstance.Getuser_id()){
                    let param=["last_seen":last_seen,"profile_photo":profile_photo,"show_status":profile_status]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary)
                }
                
                if(CheckFav.count > 0)
                {
                    let predic3 = NSPredicate(format: "msisdn contains[c] %@", msisdn)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Favourite_Contact, Predicatefromat:predic3 , Deletestring: "1", AttributeName: "is_fav")
                    
                }
                
                let p1 = NSPredicate(format: "id = %@", _id)
                let p2 = NSPredicate(format: "is_fav = %@", "0")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
                let nonFavcontactArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
                if(nonFavcontactArr.count > 0)
                {
                    let predic2 = NSPredicate(format: "id == %@",_id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Favourite_Contact, Predicatefromat: predic2, Deletestring:_id , AttributeName: "id")
                }
                if let showMobileNumber = FavDict["showNumber"] as? Bool, !showMobileNumber {
                    msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.value(forKey: "email"))
                }else {
                    msisdn = msisdn.parseNumber
                }
                
                name = Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.value(forKey: "Name"))
                contact_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.value(forKey: "_id"))
                
                var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "ProfilePic"))
                if(image_Url != "")
                {
                    if(image_Url.substring(to: 1) == ".")
                    {
                        image_Url.remove(at: image_Url.startIndex)
                    }
                    image_Url = ("\(ImgUrl)\(image_Url)")
                    
                }
                print("❎   \(name) \(image_Url)")
                let mute_status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "opponent_id", fetchString: _id, returnStr: "is_mute")
                
                let ConvDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":_id,"type":"single","chat_type":"normal"]
                self.EmitConvDetails(ConvDict: ConvDict)
                image_Url = image_Url == "" ? "photo" : image_Url
                let Dict:Dictionary = [
                    "name":name,
                    "countrycode":Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "CountryCode")),
                    "id":_id,
                    "is_add":Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "is_add")),
                    "msisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "msisdn")),
                    "phnumber":Phonenumber,
                    "contact_id":contact_ID,
                    "profilepic":image_Url,
                    "status":status1,
                    "user_id":Themes.sharedInstance.Getuser_id(),
                    "is_fav":"1",
                    "is_online":Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "is_online")),
                    "time_stamp":Themes.sharedInstance.CheckNullvalue(Passed_value: FavDict.object(forKey: "time_stamp")),
                    "is_mute":mute_status,
                    "security_code":security_code,
                    "last_seen":last_seen,
                    "profile_photo":profile_photo,
                    "show_status":profile_status,
                    "contactUserList" : contactUserList,
                    "formatted" : msisdn,
                    "email_address":"mail@mail.com"
                ] as [String : Any]
                
                let msisdnPred = NSPredicate(format: "NOT (msisdn contains[c] %@)", msisdn)
                let idPred = NSPredicate(format: "id == %@", _id)
                let CheckPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPred, msisdnPred])
                let Checkfav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: CheckPredicate, Limit: 0) as! NSArray
                if(Checkfav.count < 1)
                {
                    if(_id != Themes.sharedInstance.Getuser_id()){
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Favourite_Contact)
                    }
                }
                else
                {
                    if(_id != Themes.sharedInstance.Getuser_id()){
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: _id, attribute: "id", UpdationElements: Dict as NSDictionary)
                    }
                }
                
                
            }
            self.doNextAction(Index: Index)
        }
        else
        {
            self.doNextAction(Index: Index)
        }
    }
    
    func doNextAction(Index : Int)
    {
        var Index = Index
        if(isRecent)
        {
            let ChangePred = NSPredicate(format: "is_changed == %@", "1")
            
            let checkRecentArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Contact_add, SortDescriptor: nil, predicate: ChangePred, Limit: 0) as! [NSManagedObject]
            if(checkRecentArr.count > 0)
            {
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Contact_add, FetchString: "1", attribute: "is_changed", UpdationElements: ["is_changed" : "0"] as NSDictionary)
                _ = checkRecentArr.map{
                    let phone = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "contact_mobilenum"))
                    let predic3 = NSPredicate(format: "msisdn contains[c] %@", phone)
                    DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, predicate: predic3, UpdationElements: ["name" : ""] as NSDictionary)
                }
            }
            
            let predicate = NSPredicate(format: "is_fav != %@", "2")
            let CheckFavCount = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
            if(CheckFavCount.count > 0)
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:Constant.sharedinstance.reloadData), object: nil)
            }
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.NoContacts), object: nil)
            }
            self.StorecontactInProgress = false
        }
        else
        {
            Index = (isRecent) ? Index - 1 : Index
            
            let ContactArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil, SortDescriptor: nil) as! NSArray
            
            if((Index + 1) * Constant.sharedinstance.ContactCount < ContactArr.count)
            {
                self.CheckFav(index: Index + 1)
            }
            else
            {
                let predicate = NSPredicate(format: "is_fav != %@", "2")
                let CheckFavCount = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
                if(CheckFavCount.count > 0)
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:Constant.sharedinstance.reloadData), object: nil)
                }
                else
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.NoContacts), object: nil)
                }
                self.StorecontactInProgress = false
            }
        }
    }
    
    func StoreContacts()
    {
        DispatchQueue.main.async {
            Themes.sharedInstance.showWaitingNetwork(false, state: false)
        }
        if(self.CheckCheckPermission())
        {
            self.StorecontactInProgress = true
            DispatchQueue.global(qos: .background).async {
                
                self.fetchContactsFromPhone(completionHandler: { (total, success) in
                    if(total == self.contacts.count)
                    {
                        self.SaveContact(completionHandler: { (totalcontact) in
//                            let RecentContactArr : NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "is_changed", FetchString: "1", SortDescriptor: nil) as! NSArray
                            DatabaseHandler.sharedInstance.FetchFromDBWithCompletion(Entityname: Constant.sharedinstance.Contact_add, attribute: "is_changed", FetchString: "1", SortDescriptor: nil, completion: { (result) in
                                let RecentContactArr = result as! NSArray
                                if(RecentContactArr.count > 0) {
                                    self.sendRecentlyUpdatedContactArray(index: 0, ContactArr: RecentContactArr)
                                } else {
                                    self.CheckFavArray(index: 0, RecentContactArr: RecentContactArr, ContactArr: totalcontact)
                                }
                                DispatchQueue.main.async {
                                    Themes.sharedInstance.showWaitingNetwork(false, state: true)
                                }
                            })
                        })
                    }
                })
            }
        }
    }
    
    func fetchContactsFromPhone(completionHandler : @escaping(_ totalCount : Int,_ Success : Bool) -> Void)
    {
        callBack = completionHandler
        
        PhonenumberArray = NSMutableArray()
        ContactNameArr = NSMutableArray()
        contactID_Array = NSMutableArray()
        contactEmail_Array = NSMutableArray()
        contactphone_Array = NSMutableArray()
        contactAddress_Array = NSMutableArray()
        contactDetails_Array = NSMutableArray()
        contactStore = CNContactStore()
        
        let last_seen = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "last_seen")
        if(last_seen == ""){
            let Dict = ["last_seen":"everyone","profile_photo":"everyone","show_status":"everyone"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary)
        }
        
        NotificationCenter.default.removeObserver(AppDelegate(), name: .CNContactStoreDidChange, object: nil)
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor,
                                                               CNContactFamilyNameKey as CNKeyDescriptor,
                                                               CNContactMiddleNameKey as CNKeyDescriptor,
                                                               CNContactPhoneticGivenNameKey as CNKeyDescriptor,
                                                               CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
                                                               CNContactPhoneticMiddleNameKey as CNKeyDescriptor,
                                                               CNContactPhoneNumbersKey as CNKeyDescriptor,
                                                               CNContactEmailAddressesKey as CNKeyDescriptor,
                                                               CNContactPostalAddressesKey as CNKeyDescriptor])
        contacts = [CNContact]()
        try? contactStore.enumerateContacts(with: fetchRequest) { contact, stop in
            if contact.phoneNumbers.count > 0 {
                self.contacts.append(contact)
            }
        }
        if(contacts.count > 0)
        {
            DispatchQueue.global(qos: .background).async {
                self.GetContactDetailsFromFetchedList(0, self.contacts.count, completionHandler: { (i, j) in
                    completionHandler(j,true)
                })
            }
        }
        
    }
    
    func GetContactDetailsFromFetchedList(_ i : Int,_ j : Int, completionHandler :@escaping (_ from : Int,_ to : Int) -> Void)
    {
        ArrayCreations {
            completionHandler(i, j)
        }
        
    }
    
    func ArrayCreations(completionHandler: @escaping() -> Void)
    {
        DispatchQueue.main.async {
            
            _ =    self.contacts.map{
                let indexofContact = (self.contacts as NSArray).index(of: $0)
                let currentcontact = $0
                
                //var email:String = ""
                var Phonenumber:String = ""
                var email:String = ""
                var label:String = ""
                let store_mob:NSMutableArray = NSMutableArray()
                let store_mail:NSMutableArray = NSMutableArray()
                let store_address:NSMutableArray = NSMutableArray()
                let store_web:NSMutableArray = NSMutableArray()
                
                _ =    currentcontact.phoneNumbers.map{
                    let phonenumbers = $0
                    Phonenumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ((phonenumbers.value).value(forKey: "digits") as! String))
                    let str = phonenumbers.value(forKey: "label") as? String
                    
                    
                    if(str != nil){
                        label = Themes.sharedInstance.CheckNullvalue(Passed_value: (phonenumbers.value(forKey: "label") as! String))
                    }
                    
                    if(label.hasPrefix("_")){
                        var endIndex = label.index(label.endIndex, offsetBy: -4)
                        label = label.substring(to: endIndex)
                        endIndex = label.index(label.startIndex, offsetBy: 4)
                        label = label.substring(with: endIndex..<label.endIndex)
                    }
                    
                    let phone:NSMutableDictionary = ["type":label,"value":Phonenumber]
                    let web:NSMutableDictionary = ["type":"phone_number","value":Phonenumber,"label":label]
                    store_mob.add(phone)
                    store_web.add(web)
                    
                }
                
                _ = currentcontact.emailAddresses.map {
                    let emailAddresses = $0
                    email = Themes.sharedInstance.CheckNullvalue(Passed_value: (emailAddresses.value))
                    label = ""
                    let str = emailAddresses.value(forKey: "label") as? String
                    
                    
                    if(str != nil){
                        label = Themes.sharedInstance.CheckNullvalue(Passed_value: (emailAddresses.value(forKey: "label") as! String))
                    }
                    if(label.hasPrefix("_")){
                        var endIndex = label.index(label.endIndex, offsetBy: -4)
                        label = label.substring(to: endIndex)
                        endIndex = label.index(label.startIndex, offsetBy: 4)
                        label = label.substring(with: endIndex..<label.endIndex)
                    }
                    
                    let emails:NSMutableDictionary = ["type":label,"value":email]
                    let web_mail:NSMutableDictionary = ["type":"email","value":email,"label":label]
                    store_mail.add(emails)
                    store_web.add(web_mail)
                }
                
                _ = currentcontact.postalAddresses.map{
                    let postalAddresses = $0
                    label = ""
                    let str = postalAddresses.value(forKey: "label") as? String
                    
                    if(str != nil){
                        label = Themes.sharedInstance.CheckNullvalue(Passed_value: (postalAddresses.value(forKey: "label") as! String))
                    }
                    if(label.hasPrefix("_")){
                        var endIndex = label.index(label.endIndex, offsetBy: -4)
                        label = label.substring(to: endIndex)
                        endIndex = label.index(label.startIndex, offsetBy: 4)
                        label = label.substring(with: endIndex..<label.endIndex)
                    }
                    
                    let street = Themes.sharedInstance.CheckNullvalue(Passed_value: ((postalAddresses.value).value(forKey: "street") as! String))
                    let webs_address:NSMutableDictionary = ["type":"street","value":street,"label":label]
                    store_web.add(webs_address)
                    let city = Themes.sharedInstance.CheckNullvalue(Passed_value: ((postalAddresses.value).value(forKey: "city") as! String))
                    let webc_address:NSMutableDictionary = ["type":"city","value":city,"label":label]
                    store_web.add(webc_address)
                    let state = Themes.sharedInstance.CheckNullvalue(Passed_value: ((postalAddresses.value).value(forKey: "state") as! String))
                    let webst_address:NSMutableDictionary = ["type":"state","value":state,"label":label]
                    store_web.add(webst_address)
                    let postalCode = Themes.sharedInstance.CheckNullvalue(Passed_value: ((postalAddresses.value).value(forKey: "postalCode") as! String))
                    let webp_address:NSMutableDictionary = ["type":"postalCode","value":postalCode,"label":label]
                    store_web.add(webp_address)
                    let country = Themes.sharedInstance.CheckNullvalue(Passed_value: ((postalAddresses.value).value(forKey: "country") as! String))
                    let webco_address:NSMutableDictionary = ["type":"country","value":country,"label":label]
                    store_web.add(webco_address)
                    
                    
                    let address:NSMutableDictionary = ["type":label,"street":street,"city":city,"state":state,"postalCode":postalCode,"country":country,"label":label]
                    
                    store_address.add(address)
                }
                
                
                var ContactName:NSString = ""
                if(currentcontact.middleName == "")
                {
                    ContactName = Themes.sharedInstance.CheckNullvalue(Passed_value: "\(currentcontact.givenName) \(currentcontact.familyName)") as NSString
                }
                else
                {
                    ContactName = Themes.sharedInstance.CheckNullvalue(Passed_value: "\(currentcontact.givenName) \(currentcontact.middleName) \(currentcontact.familyName)") as NSString
                }
                ContactName = ContactName.trimmingCharacters(in: NSCharacterSet.whitespaces) as NSString
                
                //                DispatchQueue.global(qos: .background).async {
                
                _ = currentcontact.phoneNumbers.map {
                    
                    let index = (currentcontact.phoneNumbers as NSArray).index(of: $0)
                    
                    Phonenumber = Themes.sharedInstance.CheckNullvalue(Passed_value: (($0.value ).value(forKey: "digits") as! String))
                    
                    if(Phonenumber != "")
                    {
                        let Character=Phonenumber[0]
                        Phonenumber = Themes.sharedInstance.RemoveNonnumericEntitites(PassedValue: Phonenumber as NSString)
                        if(Character == "+")
                        {
                            Phonenumber="\(Character)\(Phonenumber)"
                        }
                        
                        //                        print("aaaaaaaaaa...\(ContactName)....\(Phonenumber)")
                        
                        let contactNo_ID:String = Themes.sharedInstance.createUniqueContactID(ID: Themes.sharedInstance.CheckNullvalue(Passed_value: currentcontact.identifier), index: index)
                        
                        if(!self.PhonenumberArray.contains(Phonenumber))
                        {
                            if self.contactID_Array.contains(contactNo_ID){
                                let index:Int = self.contactID_Array.index(of: contactNo_ID)
                                self.contactID_Array.removeObject(at:index)
                                self.PhonenumberArray.removeObject(at:index)
                                self.OriginalPhonenumberArray.removeObject(at:index)
                                self.ContactNameArr.removeObject(at:index)
                                self.contactEmail_Array.removeObject(at:index)
                                self.contactphone_Array.removeObject(at:index)
                                self.contactAddress_Array.removeObject(at:index)
                                self.contactDetails_Array.removeObject(at:index)
                                self.PhonenumberArray.add(Phonenumber)
                                self.ContactNameArr.add(ContactName)
                                self.contactID_Array.add(contactNo_ID)
                                self.contactEmail_Array.add(store_mail)
                                self.contactphone_Array.add(store_mob)
                                self.contactAddress_Array.add(store_address)
                                self.contactDetails_Array.add(store_web)
                                
                            }
                            else{
                                self.PhonenumberArray.add(Phonenumber)
                                self.ContactNameArr.add(ContactName)
                                self.contactID_Array.add(contactNo_ID)
                                self.contactEmail_Array.add(store_mail)
                                self.contactphone_Array.add(store_mob)
                                self.contactAddress_Array.add(store_address)
                                self.contactDetails_Array.add(store_web)
                            }
                        }
                    }
                    
                }
                if(indexofContact == self.contacts.count - 1)
                {
                    completionHandler()
                }
                //                }
            }
        }
    }
    
    func SaveContact(completionHandler: @escaping (_ totalcontactArray: NSArray) -> Void)
    {
        DispatchQueue.main.async {
            var ContactArr = [NSDictionary]()
            if(self.PhonenumberArray.count > 0)
            {
                _ = self.PhonenumberArray.map {
                    let phonenumber = $0
                    if self.PhonenumberArray.contains(phonenumber){
                        let i = self.PhonenumberArray.index(of: phonenumber)
                        if self.contactphone_Array.count > i && self.contactEmail_Array.count > i && self.contactAddress_Array.count > i && self.ContactNameArr.count > i && self.contactID_Array.count  > i{
                            let contact_details:NSMutableDictionary = ["phone_number":self.contactphone_Array[i],"email":self.contactEmail_Array[i],"address":self.contactAddress_Array[i],"im":[],"organisation":[],"name":[]]
                            if let json = try?JSONSerialization.data(withJSONObject: contact_details, options: []) {
                                if let content = String(data: json, encoding: String.Encoding.utf8) {
                                    let Dict:NSMutableDictionary=["contact_id":self.contactID_Array[i],"contact_mobilenum":self.PhonenumberArray[i],"contact_name":self.ContactNameArr[i],"is_fav":"0","contact_details":content]
                                    ContactArr.append(Dict)
                                }
                                
                            }
                        }
                    }
                }
                
                if(ContactArr.count > 0)
                {
                    let sortedArray = ContactArr.sorted { Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "contact_name")).lowercased() < Themes.sharedInstance.CheckNullvalue(Passed_value: $1.value(forKey: "contact_name")).lowercased()}
                    ContactArr.removeAll()
                    ContactArr.append(contentsOf: sortedArray)
                    
                    DatabaseHandler.sharedInstance.fetchTableAllDataCompletion(Entityname: Constant.sharedinstance.Contact_add, completion: { (result) in
                        let totalcontactArray = result as! NSArray
                        
                        _ = ContactArr.map {
                            var Dict = $0 as! [String : Any]
                            let contact_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict["contact_id"])
                            let p1 = NSPredicate(format: "contact_id == %@", contact_id)
                            //                        let checkContact = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Contact_add, SortDescriptor: nil, predicate: p1, Limit: 0) as! NSArray
                            let checkContact = totalcontactArray.filter { p1.evaluate(with: $0) };
                            
                            let contact_name:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict["contact_name"])
                            let contact_mobilenum:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict["contact_mobilenum"])
                            
                            let p2 = NSPredicate(format: "contact_name == %@", contact_name)
                            let p3 = NSPredicate(format: "contact_mobilenum == %@", contact_mobilenum)
                            
                            //                        let checkContactAgain = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Contact_add, SortDescriptor: nil, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3]), Limit: 0) as! NSArray
                            let combinepredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
                            let checkContactAgain = totalcontactArray.filter { combinepredicate.evaluate(with: $0) };
                            
                            if(checkContact.count > 0) {
                                if(checkContactAgain.count == 0) {
                                    Dict["is_changed"] = "1"
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Contact_add, FetchString: contact_id, attribute: "contact_id", UpdationElements: Dict as NSDictionary)
                                } else {
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Contact_add, FetchString: contact_id, attribute: "contact_id", UpdationElements: Dict as NSDictionary)
                                }
                            } else {
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname:Constant.sharedinstance.Contact_add)
                            }
                        }
                        
                        //let AllContacts = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [NSManagedObject]
                        DatabaseHandler.sharedInstance.fetchTableAllDataCompletion(Entityname: Constant.sharedinstance.Contact_add, completion: { (result) in
                            let AllContacts = result as! [NSManagedObject]
                            _ = AllContacts.map {
                                let dict = $0
                                let contact_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "contact_id"))
                                let contact_phone:String = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "contact_mobilenum"))
                                if(!self.contactID_Array.contains(contact_id))
                                {
                                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Contact_add, Predicatefromat: NSPredicate(format: "contact_id == %@", contact_id), Deletestring: contact_id, AttributeName: "contact_id")
                                    
                                    let predic3 = NSPredicate(format: "msisdn contains[c] %@", contact_phone)
                                    let ContactArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predic3, Limit: 0) as! [NSManagedObject]
                                    
                                    _ = ContactArr.map {
                                        let Cdict = $0
                                        let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + Themes.sharedInstance.CheckNullvalue(Passed_value: Cdict.value(forKey: "id"))
                                        let CheckChat = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", FetchString: user_common_id)
                                        if(CheckChat)
                                        {
                                            DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, predicate: predic3, UpdationElements: ["name" : "", "is_fav" : "2"] as NSDictionary)
                                        }
                                        else
                                        {
                                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Favourite_Contact, Predicatefromat:predic3 , Deletestring: "1", AttributeName: "is_fav")
                                        }
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:Constant.sharedinstance.reloadData), object: nil)
                                    }
                                }
                            }
                            
                            completionHandler(result as! NSArray)
                        })
                    })
                }
            }
            else
            {
                self.StorecontactInProgress = false
                completionHandler(NSArray())
            }
        }
    }
    
    func CheckFav(index : Int)
    {
        if(self.CheckCheckPermission())
        {
            let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
            if(CheckLogin)
            {
                
                let CheckContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil);
                if(CheckContact)
                {
                    let RecentContactArr : NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "is_changed", FetchString: "1", SortDescriptor: nil) as! NSArray
                    if(RecentContactArr.count > 0)
                    {
                        self.sendRecentlyUpdatedContacts(index: 0)
                    }
                    else
                    {
                        let ContactArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil, SortDescriptor: nil) as! NSArray
                        
                        if(ContactArr.count > 0)
                        {
                            let CheckFavcontactArr:NSMutableArray=NSMutableArray()
                            var ContactsInRange = NSArray()
                            if(index * Constant.sharedinstance.ContactCount + Constant.sharedinstance.ContactCount < ContactArr.count)
                            {
                                ContactsInRange = ContactArr.subarray(with: NSRange(location: index * Constant.sharedinstance.ContactCount, length: Constant.sharedinstance.ContactCount)) as NSArray
                            }
                            else
                            {
                                if(index * Constant.sharedinstance.ContactCount < ContactArr.count)
                                {
                                    ContactsInRange = ContactArr.subarray(with: NSRange(location: index * Constant.sharedinstance.ContactCount, length: ContactArr.count % Constant.sharedinstance.ContactCount)) as NSArray
                                }
                            }
                            _ = ContactsInRange.map {
                                
                                let ChatFavObj = $0 as! NSManagedObject
                                let dict_contact:NSMutableDictionary=NSMutableDictionary()
                                
                                var nameStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_name"))
                                nameStr = nameStr == "" ? Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_mobilenum")) : nameStr
                                dict_contact.setDictionary(["Phno":Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_mobilenum")),"Name":nameStr.decoded])
                                CheckFavcontactArr.add(dict_contact as NSDictionary)
                                //                                print("aaaaaaaaaa...\(nameStr.decoded).......\(Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_mobilenum")))")
                                
                            }
                            
                            
                            if(CheckFavcontactArr.count > 0)
                            {
                                var dictFromJSONArr:Any!
                                
                                let GetContactNumber:String = Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                                
                                
                                do {
                                    let jsonData = try JSONSerialization.data(withJSONObject: CheckFavcontactArr, options: .prettyPrinted)
                                    if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                                        dictFromJSONArr=JSONString
                                        dictFromJSONArr = (dictFromJSONArr as! NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                                        
                                    }
                                    
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                                let CheckFavDict:[String:String]=["msisdn":"\(GetContactNumber)","Contacts": dictFromJSONArr as! String, "indexAt" : "\(index)"]
                                
                                isRecent = false
                                SocketIOManager.sharedInstance.GetFavContact(Dict: CheckFavDict as NSDictionary)
                                
                                if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                                    self.StorecontactInProgress = false
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func CheckFavArray(index : Int, RecentContactArr: NSArray, ContactArr: NSArray) {
        if(self.CheckCheckPermission()) {
            let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
            if(CheckLogin) {
                let CheckContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil);
                if(CheckContact) {
//                    let RecentContactArr : NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "is_changed", FetchString: "1", SortDescriptor: nil) as! NSArray
                    if(RecentContactArr.count > 0) {
//                        self.sendRecentlyUpdatedContacts(index: 0)
                        self.sendRecentlyUpdatedContactArray(index: 0, ContactArr: RecentContactArr)
                    } else {
//                        let ContactArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil, SortDescriptor: nil) as! NSArray
                        
                        if(ContactArr.count > 0) {
                            let CheckFavcontactArr:NSMutableArray=NSMutableArray()
                            var ContactsInRange = NSArray()
                            if(index * Constant.sharedinstance.ContactCount + Constant.sharedinstance.ContactCount < ContactArr.count) {
                                ContactsInRange = ContactArr.subarray(with: NSRange(location: index * Constant.sharedinstance.ContactCount, length: Constant.sharedinstance.ContactCount)) as NSArray
                            } else {
                                if(index * Constant.sharedinstance.ContactCount < ContactArr.count) {
                                    ContactsInRange = ContactArr.subarray(with: NSRange(location: index * Constant.sharedinstance.ContactCount, length: ContactArr.count % Constant.sharedinstance.ContactCount)) as NSArray
                                }
                            }
                            
                            _ = ContactsInRange.map {
                                let ChatFavObj = $0 as! NSManagedObject
                                let dict_contact:NSMutableDictionary=NSMutableDictionary()
                                
                                var nameStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_name"))
                                nameStr = nameStr == "" ? Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_mobilenum")) : nameStr
                            dict_contact.setDictionary(["Phno":Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_mobilenum")),"Name":nameStr.decoded])
                                CheckFavcontactArr.add(dict_contact as NSDictionary)
                            }
                            
                            if(CheckFavcontactArr.count > 0) {
                                var dictFromJSONArr:Any!
                                let GetContactNumber:String = Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                                
                                do {
                                    let jsonData = try JSONSerialization.data(withJSONObject: CheckFavcontactArr, options: .prettyPrinted)
                                    if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                                        dictFromJSONArr=JSONString
                                        dictFromJSONArr = (dictFromJSONArr as! NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                                let CheckFavDict:[String:String]=["msisdn":"\(GetContactNumber)","Contacts": dictFromJSONArr as! String, "indexAt" : "\(index)"]
                                
                                isRecent = false
                                SocketIOManager.sharedInstance.GetFavContact(Dict: CheckFavDict as NSDictionary)
                                
                                if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                                    self.StorecontactInProgress = false
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func sendRecentlyUpdatedContacts(index : Int) {
        if(self.CheckCheckPermission()) {
            let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
            if(CheckLogin) {
                let CheckContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil);
                if(CheckContact) {
                    let ContactArr : NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "is_changed", FetchString: "1", SortDescriptor: nil) as! NSArray
                    if(ContactArr.count > 0) {
                        let CheckFavcontactArr:NSMutableArray=NSMutableArray()
                        _ = ContactArr.map {
                            let ChatFavObj = $0 as! NSManagedObject
                            let dict_contact:NSMutableDictionary=NSMutableDictionary()
                            
                            let nameStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_name"))
                            dict_contact.setDictionary(["Phno":Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_mobilenum")),"Name":nameStr.decoded])
                            CheckFavcontactArr.add(dict_contact as NSDictionary)
                        }
                        
                        if(CheckFavcontactArr.count > 0) {
                            var dictFromJSONArr:Any!
                            let GetContactNumber:String = Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                            
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: CheckFavcontactArr, options: .prettyPrinted)
                                if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                                    dictFromJSONArr=JSONString
                                    dictFromJSONArr = (dictFromJSONArr as! NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            let CheckFavDict:[String:String]=["msisdn":"\(GetContactNumber)","Contacts": dictFromJSONArr as! String, "indexAt" : "\(index)"]
                            
                            isRecent = true
                            SocketIOManager.sharedInstance.GetFavContact(Dict: CheckFavDict as NSDictionary)
                            
                            if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                                self.StorecontactInProgress = false
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func sendRecentlyUpdatedContactArray(index : Int, ContactArr: NSArray) {
        if(self.CheckCheckPermission()) {
            let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
            if(CheckLogin) {
                let CheckContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: nil, FetchString: nil);
                if(CheckContact) {
//                    let ContactArr : NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "is_changed", FetchString: "1", SortDescriptor: nil) as! NSArray
                    if(ContactArr.count > 0) {
                        let CheckFavcontactArr:NSMutableArray=NSMutableArray()
                        _ = ContactArr.map {
                            let ChatFavObj = $0 as! NSManagedObject
                            let dict_contact:NSMutableDictionary=NSMutableDictionary()
                            
                            let nameStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_name"))
                            dict_contact.setDictionary(["Phno":Themes.sharedInstance.CheckNullvalue(Passed_value: ChatFavObj.value(forKey: "contact_mobilenum")),"Name":nameStr.decoded])
                            CheckFavcontactArr.add(dict_contact as NSDictionary)
                        }
                        
                        if(CheckFavcontactArr.count > 0) {
                            var dictFromJSONArr:Any!
                            let GetContactNumber:String = Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                            
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: CheckFavcontactArr, options: .prettyPrinted)
                                if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                                    dictFromJSONArr=JSONString
                                    dictFromJSONArr = (dictFromJSONArr as! NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            let CheckFavDict:[String:String]=["msisdn":"\(GetContactNumber)","Contacts": dictFromJSONArr as! String, "indexAt" : "\(index)"]
                            
                            isRecent = true
                            SocketIOManager.sharedInstance.GetFavContact(Dict: CheckFavDict as NSDictionary)
                            
                            if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                                self.StorecontactInProgress = false
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func CheckCheckPermission()->Bool
    {
        var isgivenPermission:Bool=Bool()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted || status == .notDetermined
        {
            isgivenPermission=false
        }
        else
            
        {
            isgivenPermission=true
            
        }
        return isgivenPermission
        
    }
}


