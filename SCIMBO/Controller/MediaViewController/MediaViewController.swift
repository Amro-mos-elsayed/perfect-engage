//
//  MediaViewController.swift
//
//
//  Created by CASPERON on 08/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage
import SimpleImageViewer

class MediaViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nodata_detailLbl: UILabel!
    @IBOutlet weak var nodata_Lbl: UILabel!
    @IBOutlet weak var Header_segment: UISegmentedControl!
    var user_common_id:String = String()
    var LinkArray:NSMutableArray=NSMutableArray()
    @IBOutlet weak var detailtableView: UITableView!
    @IBOutlet weak var MediaCollectionView: UICollectionView!
    var DataSourceArr:NSMutableArray = NSMutableArray()
    var payload:NSMutableArray = NSMutableArray()
    var table_index:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        let Nib = UINib(nibName: "MediaCollectionViewCell", bundle: nil)
        MediaCollectionView.register(Nib, forCellWithReuseIdentifier: "MediaCollectionViewCellID")
        MediaCollectionView.dataSource = self
        MediaCollectionView.delegate = self
        
        detailtableView.dataSource = self
        detailtableView.delegate = self
        detailtableView.estimatedRowHeight = 65
        detailtableView.rowHeight = UITableView.automaticDimension
        Header_segment.selectedSegmentIndex = 0
        self.SetValue(index: 0)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func SetValue(index:Int)
    {
        if(DataSourceArr.count > 0)
        {
            DataSourceArr.removeAllObjects()
        }
        nodata_Lbl.isHidden = true
        nodata_detailLbl.isHidden = true
        if(index == 0)
        {
            detailtableView.isHidden = true
            MediaCollectionView.isHidden = false
            let predicate1:NSPredicate =  NSPredicate(format: "user_common_id == %@", user_common_id)
            print(user_common_id)
            let predicate2:NSPredicate =  NSPredicate(format: "upload_type == 1")
            let predicate3:NSPredicate =  NSPredicate(format: "upload_type == 2")
            let compunPred = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate2,predicate3])
            var CompoundPredicate:NSCompoundPredicate!
            CompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,compunPred])
            let fetchMediaRecordArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Upload_Details, SortDescriptor: nil, predicate: CompoundPredicate, Limit: 0) as! NSArray
            if(fetchMediaRecordArr.count > 0)
            {
                for i in 0..<fetchMediaRecordArr.count
                {
                    let objRecord:NSManagedObject = fetchMediaRecordArr[i] as! NSManagedObject
                    let objmediaRecord:mediarecord = mediarecord()
                    objmediaRecord.upload_status = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "upload_status"))
                    objmediaRecord.download_status = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "download_status"))
                    objmediaRecord.is_uploaded = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "is_uploaded"))
                    objmediaRecord.upload_data_id = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "upload_data_id"))
                    objmediaRecord.total_byte_count = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "total_byte_count"))
                    objmediaRecord.to_id = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "to_id"))
                    objmediaRecord.upload_type = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "upload_type"))
                    
                    
                    objmediaRecord.timestamp = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "thumbnail", fetchString: objmediaRecord.upload_data_id, returnStr: "timestamp")
                    objmediaRecord.compressed_data = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "compressed_data"))
                    
                    if(objmediaRecord.upload_type == "1")
                    {
                        if(objmediaRecord.is_uploaded == "1")
                        {
                            
                            objmediaRecord.upload_Path = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: objmediaRecord.upload_data_id as String, upload_detail: "upload_Path")! as! String
                            objmediaRecord.isserverPath = false
                            
                        }
                        else
                        {
                            //                        if(objmediaRecord.download_status == "2")
                            //                        {
                            //                             objmediaRecord.upload_Path = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "upload_Path"))
                            //                            objmediaRecord.isserverPath = false
                            //
                            //                         }
                            //                        else
                            //                        {
                            
                            objmediaRecord.serverpath = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "serverpath"))
                            objmediaRecord.upload_Path = ""
                            objmediaRecord.isserverPath = true
                            
                            //                   }
                        }
                    }
                    if(objmediaRecord.upload_type == "2")
                    {
                        if(objmediaRecord.is_uploaded == "1")
                        {
                            objmediaRecord.upload_Path = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: objmediaRecord.upload_data_id as String, upload_detail: "upload_Path")! as! String
                            objmediaRecord.isserverPath = false
                        }
                        else
                        {
                            if(objmediaRecord.download_status == "2")
                            {
                                objmediaRecord.upload_Path = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: objmediaRecord.upload_data_id as String, upload_detail: "upload_Path")! as! String
                                objmediaRecord.isserverPath = false
                                
                            }
                            else
                            {
                                
                                objmediaRecord.serverpath = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "serverpath"))
                                objmediaRecord.upload_Path = ""
                                objmediaRecord.isserverPath = true
                            }
                        }
                    }
                    
                    DataSourceArr.add(objmediaRecord)
                    
                }
                if(DataSourceArr.count > 0)
                {
//                    var SortArray:NSArray=NSArray(array: DataSourceArr)
//                    let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                    DataSourceArr = NSMutableArray(array: DataSourceArr.filter{($0 as? mediarecord != nil)}.sorted{(($0 as! mediarecord).timestamp > ($1 as! mediarecord).timestamp)})
//                    DataSourceArr=NSMutableArray(array: SortArray)
                }
                print(MediaCollectionView.frame)
                MediaCollectionView.reloadData()
            }
            else
            {
                nodata_Lbl.isHidden = false
                nodata_detailLbl.isHidden = false
                
                MediaCollectionView.isHidden = true
                nodata_Lbl.text = "No Media"
                nodata_detailLbl.text = "Tap + to add media"
                
            }
        }
        if(index > 0)
        {
            MediaCollectionView.isHidden = true
            detailtableView.isHidden = false
            if(index == 2)
            {
                table_index = index
                let tableNib = UINib(nibName: "DocumentTableViewCell", bundle: nil)
                detailtableView.register(tableNib, forCellReuseIdentifier: "DocumentTableViewCellID")
                detailtableView.isHidden = false
                let predicate1:NSPredicate =  NSPredicate(format: "user_common_id == %@", user_common_id)
                let predicate2:NSPredicate =  NSPredicate(format: "upload_type == 6")
                var CompoundPredicate:NSCompoundPredicate!
                CompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
                let fetchMediaRecordArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Upload_Details, SortDescriptor: nil, predicate: CompoundPredicate, Limit: 0) as! NSArray
                if(fetchMediaRecordArr.count > 0)
                {
                    for i in 0..<fetchMediaRecordArr.count
                    {
                        let objRecord:NSManagedObject = fetchMediaRecordArr[i] as! NSManagedObject
                        let objmediaRecord:mediarecord = mediarecord()
                        objmediaRecord.upload_status = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "upload_status"))
                        objmediaRecord.download_status = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "download_status"))
                        objmediaRecord.is_uploaded = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "is_uploaded"))
                        objmediaRecord.upload_data_id = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "upload_data_id"))
                        objmediaRecord.total_byte_count = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "total_byte_count"))
                        objmediaRecord.to_id = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "to_id"))
                        objmediaRecord.user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "user_common_id"))
                        objmediaRecord.doc_type = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "doc_type"))
                        objmediaRecord.doc_pagecount = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "doc_pagecount"))
                        objmediaRecord.doc_name = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "doc_name"))
                        objmediaRecord.timestamp = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "thumbnail", fetchString: objmediaRecord.upload_data_id, returnStr: "timestamp")
                        objmediaRecord.compressed_data = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "compressed_data"))
                        objmediaRecord.upload_type = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "upload_type"))
                        
                        if(objmediaRecord.upload_type == "6" || objmediaRecord.upload_type == "20")
                        {
                            if(objmediaRecord.is_uploaded == "1")
                            {
                                
                                objmediaRecord.upload_Path = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: objmediaRecord.upload_data_id as String, upload_detail: "upload_Path")! as! String
                                objmediaRecord.isserverPath = false
                            }
                            else
                            {
                                if(objmediaRecord.download_status == "2")
                                {
                                    objmediaRecord.upload_Path = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: objmediaRecord.upload_data_id as String, upload_detail: "upload_Path")! as! String
                                    objmediaRecord.isserverPath = false
                                    
                                }
                                
                            }
                        }
                        if(objmediaRecord.upload_type == "2")
                        {
                            if(objmediaRecord.is_uploaded == "1")
                            {
                                objmediaRecord.upload_Path = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: objmediaRecord.upload_data_id as String, upload_detail: "upload_Path")! as! String
                                objmediaRecord.isserverPath = false
                            }
                            else
                            {
                                if(objmediaRecord.download_status == "2")
                                {
                                    objmediaRecord.upload_Path = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: objmediaRecord.upload_data_id as String, upload_detail: "upload_Path")! as! String
                                    objmediaRecord.isserverPath = false
                                    
                                }
                                else
                                {
                                    
                                    objmediaRecord.serverpath = Themes.sharedInstance.CheckNullvalue(Passed_value: objRecord.value(forKey: "serverpath"))
                                    objmediaRecord.upload_Path = ""
                                    objmediaRecord.isserverPath = true
                                }
                            }
                        }
                        
                        DataSourceArr.add(objmediaRecord)
                        
                    }
                    if(DataSourceArr.count > 0)
                    {
//                        var SortArray:NSArray=NSArray(array: DataSourceArr)
//                        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
//                        SortArray = SortArray.sortedArray(using: [descriptor]) as NSArray
                        DataSourceArr=NSMutableArray(array: DataSourceArr.filter{($0 as? mediarecord != nil)}.sorted{(($0 as! mediarecord).timestamp > ($1 as! mediarecord).timestamp)})
                    }
                    detailtableView.reloadData()
                }
                else
                {
                    nodata_Lbl.isHidden = false
                    nodata_detailLbl.isHidden = false
                    detailtableView.isHidden = true
                    nodata_Lbl.text = "No Documents"
                    nodata_detailLbl.text = "Tap + to add document"
                }
            }
            if(index == 1)
            {
                LinkArray = []
                table_index = index
                let linkNib = UINib(nibName: "MediaTableViewCell", bundle: nil)
                detailtableView.register(linkNib, forCellReuseIdentifier: "MediaTableViewCell")
                var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: user_common_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
                if(ChatArr.count > 0)
                {
                    let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                    ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
                    for i in 0 ..< ChatArr.count {
                        let ResponseDict = ChatArr[i] as! NSManagedObject
                        let messageType:String = ResponseDict.value(forKey: "type") as! String
                        if(messageType == "4"){
                            
                            let msg:String = ResponseDict.value(forKey: "payload") as! String
                            let ChekLocation:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")!))
                            
                            if(ChekLocation)
                            {
                                
                                let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")!), SortDescriptor: nil) as! NSArray
                                
                                //let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                                //let object:NSManagedObject = LinkArray[i] as! NSManagedObject
                                LinkArray.add(LocationArr[0])
                                payload.add(msg)
                                
                            }
                        }
                    }
                    if(LinkArray.count > 0){
                        
                        detailtableView.separatorStyle = .none
                        detailtableView.reloadData()
                        
                    }else{
                        nodata_Lbl.isHidden = false
                        nodata_detailLbl.isHidden = false
                        detailtableView.isHidden = true
                        nodata_Lbl.text = "No Links"
                        nodata_detailLbl.text = ""
                    }
                    
                }else{
                    nodata_Lbl.isHidden = false
                    nodata_detailLbl.isHidden = false
                    detailtableView.isHidden = true
                    nodata_Lbl.text = "No Links"
                    nodata_detailLbl.text = ""
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(table_index == 2){
            return 83
        }else if(table_index == 1){
            return UITableView.automaticDimension
        }
        return 0
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataSourceArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let Cell:MediaCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCellID", for: indexPath) as! MediaCollectionViewCell
        guard DataSourceArr.count > indexPath.row else{return Cell}
        let ObjMultiMedia:mediarecord = DataSourceArr[indexPath.row] as! mediarecord
       
        var str:String = "data:image/jpg;base64,";
        
        if ObjMultiMedia.compressed_data.contains("data:image")
        {
            str = ObjMultiMedia.compressed_data
        }
        else
        {
            str = str.appending(ObjMultiMedia.compressed_data)
        }
        
        Cell.MediaImageView.sd_setImage(with: URL(string:str))

        if(ObjMultiMedia.upload_type == "2")
        {
            Cell.play_img.isHidden = false
            Cell.play_img.image = #imageLiteral(resourceName: "playIcon")
        }
        else
        {
            if FileManager.default.fileExists(atPath: ObjMultiMedia.upload_Path) {
                let url = URL(fileURLWithPath: ObjMultiMedia.upload_Path)
                if(url.pathExtension == "gif")
                {
                    Cell.play_img.isHidden = false
                    Cell.play_img.image = #imageLiteral(resourceName: "gifIcon")
                }
                else
                {
                    Cell.play_img.isHidden = true
                }
            }
            else
            {
                if(URL(string: ObjMultiMedia.serverpath)?.pathExtension == "gif")
                {
                    Cell.play_img.isHidden = false
                    Cell.play_img.image = #imageLiteral(resourceName: "gifIcon")
                }
                else
                {
                    Cell.play_img.isHidden = true
                }
            }
        }
        
        return  Cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let ObjMultiMedia:mediarecord = DataSourceArr[indexPath.row] as! mediarecord
        let cell = collectionView.cellForItem(at: indexPath) as! MediaCollectionViewCell
        
        if (ObjMultiMedia.upload_type == "1")
        {
            if(ObjMultiMedia.is_uploaded == "1")
            {
                if(URL(string: ObjMultiMedia.upload_Path)?.pathExtension == "gif")
                {
                    let configuration = ImageViewerConfiguration { config in
                        config.gifimageView = cell.MediaImageView
                        config.imagePath = URL(fileURLWithPath: ObjMultiMedia.upload_Path)

                    }
                    self.presentView(ImageViewerController(configuration: configuration), animated: true)
                }
                else
                {
                    let configuration = ImageViewerConfiguration { config in
                        config.imageView = cell.MediaImageView
                    }
                    self.presentView(ImageViewerController(configuration: configuration), animated: true)
                }
                
                
            }
            else
            {
                let configuration = ImageViewerConfiguration { config in
                    config.imageView = cell.MediaImageView
                }
                self.presentView(ImageViewerController(configuration: configuration), animated: true)
            }
            
        }
        else if (ObjMultiMedia.upload_type == "2")
        {
            if(ObjMultiMedia.isserverPath)
            {
                let videoPath:String! = ObjMultiMedia.serverpath
                let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(videoPath!))
                let player = AVPlayer(url: videoURL! )
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.presentView(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
            else
            {
                let videoPath:String! = ObjMultiMedia.upload_Path
                let videoURL = URL(fileURLWithPath: videoPath)
                let player = AVPlayer(url: videoURL )
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.presentView(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(table_index == 2){
            return 1
        }else if(table_index == 1){
            return LinkArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(table_index == 2){
            return DataSourceArr.count
        }else if(table_index == 1){
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(table_index == 2){
            let Cell:DocumentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCellID", for: indexPath) as! DocumentTableViewCell
            let ObjMultiMedia:mediarecord = DataSourceArr[indexPath.row] as! mediarecord
            
            var DetailStr:String = ""
            if(ObjMultiMedia.doc_type == "1")
            {
                var str:String = "data:image/jpg;base64,";
                if ObjMultiMedia.compressed_data.contains("data:image")
                {
                    str = ObjMultiMedia.compressed_data
                }
                else
                {
                    str = str.appending(ObjMultiMedia.compressed_data)
                }
                
                Cell.doc_img.sd_setImage(with: URL(string:str))
                let Gettotalbyte:String = Themes.sharedInstance.transformedValue(ObjMultiMedia.total_byte_count) as! String
                var Extension:NSString =  NSString()
                if(ObjMultiMedia.isserverPath)
                {
                    Extension = ObjMultiMedia.serverpath as NSString
                }
                else
                {
                    Extension = ObjMultiMedia.upload_Path as NSString
                    
                }
                DetailStr = "\(ObjMultiMedia.doc_pagecount) pages ● \(Gettotalbyte) ● \((Extension as NSString).pathExtension.uppercased())"
                
            }
            else
            {
                Cell.doc_img.image = #imageLiteral(resourceName: "docicon")
                let Gettotalbyte:String = Themes.sharedInstance.transformedValue(ObjMultiMedia.total_byte_count) as! String
                var Extension:NSString =  NSString()
                if(ObjMultiMedia.isserverPath)
                {
                    Extension = ObjMultiMedia.serverpath as NSString
                }
                else
                {
                    Extension =  ObjMultiMedia.upload_Path as NSString
                }
                
                DetailStr = " \(Gettotalbyte) ● \((Extension as NSString).pathExtension.uppercased())"
            }
            Cell.document_nameLbl.text = ObjMultiMedia.doc_name
            Cell.infoLbl.text = DetailStr
            return Cell
        }else if(table_index == 1){
            let Cell:MediaTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell", for: indexPath) as! MediaTableViewCell
            let object:NSManagedObject = LinkArray[indexPath.section] as! NSManagedObject
            var title:String = Themes.sharedInstance.CheckNullvalue(Passed_value: object.value(forKey: "title"))
            if let range = title.range(of:"{"){
                let firstPart = title[(title.startIndex)..<range.lowerBound]
                title=String(firstPart)
            }
            Cell.title.text = title
            var desc:String = Themes.sharedInstance.CheckNullvalue(Passed_value: object.value(forKey: "desc"))
            if let range = desc.range(of:"{"){
                let firstPart = desc[(desc.startIndex)..<range.lowerBound]
                desc=String(firstPart)
            }
            
            Cell.desc.text = desc
            Cell.link_image.sd_setImage(with:URL(string:(object.value(forKey: "image_url") as! String?)!), placeholderImage: #imageLiteral(resourceName: "link") )
            Cell.selectionStyle = .none
            return Cell
        }
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(table_index == 2){
            let ObjMultiMedia:mediarecord = DataSourceArr[indexPath.row] as! mediarecord
            var Extension:NSString =  NSString()
            if(ObjMultiMedia.isserverPath)
            {
                Extension = Themes.sharedInstance.getDownloadURL(ObjMultiMedia.serverpath) as NSString
            }
            else
            {
                Extension =  ObjMultiMedia.upload_Path as NSString
            }
            
            let objVC:DocViewController = self.storyboard?.instantiateViewController(withIdentifier: "DocViewControllerID") as! DocViewController
            objVC.webViewTitle = ObjMultiMedia.doc_name
            objVC.webViewURL = Extension as String
            self.pushView(objVC, animated: true)
        }else if(table_index == 1){
            print(indexPath)
            let object:NSManagedObject = LinkArray[indexPath.section] as! NSManagedObject
            let url:String = Themes.sharedInstance.CheckNullvalue(Passed_value: object.value(forKey: "url_str"))
            if(url != "")
            {
                UIApplication.shared.open(URL(string: url)!, options:[:], completionHandler:nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(table_index == 1){
            return 10
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(table_index == 1){
            let header = UIView()
            header.backgroundColor = UIColor.clear
            return header
        }
        return UIView()
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.pop(animated: true)
        
        
    }
    @IBAction func ChangeSegment(_ sender: Any) {
        let segmentobj:UISegmentedControl = sender as!  UISegmentedControl
        self.SetValue(index: segmentobj.selectedSegmentIndex)
        
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

