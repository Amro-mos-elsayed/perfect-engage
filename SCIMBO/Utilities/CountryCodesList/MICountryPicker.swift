//
//  MICountryPicker.swift
//  MICountryPicker
//
//  Created by Ibrahim, Mustafa on 1/24/16.
//  Copyright © 2016 Mustafa Ibrahim. All rights reserved.
//

import UIKit

class MICountry: NSObject {
    @objc let name: String
    let code: String
    var section: Int?
    let dialCode: String!
    
    init(name: String, code: String, dialCode: String = " - ") {
        self.name = name
        self.code = code
        self.dialCode = dialCode
    }
}

struct Section {
    var countries: [MICountry] = []
    
    mutating func addCountry(_ country: MICountry) {
        if country.name != "Ascension Island"{
            countries.append(country)
        }
    }
}

@objc public protocol MICountryPickerDelegate: class {
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String)
    @objc optional func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,countryFlagImage:UIImage)
    
}

open class MICountryPicker: UITableViewController {
    
    open var customCountriesCode: [String]?
    
    fileprivate lazy var CallingCodes = { () -> [[String: String]] in
        let resourceBundle = Bundle(for: MICountryPicker.classForCoder())
        guard let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist") else { return [] }
        return NSArray(contentsOfFile: path) as! [[String: String]]
    }()
    var searchController: UISearchController!
    fileprivate var filteredList = [MICountry]()
    fileprivate var unsourtedCountries : [MICountry] {
        let locale = Locale.current
        var unsourtedCountries = [MICountry]()
        let countriesCodes = customCountriesCode == nil ? Locale.isoRegionCodes : customCountriesCode!
        
        for countryCode in countriesCodes {
            let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
            let countryData = CallingCodes.filter { $0["code"] == countryCode }
            let country: MICountry
            
            if countryData.count > 0, let dialCode = countryData[0]["dial_code"] {
                country = MICountry(name: displayName!, code: countryCode, dialCode: dialCode)
            } else {
                country = MICountry(name: displayName!, code: countryCode)
            }
            unsourtedCountries.append(country)
        }
        
        return unsourtedCountries
    }
    
