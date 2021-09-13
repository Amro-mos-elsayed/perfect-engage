//
//  OptionsViewController.swift
//
//
//  Created by CASPERON on 26/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var optionsTableView: UITableView!
    
    
    @IBOutlet weak var headerLabel: UILabel!
    var option:String = String()
    var optionsArray:NSArray = NSArray()
    var socket_optionsArray:NSArray = NSArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        headerLabel.text = option
        optionsArray = [NSLocalizedString("Everyone", comment:"Everyone") , NSLocalizedString("My Contacts", comment:"My Contacts") , NSLocalizedString("Nobody", comment:"Nobody") ]
        let nibName = UINib(nibName: "OptionsTableViewCell", bundle: nil)
        self.optionsTableView.register(nibName, forCellReuseIdentifier: "OptionsTableViewCell")
        optionsTableView.tableFooterView = UIView()
        socket_optionsArray = ["everyone","mycontacts","nobody"]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"OptionsTableViewCell") as! OptionsTableViewCell
        cell.options_Name.text = optionsArray[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Themes.sharedInstance.activityView(View: self.view)
        var socket_option = Themes.sharedInstance.CheckNullvalue(Passed_value: optionsArray[indexPath.row])
        socket_option = socket_option.lowercased().replacingOccurrences(of: " ", with: "")
        var privacy_text:String = ""
        if(option == "Last Seen"){
            privacy_text = "last_seen"
        }else if(option == "Profile"){
            privacy_text = "profile_photo"
        }else if(option == "Status"){
            privacy_text = "status"
        }
        SocketIOManager.sharedInstance.privacySetting(from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()), status: socket_option, privacy:privacy_text)
    }
    func pop(){
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        self.pop(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.pop(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.pop()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
