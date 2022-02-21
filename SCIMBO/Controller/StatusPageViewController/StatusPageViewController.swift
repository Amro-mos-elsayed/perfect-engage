//
//  StatusPageViewController.swift
//  whatsUpStatus
//
//  Created by raguraman on 03/04/18.
//  Copyright © 2018 raguraman. All rights reserved.
//

import UIKit

protocol StatusPageViewControllerDelegate : class {
    func DidDismiss()
    func DidClickDelete(_ messageFrame : UUMessageFrame)
}


class StatusPageViewController: UIPageViewController
{
    var isMyStatus = false
    var currentStatusIndex = 0
    var statusBarHidden = true
    weak var customDelegate:StatusPageViewControllerDelegate?
    var ChatRecorDict = [String : NSMutableArray]()
    var idArr = [String]()
    var startIndex : Int = Int()
    var isFromView : Bool = Bool()
    
    fileprivate lazy var pages: [UIViewController] = {
        if(self.isMyStatus)
        {
            var views = [UIViewController]()
            self.idArr.forEach({ id in
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatusViewController") as! StatusViewController
                    vc.isMyStatus = self.isMyStatus
                    vc.statusArray = self.ChatRecorDict[id]!
                    vc.startIndex = self.startIndex
                    vc.isFromView = self.isFromView
                    vc.userId = Themes.sharedInstance.Getuser_id()
                    vc.view.clipsToBounds = true
                    vc.delegate = self
                    views.append(vc)
                }
            })
            return views
        }
        else
        {
            
            var views = [UIViewController]()
            self.idArr.forEach({ id in
                if(id != Themes.sharedInstance.Getuser_id())
                {
                    var i = 0
                    let datasource : NSMutableArray = self.ChatRecorDict[id]!
                    for messageFrame in datasource {
                        let messageFrame : UUMessageFrame = messageFrame as! UUMessageFrame
                        
                        if(messageFrame.message.is_viewed != "1")
                        {
                            i = datasource.index(of: messageFrame) - 1
                            break
                        }
                    }
                    if(i < 0 || i > 0)
                    {
                        i = i + 1
                    }
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatusViewController") as! StatusViewController
                    vc.isMyStatus = self.isMyStatus
                    vc.statusArray = self.ChatRecorDict[id]!
                    vc.startIndex = i
                    vc.userId = id
                    vc.view.clipsToBounds = true
                    vc.delegate = self
                    views.append(vc)
                }
            })
            return views
        }
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! StatusViewController
        vc.view.clipsToBounds = true
        vc.delegate = self
        vc.isMyStatus = isMyStatus
        return vc
    }
    
    var isHidden = true{
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        //        if let firstVC : UIViewController = pages[currentStatusIndex]
        //        {
        setViewControllers([pages[currentStatusIndex]], direction: .forward, animated: true, completion: nil)
        //        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        swipeDown.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statusBarHidden = false
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Swipe Down")
            isHidden = false
            setNeedsStatusBarAppearanceUpdate()
            customDelegate?.DidDismiss()
            self.dismissView(animated: true, completion: nil)
        }
    }
}

extension StatusPageViewController:StatusViewControllerDelegate{
    
    func currentStatusEnded() {
        guard currentStatusIndex+1 < pages.count else {
            isHidden = false
            setNeedsStatusBarAppearanceUpdate()
            customDelegate?.DidDismiss()
            self.dismissView(animated: true, completion: nil)
            return
        }
        
        guard pages.count > currentStatusIndex+1 else {
            isHidden = false
            setNeedsStatusBarAppearanceUpdate()
            customDelegate?.DidDismiss()
            self.dismissView(animated: true, completion: nil)
            return
        }
        currentStatusIndex = currentStatusIndex+1
        setViewControllers([pages[currentStatusIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    func backButtonTapped() {
        isHidden = false
        setNeedsStatusBarAppearanceUpdate()
        customDelegate?.DidDismiss()
        self.dismissView(animated: true, completion: nil)
    }
    
    func DidClickDelete(_ messageFrame: UUMessageFrame) {
        isHidden = false
        setNeedsStatusBarAppearanceUpdate()
        customDelegate?.DidClickDelete(messageFrame)
        self.dismissView(animated: true, completion: nil)
    }
    
    func DidClickReplyMessage(_ messageFrame: UUMessageFrame,_ message: String,_ toId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            if(message.removingWhitespaces() != "")
            {
                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: toId)
                var timestamp:String = String(Date().ticks)
                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                
                if(servertimeStr == "")
                {
                    servertimeStr = "0"
                }
                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                
                let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                
                let toDocId:String="\(from)-\(to)-\(timestamp)"
                
                var dic:[AnyHashable: Any]
                
                
                dic = ["type": "7","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                    ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                    ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:message
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                    ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
                    ),"message_from":"1","chat_type":"single","info_type":"0","created_by":from,"is_reply":"1", "reply_type" : "status", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                var Fromid:String = String()
                var CompressedData:String = String()
                print(toId,Themes.sharedInstance.Getuser_id())
                
                Fromid = messageFrame.message.doc_id.components(separatedBy: "-").first!
                
                
                if(messageFrame.message.type == MessageType(rawValue: 1)! || messageFrame.message.type == MessageType(rawValue: 2)!)
                {
                    CompressedData = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_Upload_Details, attrib_name: "upload_data_id", fetchString: messageFrame.message.thumbnail!, returnStr: "compressed_data")
                }
                else
                {
                    CompressedData = ""
                }
                
                let recordID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "msgId", fetchString: messageFrame.message.msgId!, returnStr: "recordId")
                
                let Dict:NSDictionary = ["compressed_data":CompressedData,"from_id":Fromid,"recordId":recordID,"message_type":messageFrame.message.message_type!,"payload":messageFrame.message.payload,"contactmsisdn":messageFrame.message.contactmsisdn,"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                    )]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                
                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
                if(!chatarray)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    
                }
                else
                {
                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
                
                let ReplyDict:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: "single"),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: "single"),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: "single"),"recordId":recordID, "reply_type" : "status"]

                SocketIOManager.sharedInstance.EmitReplyMessage(param: ReplyDict as NSDictionary)
            }
        })
        
    }
    
    func DidClickForward(_ messageFrame: UUMessageFrame) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            
            let Chat_arr:NSMutableArray = NSMutableArray()
            Chat_arr.add(messageFrame)
            if(Chat_arr.count > 0)
            {
                let selectShareVC = self.storyboard?.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
                selectShareVC.messageDatasourceArr =  Chat_arr
                selectShareVC.isFromForward = true
                selectShareVC.isFromStatus = true
                self.pushView(selectShareVC, animated: true)
            }
        })
    }
}

extension StatusPageViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
}

extension StatusPageViewController: UIPageViewControllerDelegate { }



