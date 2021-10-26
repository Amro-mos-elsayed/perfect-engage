//
//  MyStatusViewController.swift
//  whatsUpStatus
//
//  Created by raguraman on 02/04/18.
//  Copyright © 2018 raguraman. All rights reserved.
//

import UIKit

protocol MyStatusViewControllerDelegate : class {
    func isStatusBarHidden(_:Bool)
}

class MyStatusViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var MyStatusTableView: UITableView!
    @IBOutlet weak var forwardButton: UIButton!
    var statusBarHidden = false
    var myStatusArray = NSMutableArray()
    var ChatRecorDict = [String : NSMutableArray]()
    let transition = CircularTransition()
    let btn1 = UIButton()
    var center = CGPoint()
    var selectedStatusArray = [IndexPath]()
    weak var delegate: MyStatusViewControllerDelegate?
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationListener()
        center = self.view.center
        MyStatusTableView.dataSource = self
        MyStatusTableView.delegate = self
        MyStatusTableView.allowsMultipleSelectionDuringEditing = true
        registerCell()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideBottomView()
    }
        
    private func registerCell(){
        MyStatusTableView.register(UINib(nibName: "MyStatusListTableViewCell", bundle: nil), forCellReuseIdentifier: "MyStatusListTableViewCell")
        MyStatusTableView.register(UINib(nibName: "MyStatusListFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "MyStatusListFooter")
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = center
        transition.circleColor = .black
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = center
        transition.circleColor = dismissed.view.backgroundColor!
        
        return transition
    }
    
    
    @IBAction func backButtonDidTapped(_ sender: UIButton) {
        self.pop(animated: true)
    }
    @IBAction func editButtonDidTapped(_ sender: UIButton) {
        if bottomView.isHidden == true{
            self.showBottomView()
        }
        else{
            self.hideBottomView()
        }
    }
    
    func hideBottomView()
    {
        editButton.setTitle(NSLocalizedString("Edit", comment: "Edit") , for: .normal)
        
        self.bottomView.frame = CGRect(x: 0, y: self.view.frame.size.height - self.bottomView.frame.size.height, width: self.view.frame.size.width, height: self.bottomView.frame.size.height)
        
        UIView.animate(withDuration: 0.2) {
            self.bottomView.isHidden = true
            self.bottomView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.bottomView.frame.size.height)
        }
        
        MyStatusTableView.setEditing(false, animated: true)
        MyStatusTableView.reloadData()
    }
    
    func showBottomView()
    {
        editButton.setTitle("Done", for: .normal)
        
        forwardButton.setTitleColor(.lightGray, for: .normal)
        deleteButton.setTitleColor(.lightGray, for: .normal)
        forwardButton.isEnabled = false
        deleteButton.isEnabled = false
        bottomView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: bottomView.frame.size.height)
        UIView.animate(withDuration: 0.2) {
            self.bottomView.isHidden = false
            self.bottomView.frame = CGRect(x: 0, y: self.view.frame.size.height - self.bottomView.frame.size.height, width: self.view.frame.size.width, height: self.bottomView.frame.size.height)
        }
        
        MyStatusTableView.setEditing(true, animated: true)
        MyStatusTableView.reloadData()
    }
    
    
    @IBAction func didClickDeleteButton(_ sender: UIButton) {
        if(MyStatusTableView.indexPathsForSelectedRows != nil)
        {
            let Indexpath:[IndexPath] = MyStatusTableView.indexPathsForSelectedRows!
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete \(Indexpath.count) Status Update", style: .destructive) { (action : UIAlertAction) in
                self.deleteStatus()
            }
            let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { (action : UIAlertAction) in
            }
            alert.addAction(deleteAction)
            alert.addAction(CancelAction)
            self.presentView(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func didClickForwardButton(_ sender: UIButton) {
        
        if(MyStatusTableView.indexPathsForSelectedRows != nil)
        {
            let Indexpath:[IndexPath] = MyStatusTableView.indexPathsForSelectedRows!
            let Chat_arr:NSMutableArray = NSMutableArray()
            for i in 0..<Indexpath.count
            {
                let indexpath:IndexPath = Indexpath[i]
                
                let chatobj:UUMessageFrame = self.myStatusArray.object(at: indexpath.row) as! UUMessageFrame
                Chat_arr.add(chatobj)
            }
            if(Chat_arr.count > 0)
            {
                let selectShareVC = storyboard?.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
                selectShareVC.messageDatasourceArr =  Chat_arr
                selectShareVC.isFromForward = true
                selectShareVC.isFromStatus = true
                self.pushView(selectShareVC, animated: true)
            }
        }
        
    }
    
    func deleteStatus()
    {
        if(MyStatusTableView.indexPathsForSelectedRows != nil)
        {
            var Indexpath:[IndexPath] = MyStatusTableView.indexPathsForSelectedRows!
            for i in 0..<Indexpath.count
            {
                print(i)
                
                let indexpath:IndexPath = Indexpath[i]
                self.tableView(MyStatusTableView, didDeselectRowAt: indexpath)
                
                
                let chatobj:UUMessageFrame = self.myStatusArray.object(at: indexpath.row) as! UUMessageFrame
                
                let recordId = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: chatobj.message.doc_id!, returnStr: "recordId")
                
                self.RemoveStatus(status: "2", recordId: recordId)
                
                if(chatobj.message.message_type == "0" || chatobj.message.message_type == "4" || chatobj.message.message_type == "5" || chatobj.message.message_type == "14" || chatobj.message.message_type == "11")
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                }
                else
                    
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                    let predic = NSPredicate(format: "upload_data_id == %@",chatobj.message.thumbnail)
                    
                    let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: chatobj.message.thumbnail, SortDescriptor: nil) as! NSArray
                    if(uploadDetailArr.count > 0)
                    {
                        for i in 0..<uploadDetailArr.count
                        {
                            let uploadDict:NSManagedObject = uploadDetailArr[i] as! NSManagedObject
                            let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                            Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                        }
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")
                    }
                }
                
                let checkmessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "from", FetchString: Themes.sharedInstance.Getuser_id())
                if(!checkmessage)
                {
                    let p1 = NSPredicate(format: "user_common_id = %@", Themes.sharedInstance.Getuser_id())
                    
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_initiated_details, Predicatefromat: p1, Deletestring: "user_common_id", AttributeName: "from")
                }
            }
            
            let indexset = NSMutableIndexSet()
            for index : IndexPath in Indexpath {
                indexset.add(index.row)
            }
            if(self.myStatusArray.count > 0)
            {
                myStatusArray.removeObjects(at: indexset as IndexSet)
                MyStatusTableView.deleteRows(at: Indexpath, with: .fade)
                if(self.myStatusArray.count == 0)
                {
                    self.pop(animated: true)
                    
                }
            }
        }
        self.hideBottomView()
    }
    
    func RemoveStatus(status:String,recordId:String)
    {
        let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"status":status,"recordId":recordId]
        SocketIOManager.sharedInstance.EmitStatusDeletedetails(Dict: param)
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.incomingstatus), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            if(notify.object != nil) {
                let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (notify.object as! NSDictionary).value(forKey: "doc_id"))
                let recordId = Themes.sharedInstance.CheckNullvalue(Passed_value: (notify.object as! NSDictionary).value(forKey: "recordId"))
                
                let messageFrame = (weak.myStatusArray as! [UUMessageFrame]).filter({$0.message.doc_id  == doc_id}).first
                
                if(messageFrame != nil)
                {
                    let index = weak.myStatusArray.index(of: messageFrame!)
                    let indexPath = IndexPath(row: index, section: 0)
                    messageFrame?.message.recordId = recordId
                    messageFrame?.message.message_status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: doc_id, returnStr: "message_status")
                    messageFrame?.message.timestamp = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: doc_id, returnStr: "timestamp")
                    messageFrame?.message.thumbnail = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: doc_id, returnStr: "thumbnail")
                    weak.MyStatusTableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.updateViewCount), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.MyStatusTableView.reloadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}

