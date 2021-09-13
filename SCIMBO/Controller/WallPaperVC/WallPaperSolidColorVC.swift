//
//  WallPaperSolidColorVC.swift
//
//
//  Created by Casperon iOS on 08/11/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

@objc protocol colorcode : class {
    @objc optional func colorcode(code:String)
}

class WallPaperSolidColorVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, color {
    
    
    weak var delegate :colorcode?
    @IBOutlet weak var collection: UICollectionView!
    var datasource : NSArray = NSArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        datasource = ["#212F3C", "#839192", "#CA6F1E", "#F5B041", "#82E0AA", "#5DADE2", "#A569BD", "#F5B7B1", "#D98880", "#0B5345"]
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        self.pop(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collection_Cell = collection.dequeueReusableCell(withReuseIdentifier: "SolidColorCellID", for: indexPath as IndexPath) as! SolidColorCell
        collection_Cell.colorView.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: datasource[indexPath.item] as! String)
        return collection_Cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let WallPaperPreviewVC = self.storyboard?.instantiateViewController(withIdentifier: "WallPaperPreviewVCID") as! WallPaperPreviewVC
        WallPaperPreviewVC.delegate = self
        WallPaperPreviewVC.isImage = false
        WallPaperPreviewVC.index = indexPath
        self.presentView(WallPaperPreviewVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth/3 - 10, height: collectionViewWidth/3 + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func colorcode(code:String)
    {
        self.delegate?.colorcode!(code: code)
        self.pop(animated: true)
    }
}

