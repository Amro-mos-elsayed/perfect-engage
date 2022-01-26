//
//  BlockedContactsViewController.swift
//
//
//  Created by PremMac on 11/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView
import SDWebImage
import SimpleImageViewer

class BlockedContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var block_tableView: UITableView!
    
    @IBOutlet weak var no_block_contact_view: UIView!
    var favArray:NSMutableArray=NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        let nibName = UINib(nibName: "FavouriteTableViewCell", bundle:nil)
        no_block_contact_view.isHidden = true
        self.block_tableView.register(nibName, forCellReuseIdentifier: "FavouriteTableViewCell")
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func openImage(sender:UIButton){
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem:FavouriteTableViewCell? = block_tableView.cellForRow(at: indexpath as IndexPath) as? FavouriteTableViewCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cellItem?.profileImage
        }
        self.presentView(ImageViewerController(configuration: configuration), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    @IBAction func back_action(_ sender: UIButton) {
        self.pop(animated: true)
    }
    func reloadData(){
        favArray=NSMutableArray()
        
        let blocks = DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: Constant.sharedinstance.Blocked_user) as! [Blocked_user]
        
        _ = blocks.map {
            let ResponseDict = $0
            let favRecord:FavRecord=FavRecord()
            favRecord.id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.id)
            favArray.add(favRecord)
        }
        no_block_contact_view.isHidden = blocks.count > 0
        self.block_tableView.reloadData()
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FavouriteTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "FavouriteTableViewCell") as! FavouriteTableViewCell
        let favRecord:FavRecord=favArray.object(at: indexPath.row) as! FavRecord
        cell.selectionStyle = .none
        cell.nameLbl.setNameTxt(favRecord.id, "single")
        cell.profileImage.setProfilePic(favRecord.id, "single")
        cell.profileImage.tag = indexPath.row
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
        cell.profile.addTarget(self, action: #selector(self.openImage(sender:)), for: .touchUpInside)
        cell.statusLbl.setStatusTxt(favRecord.id)
        cell.statusLbl.isHidden = cell.statusLbl.text == ""
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reloadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