extension MyStatusViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myStatusArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = MyStatusTableView.dequeueReusableCell(withIdentifier: "MyStatusListTableViewCell") as! MyStatusListTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        cell.viewsLabel.textColor = .blue
        cell.viewsImg.tintColor = .blue
        cell.viewsLabel.textColor = CustomColor.sharedInstance.themeColor
        cell.viewsImg.tintColor = CustomColor.sharedInstance.themeColor
        cell.forwardButton.tintColor = CustomColor.sharedInstance.themeColor
        
        let messageFrame = self.myStatusArray.object(at: indexPath.row) as! UUMessageFrame

        if messageFrame.message.type != MessageType(rawValue: 0){
            cell.statusLabel.isHidden = true
            StatusUploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: cell.userImg, isLoaderShow: false, isGif: false, completion: nil)
        }else{
            cell.statusLabel.isHidden = false
            cell.statusLabel.text = messageFrame.message.payload
            cell.statusLabel.font = UIFont(name: messageFrame.message.theme_font, size: cell.statusLabel.font.pointSize)
            cell.userImg.image = nil
            cell.userImg.backgroundColor = UIColor(hexString: Themes.sharedInstance.CheckNullvalue(Passed_value: (messageFrame.message.theme_color)))
        }
        
        if(messageFrame.message.message_status == "0")
        {
            cell.updatedTimeLabel.text = "🕘 Sending...".localized()
            cell.viewsLabel.isHidden = true
            cell.viewsImg.isHidden = true
            cell.forwardButton.isHidden = true
        }
        else
        {
            
            cell.updatedTimeLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
            cell.viewsLabel.isHidden = false
            cell.viewsImg.isHidden = false
            cell.forwardButton.isHidden = false
        }
        
        let FetchMessageArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: messageFrame.message.msgId!, SortDescriptor: nil) as! NSArray
        if(FetchMessageArr.count > 0)
        {
            let messageObj : NSManagedObject = FetchMessageArr[0] as! NSManagedObject
            let data = messageObj.value(forKey: "viewed_by") as? Data
            let viewedArray =   NSKeyedUnarchiver.unarchiveObject(with: data ?? Data()) as? NSArray
            if(viewedArray != nil)
            {
                if let viewedArray = viewedArray {
                    cell.viewsLabel.text = "\(viewedArray.count)"
                }else{
                    cell.viewsLabel.text = "0"
                }
            }
            else
            {
                cell.viewsLabel.text = "0"
            }
        }
        else
        {
            cell.viewsLabel.text = "0"
        }
        
        if(bottomView.isHidden)
        {
            cell.viewsImg.alpha = 1.0
            cell.viewsLabel.alpha = 1.0
            cell.forwardButton.alpha = 1.0
            cell.forwardButton.isUserInteractionEnabled = true
            cell.viewsButton.isUserInteractionEnabled = true
            cell.selectionStyle = .none
            
        }
        else
        {
            cell.viewsImg.alpha = 0.3
            cell.viewsLabel.alpha = 0.3
            cell.forwardButton.alpha = 0.3
            cell.forwardButton.isUserInteractionEnabled = false
            cell.viewsButton.isUserInteractionEnabled = false
            cell.selectionStyle = .blue
        }
        
        if(indexPath.row == 0 && self.myStatusArray.count == 1)
        {
            cell.topLineView.isHidden = false
            cell.bottomLineView.isHidden = false
            cell.bottomHalfLineView.isHidden = true
        }
        else if(indexPath.row == 0){
            cell.topLineView.isHidden = false
            cell.bottomLineView.isHidden = true
            cell.bottomHalfLineView.isHidden = false
            
        }
        else if(indexPath.row == self.myStatusArray.count - 1){
            cell.topLineView.isHidden = true
            cell.bottomLineView.isHidden = false
            cell.bottomHalfLineView.isHidden = true
            
        }
        else
        {
            cell.topLineView.isHidden = true
            cell.bottomLineView.isHidden = true
            cell.bottomHalfLineView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = MyStatusTableView.dequeueReusableHeaderFooterView(withIdentifier: "MyStatusListFooter") as! MyStatusListFooter
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if bottomView.isHidden{
            self.tableView(tableView, didDeselectRowAt: indexPath)
            let cell = tableView.cellForRow(at: indexPath)
            center = (cell?.convert((cell?.center)!, to: self.view))!
            let vc = storyboard?.instantiateViewController(withIdentifier: "StatusPageViewController") as! StatusPageViewController
            vc.isMyStatus = true
            vc.idArr = Array(self.ChatRecorDict.keys)
            vc.ChatRecorDict = self.ChatRecorDict
            vc.startIndex = indexPath.row
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .custom
            vc.view.backgroundColor = .black
            vc.customDelegate = self
            statusBarHidden = true
            setNeedsStatusBarAppearanceUpdate()
            delegate?.isStatusBarHidden(true)
            self.presentView(vc, animated: true)
        }
        else
        {
            let chatobj:UUMessageFrame = self.myStatusArray.object(at: indexPath.row) as! UUMessageFrame
            if(chatobj.message.recordId == "")
            {
                self.tableView(tableView, didDeselectRowAt: indexPath)
            }
            else
            {
                if(MyStatusTableView.indexPathsForSelectedRows != nil)
                {
                    let indexpath:[IndexPath] = MyStatusTableView.indexPathsForSelectedRows!
                    
                    if(indexpath.count > 0)
                    {
                        
                        forwardButton.isEnabled = true
                        deleteButton.isEnabled = true
                        forwardButton.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)
                        deleteButton.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)
                        
                    }
                    else
                    {
                        forwardButton.isEnabled = false
                        deleteButton.isEnabled = false
                        forwardButton.setTitleColor(.lightGray, for: .normal)
                        deleteButton.setTitleColor(.lightGray, for: .normal)
                    }
                }
                else
                {
                    forwardButton.isEnabled = false
                    deleteButton.isEnabled = false
                    forwardButton.setTitleColor(.lightGray, for: .normal)
                    deleteButton.setTitleColor(.lightGray, for: .normal)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(MyStatusTableView.indexPathsForSelectedRows != nil)
        {
            let indexpath:[IndexPath] = MyStatusTableView.indexPathsForSelectedRows!
            
            if(indexpath.count > 0)
            {
                forwardButton.isEnabled = true
                deleteButton.isEnabled = true
                forwardButton.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)
                deleteButton.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)
                
            }
            else
            {
                forwardButton.isEnabled = false
                deleteButton.isEnabled = false
                forwardButton.setTitleColor(.lightGray, for: .normal)
                deleteButton.setTitleColor(.lightGray, for: .normal)
            }
        }
        else
        {
            forwardButton.isEnabled = false
            deleteButton.isEnabled = false
            forwardButton.setTitleColor(.lightGray, for: .normal)
            deleteButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        let chatobj:UUMessageFrame = self.myStatusArray.object(at: indexPath.row) as! UUMessageFrame
//        if(chatobj.message.recordId == "")
//        {
//            return false
//        }
        //        let cell = self.MyStatusTableView.cellForRow(at: indexPath)
        //        if(cell != nil)
        //        {
        //            let cell1 = cell as! MyStatusListTableViewCell
        //            if(!cell1.forwardButton.isUserInteractionEnabled)
        //            {
        //                cell1.viewsImg.alpha = 1.0
        //                cell1.viewsLabel.alpha = 1.0
        //                cell1.forwardButton.alpha = 1.0
        //                cell1.forwardButton.isUserInteractionEnabled = true
        //                cell1.viewsButton.isUserInteractionEnabled = true
        //            }
        //            else
        //            {
        //                cell1.viewsImg.alpha = 0.3
        //                cell1.viewsLabel.alpha = 0.3
        //                cell1.forwardButton.alpha = 0.3
        //                cell1.forwardButton.isUserInteractionEnabled = false
        //                cell1.viewsButton.isUserInteractionEnabled = false
        //            }
        //        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            self.tableView(MyStatusTableView, didDeselectRowAt: indexPath)
            
            let alert = UIAlertController(title: nil, message: "Delete this Story update? It will also be deleted for everyone who received it.".localized(), preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { (action : UIAlertAction) in
                
                let chatobj:UUMessageFrame = self.myStatusArray.object(at: indexPath.row) as! UUMessageFrame
                
                let recordId = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: chatobj.message.doc_id!, returnStr: "recordId")
                
                self.RemoveStatus(status: "2", recordId: recordId)
                
                if(chatobj.message.message_type == "0" || chatobj.message.message_type == "4" || chatobj.message.message_type == "5" || chatobj.message.message_type == "14" || chatobj.message.message_type == "11")
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                }
                else
                    
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                    let predic = NSPredicate(format: "upload_data_id == %@",chatobj.message.thumbnail)
                    
                    let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: chatobj.message.thumbnail, SortDescriptor: nil) as! NSArray
                    if(uploadDetailArr.count > 0)
                    {
                        for i in 0..<uploadDetailArr.count
                        {
                            let uploadDict:NSManagedObject = uploadDetailArr[i] as! NSManagedObject
                            let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                            Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                        }
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")
                    }
                }
                
                let checkmessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "from", FetchString: Themes.sharedInstance.Getuser_id())
                if(!checkmessage)
                {
                    let p1 = NSPredicate(format: "user_common_id = %@", Themes.sharedInstance.Getuser_id())
                    
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_initiated_details, Predicatefromat: p1, Deletestring: "user_common_id", AttributeName: "from")
                }
                
                
                if(self.myStatusArray.count > 0)
                {
                    self.myStatusArray.removeObject(at: indexPath.row)
                    self.MyStatusTableView.deleteRows(at: [indexPath], with: .fade)
                    if(self.myStatusArray.count == 0)
                    {
                        self.pop(animated: true)
                        
                    }
                }
            }
            let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { (action : UIAlertAction) in
            }
            alert.addAction(deleteAction)
            alert.addAction(CancelAction)
            self.presentView(alert, animated: true, completion: nil)
        }
    }
}

