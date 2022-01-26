//
//  CalldetailVC.swift
//
//
//  Created by MV Anand Casp iOS on 26/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.
import UIKit
import SDWebImage
class CalldetailVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var user_img: UIImageView!
    @IBOutlet weak var user_Name: UILabel!
    @IBOutlet weak var callButton: UIButton!
    var user_id:String = String()
    var DataSourceDictArr:NSMutableArray = NSMutableArray()
    var user_common_id:String = String()
    var status:String = String()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        let nibName = UINib(nibName: "CallDetailLogCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: "CallDetailLogCellID")
        self.tableView.estimatedRowHeight = 40
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        getContactIsActive()
        // Do any additional setup after loading the view.
    }
    
    func getContactIsActive() {
        let id = Themes.sharedInstance.CheckNullvalue(Passed_value: user_id)
        SocketIOManager.sharedInstance.checkUserStatus(from: id)
        NotificationCenter.default.addObserver(self, selector: #selector(activatedUsers(_:)), name: NSNotification.Name.init("chechActive"), object: nil)
    }
    
    @objc func activatedUsers(_ notification: Notification) {
        
        
        guard let isDeleted = notification.userInfo?["isDeleted"] as? String else {
            return
        }
        if isDeleted == "1"{
            callButton.isUserInteractionEnabled = false
        }else {
            callButton.isUserInteractionEnabled = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloaddata()
        user_img.layer.cornerRadius = user_img.frame.size.width/2
        user_img.clipsToBounds = true
    }
    
    func reloaddata()
    {
        self.user_img.setProfilePic(self.user_id, "single")
        self.user_Name.setNameTxt(self.user_id, "single")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DidclickBack(_ sender: Any)
    {
        self.pop(animated: true)
    }
    
    @IBAction func DidclickInfo(_ sender: Any)
    {
        let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
        singleInfoVC.user_id = user_id
        self.pushView(singleInfoVC, animated: true)
    }
    @IBAction func DidclickCall_Btn(_ sender: Any) {
        if(SocketIOManager.sharedInstance.socket.status == .connected)
        {
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "") {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let docID = "\(Themes.sharedInstance.Getuser_id())-\(user_id)-\(timestamp)"
            let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: user_id),"type":Int(status)!,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
            SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
            AppDelegate.sharedInstance.openCallPage(type: status, roomid: timestamp, id: user_id)
            
            
        }
        else {
            self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reloaddata()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}

extension CalldetailVC:UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DataSourceDictArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CallDetailLogCell  = tableView.dequeueReusableCell(withIdentifier: "CallDetailLogCellID") as! CallDetailLogCell
        //        var Dict:NSDictionary = NSDictionary()
        cell.selectionStyle = .none
        let objCallRecord:calllog_Record = DataSourceDictArr[indexPath.row] as! calllog_Record
        var Type:String = ""
        if(objCallRecord.call_type == "0")
        {
            cell.call_icon.image = #imageLiteral(resourceName: "call_icon")
            Type = "Voice call"
        }
        else
        {
            cell.call_icon.image = #imageLiteral(resourceName: "video_icon")
            Type = "Video call"
            
        }
        
        if(objCallRecord.calllog_type == "0")
        {
            cell.call_status.text = "Missed \(Type)"
            cell.call_status.textColor = UIColor.red
        }
        else if(objCallRecord.calllog_type == "1")
        {
            cell.call_status.text = "Outgoing \(Type)"
            cell.call_status.textColor = UIColor.black
        }
        else if (objCallRecord.calllog_type == "2")
        {
            cell.call_status.text = "Incoming \(Type)"
            cell.call_status.textColor = UIColor.black
        }
        
        let DayStr:String = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: objCallRecord.timestamp)
        let TimeStr:String = Themes.sharedInstance.ReturnTimeForChat(timestamp: objCallRecord.timestamp)
        
        if(DayStr == "Today")
        {
            cell.time_Lbl.text = TimeStr
        }
        else
        {
            cell.time_Lbl.text = DayStr
        }
        
        cell.call_duration.isHidden = true
        
        if let float = Float(Themes.sharedInstance.CheckNullvalue(Passed_value: objCallRecord.duration)), float > 0.0 {
            let duration = Int(float)
            cell.call_duration.isHidden = false
            Themes.sharedInstance.hmsFrom(seconds: duration) { hours, minutes, seconds in
                
                let hours = Themes.sharedInstance.getStringFrom(seconds: hours)
                let minutes = Themes.sharedInstance.getStringFrom(seconds: minutes)
                let seconds = Themes.sharedInstance.getStringFrom(seconds: seconds)
                
                var finalstr = ""
                if(hours != "00") {
                    finalstr.append("\(Int(hours)!) hours,")
                }
                if(minutes != "00") {
                    finalstr.append("\(Int(minutes)!) minutes,")
                }
                if(seconds != "00") {
                    finalstr.append("\(Int(seconds)!) seconds")
                }
                
                print(finalstr)
                cell.call_duration.text = finalstr
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        
    }
    
}