    fileprivate var _sections: [Section]?
    fileprivate var sections: [Section] {
        
        if _sections != nil {
            return _sections!
        }
        
        let countries: [MICountry] = unsourtedCountries.map { country in
            let country = MICountry(name: country.name, code: country.code, dialCode: country.dialCode)
            country.section = collation.section(for: country, collationStringSelector: #selector(getter: MICountry.name))
            return country
        }
        
        // create empty sections
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        // put each country in a section
        for country in countries {
            sections[country.section!].addCountry(country)
        }
        
        // sort each section
        for section in sections {
            var s = section
            s.countries = collation.sortedArray(from: section.countries, collationStringSelector: #selector(getter: MICountry.name)) as! [MICountry]
        }
        
        _sections = sections
        
        return _sections!
    }
    fileprivate let collation = UILocalizedIndexedCollation.current()
        as UILocalizedIndexedCollation
    open weak var delegate: MICountryPickerDelegate?
    open var didSelectCountryClosure: ((String, String) -> ())?
    open var didSelectCountryWithCallingCodeClosure: ((String, String, String) -> ())?
    open var showCallingCodes = false
    
    convenience public init(completionHandler: @escaping ((String, String) -> ())) {
        self.init()
        self.didSelectCountryClosure = completionHandler
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        tableView.register(UINib(nibName: "CountryList", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .none
        
        createSearchBar()
        tableView.reloadData()
        
        definesPresentationContext = true
        
    }
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
//        let BackButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: Selector(("didClickBackButton")))
//        self.navigationItem.rightBarButtonItem = BackButton
    }
//
//    func didClickBackButton(){
//        self.navigationController?.dismiss(animated: false, completion: nil)
//    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        searchController.resignFirstResponder()
        searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        
    }
    
    // MARK: Methods
    
    fileprivate func createSearchBar()
    {
        if self.tableView.tableHeaderView == nil
        {
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            tableView.tableHeaderView = searchController.searchBar
            //searchController.hidesNavigationBarDuringPresentation = true
            searchController.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    fileprivate func filter(_ searchText: String) -> [MICountry] {
        filteredList.removeAll()
        
        sections.forEach { (section) -> () in
            section.countries.forEach({ (country) -> () in
                if country.name.count >= searchText.count {
                    let result = country.name.compare(searchText, options: [.caseInsensitive, .diacriticInsensitive], range: searchText.startIndex ..< searchText.endIndex)
                    if result == .orderedSame {
                        filteredList.append(country)
                    }
                }
            })
        }
        
        return filteredList
    }
}

// MARK: - Table view data source

extension MICountryPicker {
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.searchBar.text!.count > 0 {
            return 1
        }
        return sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text!.count > 0 {
            return filteredList.count
        }
        return sections[section].countries.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cell: CountryList = (tableView.dequeueReusableCell(withIdentifier: "cell") as! CountryList)
        
        let cell : CountryList = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CountryList
        
        let country: MICountry!
        if searchController.searchBar.text!.count > 0 {
            country = filteredList[(indexPath as NSIndexPath).row]
        } else {
            country = sections[(indexPath as NSIndexPath).section].countries[(indexPath as NSIndexPath).row]
        }
        
        if showCallingCodes {
            cell.nameCountry.text = country.name + " (" + country.dialCode! + ")"
        } else {
            cell.nameCountry.text = country.name
        }
        
        let bundle = "assets.bundle/"
        cell.imageCountry.image = UIImage(named: bundle + country.code.uppercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil)

        return cell
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !sections[section].countries.isEmpty {
            return self.collation.sectionTitles[section] as String
        }
        return ""
    }
    
    override open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return collation.sectionIndexTitles
    }
    
    override open func tableView(_ tableView: UITableView,
                                 sectionForSectionIndexTitle title: String,
                                 at index: Int)
        -> Int {
            return collation.section(forSectionIndexTitle: index)
    }
}

// MARK: - Table view delegate

extension MICountryPicker {
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.resignFirstResponder()
        searchController.searchBar.resignFirstResponder()
        searchController.navigationController?.isNavigationBarHidden = true
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        let country: MICountry!
        if searchController.searchBar.text!.count > 0 {
            country = filteredList[(indexPath as NSIndexPath).row]
            
        } else {
            country = sections[(indexPath as NSIndexPath).section].countries[(indexPath as NSIndexPath).row]
            
        }
        
        if (self.searchController.isActive){
            self.searchController.isActive = false
            //            self.navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                let bundle = "assets.bundle/"
                let get_Flag = UIImage(named: bundle + country.code.uppercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil)
                
                self.delegate?.countryPicker(self, didSelectCountryWithName: country.name, code: country.code)
                self.delegate?.countryPicker?(self, didSelectCountryWithName: country.name, code: country.code, dialCode: country.dialCode,countryFlagImage:get_Flag!)
                self.didSelectCountryClosure?(country.name, country.code)
                self.didSelectCountryWithCallingCodeClosure?(country.name, country.code, country.dialCode)
            }
            
        }
        else{
            self.searchController.isActive = false
            //            self.navigationController?.popViewController(animated: true)
            
            let bundle = "assets.bundle/"
            let get_Flag = UIImage(named: bundle + country.code.uppercased() + ".png", in: Bundle(for: MICountryPicker.self), compatibleWith: nil)
            
            delegate?.countryPicker(self, didSelectCountryWithName: country.name, code: country.code)
            if country.dialCode == " - "
            {
                
            }
            else{
                delegate?.countryPicker?(self, didSelectCountryWithName: country.name, code: country.code, dialCode: country.dialCode,countryFlagImage:get_Flag!)
                didSelectCountryClosure?(country.name, country.code)
                didSelectCountryWithCallingCodeClosure?(country.name, country.code, country.dialCode)
            }
        }
        
    }
}

// MARK: - UISearchDisplayDelegate

extension MICountryPicker: UISearchResultsUpdating , UISearchBarDelegate
{
    
    public func updateSearchResults(for searchController: UISearchController) {
        filter(searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        print("cancel clikd")
        searchBar.resignFirstResponder()
    }
}

