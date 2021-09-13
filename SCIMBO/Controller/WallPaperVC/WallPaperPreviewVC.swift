//
//  WallPaperPreviewVC.swift
//
//
//  Created by Casperon iOS on 09/11/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import DKImagePickerController

@objc protocol color : class {
    @objc optional func colorcode(code:String)
    @objc optional func url(url:String, asset: DKAsset)
}

class WallPaperPreviewVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate :color?
    @IBOutlet weak var collection: UICollectionView!
    var datasource : NSArray = NSArray()
    var isImage : Bool = false
    var url : String = String()
    var Image : UIImage = UIImage()
    var index : IndexPath = IndexPath()
    var asset : DKAsset?
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        if(!isImage)
        {
            datasource = ["#212F3C", "#839192", "#CA6F1E", "#F5B041", "#82E0AA", "#5DADE2", "#A569BD", "#F5B7B1", "#D98880", "#0B5345"]
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.collection.scrollToItem(at: self.index, at: .left, animated: true)
            })
        }
        collection.isPagingEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(!isImage)
        {
            return datasource.count
        }
        else
        {
            return 1
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collection_Cell = collection.dequeueReusableCell(withReuseIdentifier: "WallPaperPreviewCellID", for: indexPath as IndexPath) as! WallPaperPreviewCell
        if(!isImage)
        {
            collection_Cell.previewImage.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: datasource[indexPath.item] as! String)
            collection_Cell.template.image = #imageLiteral(resourceName: "sample")
            collection_Cell.template.contentMode = .scaleAspectFill
        }
        else
        {
            collection_Cell.previewImage.backgroundColor = UIColor.clear
            collection_Cell.previewImage.image = Image
            collection_Cell.template.image = #imageLiteral(resourceName: "sample1")
        }
        return collection_Cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collection.frame.size.width, height: self.collection.frame.size.height)
    }
    
    
    @IBAction func save(_ sender: Any) {
        if(!isImage)
        {
            let indexPath = self.collection.indexPathsForVisibleItems[0]
            self.delegate?.colorcode!(code: datasource[indexPath.item] as! String)
        }
        else
        {
            self.delegate?.url!(url: url, asset: asset!)
        }
        self.dismissView(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismissView(animated: true, completion: nil)
    }
    
}

