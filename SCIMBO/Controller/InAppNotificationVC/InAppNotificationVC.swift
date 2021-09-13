//
//  InAppNotificationVC.swift
//
//
//  Created by MV Anand Casp iOS on 05/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class InAppNotificationVC: UIViewController {
    var Chattype:chat_type!
    var is_sound:Bool = Bool()
    var is_vibrate:Bool = Bool()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        
        
    }
    
    @IBAction func DiclickBack(_ sender: Any) {
        self.pop(animated: true)
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
    
    
    @IBAction func SoundChanged(sender: UISwitch) {
        
        
        let Dict:Dictionary = ["is_sound":sender.isOn]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
        
        
        
    }
    @IBAction func vibrateChanged(sender: UISwitch) {
        let Dict:Dictionary = ["is_vibrate":sender.isOn]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
        
        
        
    }
    
}

extension InAppNotificationVC:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell:UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "CellID")
        Cell.accessoryType = .none
        let switchView = UISwitch(frame: CGRect.zero)
        
        if(indexPath.row == 0)
        {
            
            
            Cell.textLabel?.text = NSLocalizedString("Sounds", comment: "COM")
            Cell.accessoryView = switchView
            switchView.setOn(is_sound, animated: true)
            switchView.addTarget(self, action: #selector(self.SoundChanged(sender:)), for: .valueChanged)
        }
        else  if(indexPath.row == 1)
        {
            Cell.textLabel?.text = NSLocalizedString("Vibrate", comment: "COM")
            Cell.accessoryView = switchView
            switchView.addTarget(self, action: #selector(self.vibrateChanged(sender:)), for: .valueChanged)
            switchView.setOn(is_vibrate, animated: true)
            
        }
        return Cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = UISwitch(frame: CGRect.zero)
        
        
        
    }
}

