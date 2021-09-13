//
//  NotificationListViewController.swift
//
//
//  Created by CASPERON on 09/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import AudioToolbox
enum chat_type {
    case group,single,_default
}

class NotificationListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var notifiList_TblView: UITableView!
    
    var Chattype:chat_type!
    var ChoosedIndex:String = String()
    
    var AlerttonesNameArr:NSMutableArray = NSMutableArray()
    var AlerttonesIndexArr:NSMutableArray = NSMutableArray()
    
    var ClassictonesNameArr:NSMutableArray = NSMutableArray()
    var ClassictonesIndexArr:NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Dict:Dictionary = ["single_sound":"1015","group_sound":"1015"]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        let nibName = UINib(nibName: "AccountTableViewCell", bundle: nil)
        notifiList_TblView.register(nibName, forCellReuseIdentifier: "AccountTableViewCell")
        AlerttonesNameArr = ["None","Default","Notes","Aurora","Chord","Circles","Complete","Hello","Input","Keys","Popcorn","Pulse","Synth"]
        AlerttonesIndexArr = ["0", "Default","1012","1005","1001","1007","1008","1009","1010","1011","1013","1015","1014"]
        
        ClassictonesNameArr = ["Bell","Boing","Glass","Time Passing","Tri-Tome","Xylophone"]
        ClassictonesIndexArr = ["1027","1021","1022","1023","1024","1025","1026"]
        notifiList_TblView.reloadData()
        
        getSoundList()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func getSoundList(){
        //        for i in 0..<alertTonesDic.count{
        //            let getSoundName = alertTonesDic.object(forKey:"fgv")
        //
        //
        //        }
        
    }
    
    
    func SaveSound()
    {
        if(Chattype == .group)
        {
            let Dict:Dictionary = ["group_sound":ChoosedIndex]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
            
            
        }
        else if (Chattype == .single)
        {
            let Dict:Dictionary = ["single_sound":ChoosedIndex]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
            
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return  NSLocalizedString("ALERT TONES", comment: "COM")

        }
        else{
            return  NSLocalizedString("CLASSIC", comment: "COM")

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            
            
            return AlerttonesNameArr.count
        }
        else
        {
            return ClassictonesNameArr.count
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell:AccountTableViewCell = notifiList_TblView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") as! AccountTableViewCell
        if(indexPath.section == 0)
        {
            if( ChoosedIndex == "\(AlerttonesIndexArr[indexPath.row])")
            {
                cell.accessoryType = .checkmark
            }
            else
            {
                cell.accessoryType = .none
            }
            
            cell.optionas_Lbl.text = "\(AlerttonesNameArr[indexPath.row])"
        }
        else
        {
            if( ChoosedIndex == "\(ClassictonesIndexArr[indexPath.row])")
            {
                cell.accessoryType = .checkmark
                
            }
            else
            {
                cell.accessoryType = .none
                
            }
            cell.optionas_Lbl.text = "\(ClassictonesNameArr[indexPath.row])"
        }
        return cell
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.sharedInstance.player?.stop()
        if(ChoosedIndex != "Default" && Int(ChoosedIndex)! > 1)
        {
            AudioServicesDisposeSystemSoundID (UInt32(ChoosedIndex)!);
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        AudioServicesPlaySystemSound(0)
        if(ChoosedIndex != "Default" && Int(ChoosedIndex)! > 1)
        {
            AudioServicesDisposeSystemSoundID (UInt32(ChoosedIndex)!);
        }
        if(indexPath.section == 0)
        {
            ChoosedIndex =  "\(AlerttonesIndexArr[indexPath.row])"
        }
        else
        {
            ChoosedIndex =  "\(ClassictonesIndexArr[indexPath.row])"
        }
        
        if(indexPath.row == 1)
        {
            AppDelegate.sharedInstance.PlayAudio(tone: "notification", type: "caf", isrepeat: false)
            
        }
        else
        {
            let GetSoundID:UInt32 = UInt32(ChoosedIndex)!
            print(GetSoundID)
            AudioServicesPlaySystemSound(GetSoundID)
        }
        tableView.reloadData()
    }
    
    
    
    
    @IBAction func saveAction(_ sender: UIButton)
    {
        SaveSound()
        self.pop(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
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
    
}

