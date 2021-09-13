//
//  testTableView.swift
//  FKWidgetSheet_Example
//
//  Created by raguraman on 09/04/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import SDWebImage


protocol PersonViewedStatusViewDelegate : class {
    func closeContentSheed()
    func passSelectedPerson(data : NSDictionary)
    func forward()
    func delete()
}


class PersonViewedStatusView:UIView{
    @IBOutlet weak var personListTableView: UITableView!
    
    var isFromTag : Bool = Bool() {
        didSet{
            if(isFromTag)
            {
                StatusViewedView.isHidden = true
                TagView.isHidden = false
            }
            else
            {
                StatusViewedView.isHidden = false
                TagView.isHidden = true
            }
        }
    }
    var searchString : String = String()
    
    weak var delegate : PersonViewedStatusViewDelegate?
    
    @IBOutlet weak var StatusViewedView: UIView!
    @IBOutlet weak var TagView: UIView!
    @IBOutlet weak var TagListTblView: UITableView!
    
    @IBOutlet weak var viewsCountLbl: UILabel!
    

    var datasource : NSArray = NSArray() {
        didSet{
            TagListTblView.reloadData()

            personListTableView.reloadData()
            self.viewsCountLbl.text = "\(datasource.count) views"
        }
    }
    
    @IBAction func deleteButtonDidPressed(_ sender: UIButton) {
        delegate?.delete()
    }
    
    @IBAction func forwardButtonDidPressed(_ sender: UIButton) {
        delegate?.forward()
    }
    
    override func awakeFromNib() {
        personListTableView.dataSource = self
        personListTableView.delegate = self
        TagListTblView.dataSource = self
        TagListTblView.delegate = self

        self.registerCell()
    }
    
    private func registerCell(){
        personListTableView.register(UINib(nibName: "StatusViewedTableViewCell", bundle: nil), forCellReuseIdentifier: "StatusViewedTableViewCell")
        TagListTblView.register(UINib(nibName: "StatusViewedTableViewCell", bundle: nil), forCellReuseIdentifier: "StatusViewedTableViewCell")
    }
    
}

extension PersonViewedStatusView:UITableViewDataSource,  UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let PersonDict = self.datasource.object(at: indexPath.row) as! NSDictionary
        if(isFromTag)
        {
            let cell = TagListTblView.dequeueReusableCell(withIdentifier: "StatusViewedTableViewCell") as! StatusViewedTableViewCell
            
            let checkId = Themes.sharedInstance.CheckNullvalue(Passed_value: PersonDict.value(forKey: "id"))
            var realName = ""
            
            let id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "id")
            
            var name = Themes.sharedInstance.setNameTxt(id, "single")

            var image_Url = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "profilepic")
            
            if(id == "")
            {
                
                name = Themes.sharedInstance.CheckNullvalue(Passed_value: PersonDict.value(forKey: "msisdn")).parseNumber
                realName = Themes.sharedInstance.CheckNullvalue(Passed_value: PersonDict.value(forKey: "Name"))
                
                image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: PersonDict.value(forKey: "ProfilePic"))
                if(image_Url != "")
                {
                    if(image_Url.substring(to: 1) == ".")
                    {
                        image_Url.remove(at: image_Url.startIndex)
                    }
                    image_Url = ("\(ImgUrl)\(image_Url)")
                    
                }
            }
            cell.statusViewedDate.isHidden = true
            if(id != "")
            {
                cell.personNameLabel.text = name
                cell.statusViewedTime.text = ""
            }
            else
            {
                cell.personNameLabel.text = name
                cell.statusViewedTime.text = "~" + realName
            }
            
            let attributed = NSMutableAttributedString(string: name)
            attributed.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)], range: NSMakeRange(0, name.length))
            
            if(searchString != "" && name.lowercased().contains(searchString))
            {
                let range = name.lowercased().nsRange(from: name.lowercased().range(of: searchString)!)
                attributed.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)], range: range)
            }
            cell.personNameLabel.attributedText = attributed
            
            cell.personImg.setProfilePic(checkId, "single")
            return cell
        }
        else
        {
            let cell = personListTableView.dequeueReusableCell(withIdentifier: "StatusViewedTableViewCell") as! StatusViewedTableViewCell
            let id = PersonDict.value(forKey: "to") as! String
            
            let DayStr:String = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: PersonDict.value(forKey: "delivered_msg_time") as! String)
            let TimeStr:String = Themes.sharedInstance.ReturnTimeForChat(timestamp: PersonDict.value(forKey: "delivered_msg_time") as! String)
            
            
            let name  = Themes.sharedInstance.setNameTxt(id, "single")
            
            cell.personImg.setProfilePic(id, "single")
            cell.personNameLabel.text = name
            
            cell.statusViewedDate.text = DayStr
            cell.statusViewedTime.text = TimeStr
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let PersonDict = self.datasource.object(at: indexPath.row) as! NSDictionary
        if(isFromTag)
        {
            self.delegate?.passSelectedPerson(data: PersonDict)
        }
    }
    
    
}
