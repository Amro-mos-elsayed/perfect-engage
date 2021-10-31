//
//  HomeBaseViewController.swift
//
//
//  Created by CASPERON on 16/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class HomeBaseViewController: UIViewController,UIScrollViewDelegate ,CAPSPageMenuDelegate, GeneralStatusListViewControllerDelegate{

    
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var chatsLbl: UILabel!
    @IBOutlet weak var callsLbl: UILabel!
    @IBOutlet weak var settingsLbl: UILabel!
    
    @IBOutlet weak var BottomStackView: UIStackView!
    @IBOutlet weak var chat_count: UILabel!
    @IBOutlet weak var statusmarkerImg: UIImageView!
    
    @IBOutlet weak var baseview: UIView!
    
    var pageMenu : CAPSPageMenu?
    
    var currentIndex:Int = Int()
    var statusBarHide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationListener()
        setNavigationController()
       let codeLang = languageHandler.ApplicationLanguage()
        if codeLang.contains("ar"){
            BottomStackView.semanticContentAttribute = .forceLeftToRight
        }
        statusLbl.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.semibold)
        chatsLbl.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.semibold)
        callsLbl.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.semibold)
        settingsLbl.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.semibold)
        
        self.reloadChat()
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHide
    }

    func isStatusBarHidden(_ value: Bool) {
        statusBarHide = value
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func reloadChat(){
        chat_count.isHidden = true
        chat_count.frame.x = chatBtn.layer.frame.x + chatBtn.layer.frame.size.width - 5
        chat_count.layer.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9).cgColor
        chat_count.layer.cornerRadius = chat_count.frame.size.width/2
        
        chat_count.font = UIFont.systemFont(ofSize: 10.0)
        chat_count.adjustsFontSizeToFitWidth = true
        
        chat_count.text = "\(Themes.sharedInstance.getUnreadChatCount(false))"
        chat_count.isHidden = chat_count.text == "0"
        
        var NotViewedShow = false
        let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])

        let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_initiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
        if(chatintiatedDetailArr.count > 0)
        {
            for i in 0..<chatintiatedDetailArr.count
            {
                let Reponse_Dict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject

                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "user_common_id"))
                let is_mute = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "is_mute"))

                if(id != Themes.sharedInstance.Getuser_id() && is_mute != "1")
                {
                    let P1:NSPredicate = NSPredicate(format: "from = %@", id)
                    let fetch_predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1])

                    let ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_one_one, SortDescriptor: "timestamp", predicate: fetch_predicate, Limit: 0) as! NSArray
                    if(ChatArr.count > 0)
                    {
                        for i in 0 ..< ChatArr.count {
                            let ResponseDict = ChatArr[i] as! NSManagedObject
                            let not_viewed = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_viewed"))

                            if(not_viewed == "")
                            {
                                NotViewedShow = true
                            }

                        }
                    }
                }

            }
        }
        if(NotViewedShow)
        {
            statusmarkerImg.isHidden = false
        }
        else
        {
            statusmarkerImg.isHidden = true
        }
    }
    
    func setThemeColor(Lbl:UILabel)
    {
        Lbl.textColor = CustomColor.sharedInstance.themeColor


     }
    func ClearColour()
    {
        statusLbl.textColor=UIColor.black
        chatsLbl.textColor=UIColor.black
        callsLbl.textColor=UIColor.black
        settingsLbl.textColor=UIColor.black
        
     }
    
    func deselectAllBtns()
    {
        statusBtn.setImage(#imageLiteral(resourceName: "status"), for: UIControl.State.normal)
        chatBtn.setImage(#imageLiteral(resourceName: "chatimage"), for: UIControl.State.normal)
        callBtn.setImage(#imageLiteral(resourceName: "contacts"), for: UIControl.State.normal)
        settingBtn.setImage(#imageLiteral(resourceName: "settings"), for: UIControl.State.normal)
        
        statusBtn.tintColor = UIColor.black
        chatBtn.tintColor = UIColor.black
        callBtn.tintColor = UIColor.black
        settingBtn.tintColor = UIColor.black
    }
    
    func setNavigationController(){
       setViewControllers()
     }
    func setViewControllers(){
        
        var controllerArray : [UIViewController] = []
        
        
        let statusVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GeneralStatusListViewController") as! GeneralStatusListViewController
        statusVC.delegate = self
        statusVC.title = "Status"

        let chatsVC:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatsViewController") as! ChatsViewController
        chatsVC.title = "Chats"
        
        let callsVC:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallLogVCID") as! CallLogVC
        callsVC.title = "Calls"
        
         let settingsVC:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.title = "Settings"

        
        controllerArray.append(statusVC)
        controllerArray.append(chatsVC)
        controllerArray.append(callsVC)
        controllerArray.append(settingsVC)

        let parameters: [CAPSPageMenuOption] = [
        .scrollMenuBackgroundColor(UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)),
        .viewBackgroundColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)),
        .selectionIndicatorColor(UIColor.orange),
        .bottomMenuHairlineColor(UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)),
        .menuItemFont(UIFont.systemFont(ofSize: 13.0)),
        .menuHeight(0.0),
        .menuItemWidth(90.0),
        .centerMenuItems(true),.hideTopMenuBar(false)
        ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.frame.width, height: self.baseview.frame.origin.y))  , pageMenuOptions: parameters)
            
            self.addChild(self.pageMenu!)
            self.view.addSubview(self.pageMenu!.view)
            self.pageMenu!.didMove(toParent: self)
            
            self.getBtnIndex(currentIndx: 1)
            let indexDic = ["index":1]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.getPageIndex), object: nil, userInfo: indexDic)
            self.pageMenu?.controllerScrollView.isScrollEnabled = false
            self.pageMenu?.controllerScrollView.delegate = self
        }
        self.ClearColour()
    }
  
    
       func getBtnIndex(currentIndx:Int){
 
        print(currentIndx)
        self.deselectAllBtns()
        
        if statusBtn.tag == currentIndx{
            self.ClearColour()
            self.setThemeColor(Lbl: statusLbl)
            statusBtn.setImage(#imageLiteral(resourceName: "selectedstatus"), for: UIControl.State.normal)
            statusBtn.tintColor = CustomColor.sharedInstance.themeColor
        }
        else if chatBtn.tag == currentIndx{
            self.ClearColour()
            self.setThemeColor(Lbl: chatsLbl)
            chatBtn.setImage(#imageLiteral(resourceName: "selectedchats"), for: UIControl.State.normal)
            chatBtn.tintColor = CustomColor.sharedInstance.themeColor

        }
        else if callBtn.tag == currentIndx{
            self.ClearColour()
            self.setThemeColor(Lbl: callsLbl)
            callBtn.setImage(#imageLiteral(resourceName: "selectedcontacts"), for: UIControl.State.normal)
            callBtn.tintColor = CustomColor.sharedInstance.themeColor

        }
        else if settingBtn.tag == currentIndx{
            self.ClearColour()
            self.setThemeColor(Lbl: settingsLbl)
            settingBtn.setImage(#imageLiteral(resourceName: "selectedsettings"), for: UIControl.State.normal)
            settingBtn.tintColor = CustomColor.sharedInstance.themeColor

        }
    }
   
    func getIndex(notification:Notification){
        if let indexData = notification.userInfo?["index"] as? Int {
            getBtnIndex(currentIndx: indexData)
            
            currentIndex = pageMenu!.currentPageIndex
            if currentIndex > indexData{
                currentIndex = indexData
                didTapGoToLeft()
                
            }
                
            else if currentIndex < indexData{
                currentIndex = indexData
                didTapGoToRight()
            }

            
        }
    }
    func didTapGoToLeft() {
        pageMenu?.controllerScrollView.isScrollEnabled = false
         if currentIndex >= 0 {
            for i in 0..<pageMenu!.controllerArray.count{
                pageMenu!.controllerArray[i].viewWillDisappear(true)
            }
            pageMenu!.moveToPage(currentIndex)
            currentIndex = pageMenu!.currentPageIndex
            getBtnIndex(currentIndx: currentIndex)
        }
        pageMenu?.controllerScrollView.isScrollEnabled = false

    }
    
    func didTapGoToRight() {
        pageMenu?.controllerScrollView.isScrollEnabled = false
        
        if currentIndex < pageMenu!.controllerArray.count {
            for i in 0..<pageMenu!.controllerArray.count{
               pageMenu!.controllerArray[i].viewWillDisappear(true)
            }
            pageMenu!.moveToPage(currentIndex)
            currentIndex = pageMenu!.currentPageIndex
            getBtnIndex(currentIndx: currentIndex)
            
            
        }
        pageMenu?.controllerScrollView.isScrollEnabled = false

    }
   
  override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_scrollView: UIScrollView) {
        print(_scrollView.contentOffset.x)
     }
    @IBAction func bottomViewButtonAction(sender: AnyObject){
        
        print(currentIndex)
        
        currentIndex = pageMenu!.currentPageIndex
        if currentIndex > sender.tag{
            currentIndex = sender.tag
            
            didTapGoToLeft()
            
        }
            
        else if currentIndex < sender.tag{
            currentIndex = sender.tag
            didTapGoToRight()
        }
            
        else{
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadChat()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.getPageIndex), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.getIndex(notification: notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reloadChat()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}


extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
