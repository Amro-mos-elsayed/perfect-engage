//
//  WallPaperOptionVC.swift
//
//
//  Created by Casperon iOS on 08/11/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos
import Alamofire

class WallPaperOptionVC: UIViewController, colorcode, color ,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var Datasource : [String : Any] = [:]
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        updateTable()
        
        // Do any additional setup after loading the view.
    }
    
    func updateTable() {
        
        Datasource  = ["0" : NSLocalizedString("Gallery", comment: "note") , "1" : NSLocalizedString("Solid Colors", comment: "not"), "2" : NSLocalizedString("Default", comment: "note"), "3" : NSLocalizedString("No Wallpaper", comment: "note")]
        
        table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.pop(animated: true)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Datasource.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = Datasource["\(indexPath.row)"] as? String
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        
        switch indexPath.row {
        case 0:
            print("\(indexPath.row)")
            cell.imageView?.image = imageWithImage(image: #imageLiteral(resourceName: "gallery_ic"))
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .black
            break
        case 1:
            print("\(indexPath.row)")
            cell.imageView?.image = imageWithImage(image: #imageLiteral(resourceName: "solid_color"))
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .black
            break
        case 2:
            print("\(indexPath.row)")
            cell.imageView?.image = imageWithImage(image: #imageLiteral(resourceName: "default"))
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            break
        case 3:
            print("\(indexPath.row)")
            cell.imageView?.image = imageWithImage(image: #imageLiteral(resourceName: "no_wallpaper"))
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            break
        default:
            break
        }
        return cell
    }
    
    func imageWithImage(image:UIImage)->UIImage{
        let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 30), false, 2.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.row {
        case 0:
            print("\(indexPath.row)")
            let pickerController = DKImagePickerController()
            pickerController.singleSelect = true
            pickerController.maxSelectableCount = 1
            pickerController.assetType = .allPhotos
            pickerController.sourceType = .photo
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                if(assets.count > 0)
                {
                    assets[0].originalAsset?.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
                        if(input != nil)
                        {
                            let image:UIImage =  (input?.displaySizeImage)!
                            print(image)
                            let url = ("\((input?.fullSizeImageURL?.absoluteString)!)" as NSString)
                            let WallPaperPreviewVC = self.storyboard?.instantiateViewController(withIdentifier: "WallPaperPreviewVCID") as! WallPaperPreviewVC
                            WallPaperPreviewVC.delegate = self
                            WallPaperPreviewVC.isImage = true
                            WallPaperPreviewVC.url = url as String
                            WallPaperPreviewVC.Image = image
                            WallPaperPreviewVC.asset = assets[0]
                            self.presentView(WallPaperPreviewVC, animated: true)
                        }
                    }
                }
            }
            self.presentView(pickerController, animated: true)
            break
        case 1:
            print("\(indexPath.row)")
            let WallPaperSolidColorVC = self.storyboard?.instantiateViewController(withIdentifier: "WallPaperSolidColorVCID") as! WallPaperSolidColorVC
            WallPaperSolidColorVC.delegate = self
            self.pushView(WallPaperSolidColorVC, animated: true)
            break
        case 2:
            print("\(indexPath.row)")
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString:Themes.sharedInstance.Getuser_id() , attribute: "user_id", UpdationElements: ["wallpaper_type":"default", "wallpaper" : ""])
            self.view.makeToast(message: "Wallpaper changed to default", duration: 1, position: HRToastActivityPositionDefault)
            break
        case 3:
            print("\(indexPath.row)")
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString:Themes.sharedInstance.Getuser_id() , attribute: "user_id", UpdationElements: ["wallpaper_type":"no_wallpaper", "wallpaper" : ""])
            self.view.makeToast(message: "Wallpaper removed", duration: 1, position: HRToastActivityPositionDefault)
            break
        default:
            break
        }
    }
    func colorcode(code:String)
    {
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString:Themes.sharedInstance.Getuser_id() , attribute: "user_id", UpdationElements: ["wallpaper_type":"color", "wallpaper" : code])
        
        self.view.makeToast(message: "Wallpaper changed to solid color", duration: 1, position: HRToastActivityPositionDefault)
    }
    
    func url(url:String, asset: DKAsset)
    {
        
        asset.originalAsset?.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
            let image:UIImage =  (input?.displaySizeImage)!.fixOrientation()
            print(image)
            let url = "\((input?.fullSizeImageURL?.absoluteString)!)"
            let imageURL:URL = URL(string:url)!
            
            var documentsURL = CommondocumentDirectory().appendingPathComponent(Constant.sharedinstance.wallpaperpath)

            if (!FileManager.default.fileExists(atPath: documentsURL.path, isDirectory: nil)) {
                try? FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            documentsURL.appendPathComponent("wallpaper.\(imageURL.pathExtension.lowercased())")
            
            
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString:Themes.sharedInstance.Getuser_id() , attribute: "user_id", UpdationElements: ["wallpaper_type":"image", "wallpaper" : ""])
            try? FileManager.default.removeItem(at: documentsURL)
            
            var data : Data!
            
            if let jpegData = image.jpeg {
                data = jpegData
            }
            if let pngData = image.png {
                data = pngData
            }
            if(data != nil)
            {
                let image1 = data.uiImage
                data = Themes.sharedInstance.compressTo(1, image1!)!
                try? data.write(to: documentsURL)
                
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString:Themes.sharedInstance.Getuser_id() , attribute: "user_id", UpdationElements: ["wallpaper_type":"image", "wallpaper" : documentsURL.absoluteString])
                
                self.view.makeToast(message: "Wallpaper changed", duration: 1, position: HRToastActivityPositionDefault)
            }
            
            
        }
        
        
    }
    
}

extension UIImage {
    var jpeg: Data? {
        return self.jpegData(compressionQuality: 1)
    }
    var png: Data? {
        return self.pngData()
    }
}



extension Data {
    var uiImage: UIImage? {
        return UIImage(data: self)
    }
}


