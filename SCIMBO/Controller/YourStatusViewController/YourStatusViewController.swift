//
//  YourStatusViewController.swift
//
//
//  Created by CASPERON on 15/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
protocol reloadTable : class {
    func reloadStatus()
}

class YourStatusViewController: UIViewController,UITextViewDelegate,SocketIOManagerDelegate{
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var status_TextView: UITextView!
    var statusFrmEditVC:String = String()
    var yourstatus:String = String()
    weak var delagate:reloadTable!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        //     if statusFrmEditVC != "" {
        
        status_TextView.text = yourstatus
        let remainingLength = 140 - status_TextView.text.length
        titleLbl.text = "Your Status(\(String(remainingLength)))"
        
        // Do any additional setup after loading the view.
        //    }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.pop(animated: true)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        let remainingLength = 140 - numberOfChars
        titleLbl.text = "Your Status(\(String(remainingLength)))"
        
        // for Swift use count(newText)
        return numberOfChars < 140;
    }
    @IBAction func saveAction(_ sender: UIButton) {
        
        var checkVal:String = "not repeat"
        
        if statusFrmEditVC != ""{
            
            for i in 0..<statusRec.count{
                
                let recVal:StatusRec = statusRec[i] as StatusRec
                if statusFrmEditVC != ""{
                    if recVal.status == statusFrmEditVC {
                        
                        statusRec[i].status = status_TextView.text
                        DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.status_List)
                        for j in 0..<statusRec.count{
                            
                            let  getRec:StatusRec = statusRec[j]
                            let checkStatus = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.status_List, attribute: "status_title", FetchString: getRec.status)
                            if(!checkStatus)
                            {
                                let Dict:NSMutableDictionary=["status_id":"\(j)","status_title": getRec.status]
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname:Constant.sharedinstance.status_List)
                            }
                            
                        }
                    }
                    
                }
            }
            
            self.pop(animated: true)
            
        }
        else{
            for i in 0..<statusRec.count{
                
                let recVal:StatusRec = statusRec[i] as StatusRec
                
                //            statusRec[statusRec.count].isSelect = true
                if recVal.status == status_TextView.text {
                    checkVal =   "repeated"
                    
                    
                    
                }
                
            }
        }
        if statusFrmEditVC == ""{
            if checkVal == "not repeat"{
                if(status_TextView.text.trimmingCharacters(in: .whitespaces).isEmpty == false){
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.Delegate = self
                    SocketIOManager.sharedInstance.changeStatus(status:status_TextView.text as String , from:Themes.sharedInstance.Getuser_id())
                }else{
                    Themes.sharedInstance.ShowNotification("Status field cannot be empty", false)
                }
                
            }
            else{
                self.pop(animated: true)
            }
        }
        
        
    }
    
    
    func  statusUpdated(_Updated:String)
    {
        if(_Updated != "CHECK")
        {
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if _Updated == "Updated"{
                
                let checkStatus = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.status_List, attribute: "status_title", FetchString: status_TextView.text)
                if(!checkStatus)
                {
                    let Dict:NSMutableDictionary=["status_id":"\(statusRec.count)","status_title":status_TextView.text]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname:Constant.sharedinstance.status_List)
                }
                
                if(self.delagate != nil){
                    self.delagate.reloadStatus()
                }
                self.pop(animated: true)
                
            }
            else{
                self.view.makeToast(message: "error connection", duration: 3, position: HRToastActivityPositionDefault)
                
            }
        }
        
        
    }
    func  statusUpdtFrmStatsLst(_ status: String){
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        SocketIOManager.sharedInstance.Delegate = nil
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

