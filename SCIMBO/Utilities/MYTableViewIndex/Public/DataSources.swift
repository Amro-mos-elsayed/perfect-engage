import UIKit
var CheckBool:Bool=Bool()

protocol Item {}

protocol DataSource {
    
    func numberOfSections() -> Int
    
    func numberOfItemsInSection(_ section: Int) -> Int
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> Item?
    func itemAtIndexPathFilter(_ indexPath: IndexPath) -> AnyObject?
    func titleForHeaderInSection(_ section: Int) -> String?
    mutating func returnFavArr() -> NSMutableArray
    mutating func initwithData()
}

extension String : Item {}

struct CountryDataSource : DataSource {
    fileprivate(set) var sectionsFilter = [[AnyObject]]()
    fileprivate(set) var sections = [[String]]()
    fileprivate(set) var sectionFilter = [[AnyObject]]()
    var favArray:NSMutableArray=NSMutableArray()
    var SortedArr:NSMutableArray=NSMutableArray()
    var namesArray:NSMutableArray=NSMutableArray()
    var filter_ContactArr:NSMutableArray = NSMutableArray()
    fileprivate let collaction = UILocalizedIndexedCollation.current()
    
    init() {
    }
    mutating func initwithData()
    {
        filter_ContactArr = filter_ContactRec
        sectionsFilter=splitFilterContact(NSArray(array: filter_ContactArr) as [AnyObject])
    }
    
    fileprivate func splitFilterContact(_ items: [AnyObject]) -> [[AnyObject]] {
        let collation = UILocalizedIndexedCollation.current()
        var sections = [[AnyObject]](repeating: [], count: collation.sectionTitles.count)
        for i in 0..<items.count{
            let filterObj :FilterContact = items[i] as! FilterContact
            let nameVal = filterObj.name
            var collectItems = [String]()
            collectItems.append(nameVal!)
            let items = collation.sortedArray(from: collectItems , collationStringSelector: #selector(NSObject.description)) as! [String]
            for item in items {
                let index = collation.section(for: item, collationStringSelector: #selector(NSObject.description))
                sections[index].append(filterObj)
            }
        }
        print(sections)
        return sections as [[AnyObject]]
        
    }
    
    fileprivate func split(_ items: [String]) -> [[String]] {
        let collation = UILocalizedIndexedCollation.current()
        let items = collation.sortedArray(from: items, collationStringSelector: #selector(NSObject.description)) as! [String]
        
        var sections = [[String]](repeating: [], count: collation.sectionTitles.count)
        for item in items {
            
            
            let index = collation.section(for: item, collationStringSelector: #selector(NSObject.description))
            
            sections[index].append(item)
        }
        
        return sections
    }
    
    mutating func namesFeedArray(){
        namesArray = NSMutableArray()
        let index:NSMutableArray = NSMutableArray()
        let FavArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: "name") as! NSArray
        if(FavArr.count > 0)
        {
            for i in 0..<FavArr.count {
                if(FavArr.count > 0)
                {
                    let favRecord:FavRecord=FavRecord()
                    
                    let ResponseDict = FavArr[i] as! NSManagedObject
                    favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                    
                    if(favRecord.name == ""){
                        index.add(i)
                    }else{
                        favRecord.countrycode=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "countrycode"))
                        favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                        favRecord.is_add=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_add"))
                        favRecord.msisdn=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
                        favRecord.phnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber"))
                        favRecord.profilepic=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic"))
                        favRecord.status = Themes.sharedInstance.base64ToString(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "status")))
                        namesArray.add(favRecord)
                    }
                }
            }
            if(index.count > 0){
                for i in 0..<index.count{
                    let favRecord:FavRecord=FavRecord()
                    let ResponseDict = FavArr[index[i] as! Int] as! NSManagedObject
                    favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                    favRecord.countrycode=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "countrycode"))
                    favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                    favRecord.is_add=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_add"))
                    favRecord.msisdn=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
                    favRecord.phnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber"))
                    favRecord.profilepic=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic"))
                    favRecord.status = Themes.sharedInstance.base64ToString(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "status")))
                    namesArray.add(favRecord)
                }
            }
        }
    }
    
    mutating internal func returnFavArr() ->NSMutableArray
    {
        SortedArr=NSMutableArray()
        if(sections.count > 0)
        {
            self.namesFeedArray()
            for  i in 0..<sections.count
            {
                let Arr:NSArray = sections[i] as NSArray
                if(Arr.count>0)
                {
                    let subArr:NSMutableArray=NSMutableArray()
                    let index:NSMutableArray=NSMutableArray()
                    for k in 0..<Arr.count
                    {
                        if(namesArray.count > 0)
                        {
                            for i in 0..<namesArray.count {
                                if((namesArray[i] as! FavRecord).name == Arr[k] as! String ){
                                    subArr.add(namesArray[i])
                                    if(index.count > 0){
                                        if(index.contains(i)){
                                            subArr.removeObject(at: subArr.count - 1)
                                        }
                                    }
                                    index.add(i)
                                }
                            }
                        }
                    }
                    SortedArr.add(subArr)
                }
                else
                {
                    SortedArr.add(FavRecord())
                }
            }
        }
        print(SortedArr)
        print(SortedArr.count)
        return SortedArr
    }
    
    func numberOfSections() -> Int {
        print(sections.count)
        if CheckBool == false{
            return   sectionsFilter.count
        }
        return sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        if CheckBool == false{
            return sectionsFilter[section].count
        }
        return sections[section].count
    }
    
    internal   func itemAtIndexPath(_ indexPath: IndexPath) ->  Item? {
        return (sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).item]) as Item
    }
    
    func itemAtIndexPathFilter(_ indexPath: IndexPath) -> AnyObject?{
        guard sectionsFilter.count > indexPath.section, sectionsFilter[(indexPath as NSIndexPath).section].count > (indexPath as NSIndexPath).item else{return nil}
        return (sectionsFilter[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).item]) as AnyObject
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        
        return collaction.sectionTitles[section]
    }
}

extension UIColor : Item {}

struct CompoundDataSource : DataSource {
    mutating internal func initwithData() {
        
    }
    
    
    
    
    fileprivate let colorsSection = [UIColor.lightGray, UIColor.gray, UIColor.darkGray]
    
    fileprivate var countryDataSource = CountryDataSource()
    
    mutating internal func returnFavArr() -> NSMutableArray {
        return countryDataSource.returnFavArr()
    }
    
    func numberOfSections() -> Int {
        return countryDataSource.numberOfSections() + 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return section == 0 ? colorsSection.count : countryDataSource.numberOfItemsInSection(section - 1)
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> Item? {
        if (indexPath as NSIndexPath).section == 0 {
            return colorsSection[(indexPath as NSIndexPath).item]
        } else {
            return countryDataSource.itemAtIndexPath(IndexPath(item: (indexPath as NSIndexPath).item, section: (indexPath as NSIndexPath).section - 1))
        }
    }
    func itemAtIndexPathFilter(_ indexPath: IndexPath) -> AnyObject?{
        return nil
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        return section == 0 ? nil : countryDataSource.titleForHeaderInSection(section - 1)
    }
}


