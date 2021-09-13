//
//  SearchBarViewController.swift
//
//
//  Created by CASPERON on 27/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
protocol SearchDelegate : class {
    
    func didSelectLocation(countryName:String , countryCode:String)
    
    
}

class SearchBarViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    
    @IBOutlet weak var countryTable: UITableView!
    @IBOutlet weak var countrySearchController: UISearchBar!
    var searchArray = [String]()
    weak var delegate:SearchDelegate!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        countrySearchController.backgroundImage = UIImage()
        for subView in countrySearchController.subviews {
            for secondLevelSubview in subView.subviews{
                if(secondLevelSubview.isKind(of:UITextField.self)){
                    if let searchBarTextField:UITextField = secondLevelSubview as? UITextField  {
                        searchBarTextField.becomeFirstResponder()
                        searchBarTextField.textColor = CustomColor.sharedInstance.themeColor
                        break;
                    }
                    
                }
                
            }
        }
        countrySearchController.delegate  = self
        countryTable.reloadData()
        let cancelButtonAttributes: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [NSAttributedString.Key : AnyObject], for: UIControl.State.normal)
        countrySearchController.barTintColor = CustomColor.sharedInstance.themeColor
        
        countrySearchController.showsCancelButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let cancelButtonAttributes: NSDictionary = [NSAttributedString.Key.foregroundColor: CustomColor.sharedInstance.themeColor]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [NSAttributedString.Key : AnyObject], for: UIControl.State.normal)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(countrySearchController.text != ""){
            return searchArray.count
        }else{
            return Themes.sharedInstance.codename.count;
        }
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = countryTable.dequeueReusableCell(withIdentifier: "SearchBarTableViewCell") as! SearchBarTableViewCell
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell.textLabel?.text = ""
        cell.textLabel?.attributedText = NSAttributedString(string: "")
        
        if(countrySearchController.text != ""){
            if(indexPath.row <= searchArray.count-1)
            {
                cell.configureCellWith(searchTerm:countrySearchController.text!, cellText: searchArray[indexPath.row])
            }
            return cell
        }else{
            cell.textLabel?.text! = Themes.sharedInstance.codename[indexPath.row] as! String
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        var getCountry_Code:String = String()
        if(searchArray.count == 0){
            countrySearchController.text = Themes.sharedInstance.codename[indexPath.row] as? String
            getCountry_Code = (Themes.sharedInstance.code[indexPath.row] as? String)!
            
        }else{
            countrySearchController.text = searchArray[indexPath.row]
            getCountry_Code = Themes.sharedInstance.code[Themes.sharedInstance.codename.index(of: countrySearchController.text ?? "lafg")] as! String
            
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if  self.delegate != nil{
            
            delegate.didSelectLocation(countryName:countrySearchController.text!, countryCode: getCountry_Code)
        }
        self.pop(animated: true)
        
    }
    
    //MARK: - SearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        searchArray.removeAll(keepingCapacity: false)
        
        
        let NewText = (searchBar.text! as NSString).replacingCharacters(in: range, with:text)
        print(NewText);
        let range = (NewText as String).startIndex ..< (NewText as String).endIndex
        var searchString = String()
        (NewText as String).enumerateSubstrings(in: range, options: .byComposedCharacterSequences,{ (substring, substringRange, enclosingRange, success) in
            searchString.append(substring!)
            searchString.append("*")
            
        })
        //        (NewText as String).enumerateSubstrings(range, options: .ByComposedCharacterSequences, { (substring, substringRange, enclosingRange, success) in
        //            searchString.appendContentsOf(substring!)
        //            searchString.appendContentsOf("*")
        //        })
        let searchPredicate = NSPredicate(format: "SELF LIKE[c] %@", searchString)
        let array = (Themes.sharedInstance.codename as NSArray).filtered(using: searchPredicate)
        searchArray = array as! [String]
        countryTable.reloadData()
        return true
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.pop(animated: true)
    }
    
}