extension MyStatusViewController:MyStatusListTableViewCellDelegate{
    func viewButtonPressed(in Index: IndexPath) {
        self.hideBottomView()
        let cell = self.MyStatusTableView.cellForRow(at: Index)
        center = (cell?.convert((cell?.center)!, to: self.view))!
        let vc = storyboard?.instantiateViewController(withIdentifier: "StatusPageViewController") as! StatusPageViewController
        vc.isMyStatus = true
        vc.idArr = Array(self.ChatRecorDict.keys)
        vc.ChatRecorDict = self.ChatRecorDict
        vc.customDelegate = self
        vc.startIndex = Index.row
        vc.isFromView = true
        statusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        delegate?.isStatusBarHidden(true)
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        vc.view.backgroundColor = .black
        self.presentView(vc, animated: true)
    }
    
    func forwardButtonPressed(in Index: IndexPath) {
        
        let messageFrame = self.myStatusArray.object(at: Index.row) as! UUMessageFrame
        
        let Chat_arr:NSMutableArray = NSMutableArray()
        Chat_arr.add(messageFrame)
        if(Chat_arr.count > 0)
        {
            let selectShareVC = storyboard?.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
            selectShareVC.messageDatasourceArr =  Chat_arr
            selectShareVC.isFromForward = true
            selectShareVC.isFromStatus = true
            self.pushView(selectShareVC, animated: true)
        }
    }
    
}

