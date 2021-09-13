//
//  ChangeNameViewController.swift
//
//
//  Created by Casp iOS on 10/03/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class ChangeNameViewController: UIViewController,SocketIOManagerDelegate,UITextFieldDelegate {
    @IBOutlet weak var name_Txt: UITextField!
    @IBOutlet weak var countLbl: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var groupID:String = String()
    var name:String = String()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        saveBtn.isHidden = true
        name_Txt.text = name
        name_Txt.setLeftPaddingPoints(10)
        if name_Txt.text != ""
        {
            countLbl.text = "\(25 - (name_Txt.text?.count)!)"
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if name_Txt.text != ""{
            
            Themes.sharedInstance.activityView(View: self.view)
            SocketIOManager.sharedInstance.Delegate = self
            let name:String = name_Txt.text!
            SocketIOManager.sharedInstance.changeGroupName(groupType: "6", from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()), groupId:groupID, groupNewName: name.decoded)
        }
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.pop(animated: true)
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let trimmed = (textField.text!).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let length = (trimmed.count) - range.length + string.count
        
        if length > 0
        {
            if(trimmed != "")
            {
                if length > 25{
                    return false
                }
                countLbl.text = "\(25 - length)"
                saveBtn.isHidden = false
            }
        }
        else
        {
            saveBtn.isHidden = true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func statusUpdated(_Updated: String) {
        if _Updated == "Updated"{
            let Dict:[String:Any]=["displayName":name_Txt.text!]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_details, FetchString: groupID, attribute: "id", UpdationElements: Dict as NSDictionary?)
            self.pop(animated: true)
        }
        
        print("SUCCESSFULLY CHANGED")
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