extension MyStatusViewController : StatusPageViewControllerDelegate {
    
    func DidDismiss() {
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        delegate?.isStatusBarHidden(false)
        self.MyStatusTableView.reloadData()
    }
    
    
    func DidClickDelete(_ messageFrame: UUMessageFrame) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = UIAlertController(title: nil, message: "Delete this Story update? It will also be deleted for everyone who received it.".localized(), preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action : UIAlertAction) in
                
                let chatobj = messageFrame
                
                let recordId = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: chatobj.message.doc_id!, returnStr: "recordId")
                
                self.RemoveStatus(status: "2", recordId: recordId)
                
                if(chatobj.message.message_type == "0" || chatobj.message.message_type == "4" || chatobj.message.message_type == "5" || chatobj.message.message_type == "14" || chatobj.message.message_type == "11")
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                }
                else
                    
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                    let predic = NSPredicate(format: "upload_data_id == %@",chatobj.message.thumbnail)
                    
                    let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: chatobj.message.thumbnail, SortDescriptor: nil) as! NSArray
                    if(uploadDetailArr.count > 0)
                    {
                        for i in 0..<uploadDetailArr.count
                        {
                            let uploadDict:NSManagedObject = uploadDetailArr[i] as! NSManagedObject
                            let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                            Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                        }
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")
                    }
                }
                
                let checkmessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "from", FetchString: Themes.sharedInstance.Getuser_id())
                if(!checkmessage)
                {
                    let p1 = NSPredicate(format: "user_common_id = %@", Themes.sharedInstance.Getuser_id())
                    
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_initiated_details, Predicatefromat: p1, Deletestring: "user_common_id", AttributeName: "from")
                }
                
                
                if(self.myStatusArray.count > 0)
                {
                    let index = self.myStatusArray.index(of: chatobj)
                    self.myStatusArray.removeObject(at: index)
                    self.MyStatusTableView.reloadData()
                    if(self.myStatusArray.count == 0)
                    {
                        self.pop(animated: true)
                        
                    }
                }
            }
            let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { (action : UIAlertAction) in
            }
            alert.addAction(deleteAction)
            alert.addAction(CancelAction)
            self.presentView(alert, animated: true, completion: nil)
        }
    }
}
