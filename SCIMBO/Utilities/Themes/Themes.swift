//
//  ConnectionTimer.swift
//  ChatApp
//
//  Created by Casp iOS on 09/01/17.
//  Copyright © 2017 Casp iOS. All rights reserved.
//

import UIKit
import JSSAlertView
import MMMaterialDesignSpinner
import SWMessages
import ACPDownload
import UserNotifications
import PushKit
import Social
import GLNotificationBar
import SDWebImage

class Themes: NSObject,UNUserNotificationCenterDelegate {
    static let sharedInstance = Themes()
    var notificationBar:GLNotificationBar=GLNotificationBar()
    let screenSize:CGRect = UIScreen.main.bounds
    var spinnerView:MMMaterialDesignSpinner=MMMaterialDesignSpinner()
    var spinner:UIView=UIView()
    var autoCircularProgressView : MRCircularProgressView!
    var progressView : UIView!
    var success_img : UIImageView!
    var restore_lbl : UILabel!
    var iterationCount:Int = 0
    var notification_dict:NSDictionary = NSDictionary()
    var chat_type:String = String()
    private let cache = NSCache<NSString, UIImage>()
    
    var progressAlert = UIAlertController()
    var progressBar = UIProgressView()

    var kLanguage : String{
        get {
            return "en"
        }
    }
    let  codename:NSArray=["Afghanistan(+93)", "Albania(+355)","Algeria(+213)","American Samoa(+1684)","Andorra(+376)","Angola(+244)","Anguilla(+1264)","Antarctica(+672)","Antigua and Barbuda(+1268)","Argentina(+54)","Armenia(+374)","Aruba(+297)","Australia(+61)","Austria(+43)","Azerbaijan(+994)","Bahamas(+1242)","Bahrain(+973)","Bangladesh(+880)","Barbados(+1246)","Belarus(+375)","Belgium(+32)","Belize(+501)","Benin(+229)","Bermuda(+1441)","Bhutan(+975)","Bolivia(+591)","Bosnia and Herzegovina(+387)","Botswana(+267)","Brazil(+55)","British Virgin Islands(+1284)","Brunei(+673)","Bulgaria(+359)","Burkina Faso(+226)","Burma (Myanmar)(+95)","Burundi(+257)","Cambodia(+855)","Cameroon(+237)","Canada(+1)","Cape Verde(+238)","Cayman Islands(+1345)","Central African Republic(+236)","Chad(+235)","Chile(+56)","China(+86)","Christmas Island(+61)","Cocos (Keeling) Islands(+61)","Colombia(+57)","Comoros(+269)","Cook Islands(+682)","Costa Rica(+506)","Croatia(+385)","Cuba(+53)","Cyprus(+357)","Czech Republic(+420)","Democratic Republic of the Congo(+243)","Denmark(+45)","Djibouti(+253)","Dominica(+1767)","Dominican Republic(+1809)","Ecuador(+593)","Egypt(+20)","El Salvador(+503)","Equatorial Guinea(+240)","Eritrea(+291)","Estonia(+372)","Ethiopia(+251)","Falkland Islands(+500)","Faroe Islands(+298)","Fiji(+679)","Finland(+358)","France (+33)","French Polynesia(+689)","Gabon(+241)","Gambia(+220)","Gaza Strip(+970)","Georgia(+995)","Germany(+49)","Ghana(+233)","Gibraltar(+350)","Greece(+30)","Greenland(+299)","Grenada(+1473)","Guam(+1671)","Guatemala(+502)","Guinea(+224)","Guinea-Bissau(+245)","Guyana(+592)","Haiti(+509)","Holy See (Vatican City)(+39)","Honduras(+504)","Hong Kong(+852)","Hungary(+36)","Iceland(+354)","India(+91)","Indonesia(+62)","Iran(+98)","Iraq(+964)","Ireland(+353)","Isle of Man(+44)","Israel(+972)","Italy(+39)","Ivory Coast(+225)","Jamaica(+1876)","Japan(+81)","Jordan(+962)","Kazakhstan(+7)","Kenya(+254)","Kiribati(+686)","Kosovo(+381)","Kuwait(+965)","Kyrgyzstan(+996)","Laos(+856)","Latvia(+371)","Lebanon(+961)","Lesotho(+266)","Liberia(+231)","Libya(+218)","Liechtenstein(+423)","Lithuania(+370)","Luxembourg(+352)","Macau(+853)","Macedonia(+389)","Madagascar(+261)","Malawi(+265)","Malaysia(+60)","Maldives(+960)","Mali(+223)","Malta(+356)","MarshallIslands(+692)","Mauritania(+222)","Mauritius(+230)","Mayotte(+262)","Mexico(+52)","Micronesia(+691)","Moldova(+373)","Monaco(+377)","Mongolia(+976)","Montenegro(+382)","Montserrat(+1664)","Morocco(+212)","Mozambique(+258)","Namibia(+264)","Nauru(+674)","Nepal(+977)","Netherlands(+31)","Netherlands Antilles(+599)","New Caledonia(+687)","New Zealand(+64)","Nicaragua(+505)","Niger(+227)","Nigeria(+234)","Niue(+683)","Norfolk Island(+672)","North Korea (+850)","Northern Mariana Islands(+1670)","Norway(+47)","Oman(+968)","Pakistan(+92)","Palau(+680)","Panama(+507)","Papua New Guinea(+675)","Paraguay(+595)","Peru(+51)","Philippines(+63)","Pitcairn Islands(+870)","Poland(+48)","Portugal(+351)","Puerto Rico(+1)","Qatar(+974)","Republic of the Congo(+242)","Romania(+40)","Russia(+7)","Rwanda(+250)","Saint Barthelemy(+590)","Saint Helena(+290)","Saint Kitts and Nevis(+1869)","Saint Lucia(+1758)","Saint Martin(+1599)","Saint Pierre and Miquelon(+508)","Saint Vincent and the Grenadines(+1784)","Samoa(+685)","San Marino(+378)","Sao Tome and Principe(+239)","Saudi Arabia(+966)","Senegal(+221)","Serbia(+381)","Seychelles(+248)","Sierra Leone(+232)","Singapore(+65)","Slovakia(+421)","Slovenia(+386)","Solomon Islands(+677)","Somalia(+252)","South Africa(+27)","South Korea(+82)","Spain(+34)","Sri Lanka(+94)","Sudan(+249)","Suriname(+597)","Swaziland(+268)","Sweden(+46)","Switzerland(+41)","Syria(+963)","Taiwan(+886)","Tajikistan(+992)","Tanzania(+255)","Thailand(+66)","Timor-Leste(+670)","Togo(+228)","Tokelau(+690)","Tonga(+676)","Trinidad and Tobago(+1868)","Tunisia(+216)","Turkey(+90)","Turkmenistan(+993)","Turks and Caicos Islands(+1649)","Tuvalu(+688)","Uganda(+256)","Ukraine(+380)","United Arab Emirates(+971)","United Kingdom(+44)","United States(+1)","Uruguay(+598)","US Virgin Islands(+1340)","Uzbekistan(+998)","Vanuatu(+678)","Venezuela(+58)","Vietnam(+84)","Wallis and Futuna(+681)","West Bank(970)","Yemen(+967)","Zambia(+260)","Zimbabwe(+263)"];
    let code:NSArray=["+93", "+355","+213","+1684","+376","+244","+1264","+672","+1268","+54","+374","+297","+61","+43","+994","+1242","+973","+880","+1246","+375","+32","+501","+229","+1441","+975","+591"," +387","+267","+55","+1284","+673","+359","+226","+95","+257","+855","+237","+1","+238","+1345","+236","+235","+56","+86","+61","+61","+57","+269","+682","+506","+385","+53","+357","+420","+243","+45","+253","+1767","+1809","+593","+20","+503","+240","+291","+372","+251"," +500","+298","+679","+358","+33","+689","+241","+220"," +970","+995","+49","+233","+350","+30","+299","+1473","+1671","+502","+224","+245","+592","+509","+39","+504","+852","+36","+354","+91","+62","+98","+964","+353","+44","+972","+39","+225","+1876","+81","+962","+7","+254","+686","+381","+965","+996","+856","+371","+961","+266","+231","+218","+423","+370","+352","+853","+389","+261","+265","+60","+960","+223","+356","+692","+222","+230","+262","+52","+691","+373","+377","+976","+382","+1664","+212","+258","+264","+674","+977","+31","+599","+687","+64","+505","+227","+234","+683","+672","+850","+1670","+47","+968","+92","+680","+507","+675","+595","+51","+63","+870","+48","+351","+1","+974","+242","+40","+7","+250","+590","+290","+1869","+1758","+1599","+508","+1784","+685","+378","+239","+966","+221","+381","+248","+232","+65","+421","+386","+677","+252","+27","+82","+34","+94","+249","+597","+268","+46","+41","+963","+886","+992","+255","+66","+670","+228","+690","+676","+1868","+216","+90","+993","+1649","+688","+256","+380","+971","+44","+1","+598","+1340","+998","+678","+58","+84","+681","+970","+967","+260","+263"];
    
    
    
    var osVersion:String{
        let systemVersion = UIDevice.current.systemVersion
        return systemVersion
    }
    
    var fourUniqueDigits: String {
        var result = ""
        repeat {
            result = String(format:"%04d", arc4random_uniform(10000) )
        } while Set<Character>(result).count < 4
        return result
    }
    
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func isValidUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    var showContactPermissionAlert : UIAlertController {
        
        let alertController = UIAlertController (title: self.GetAppname(), message: "\(self.GetAppname()) doesn't have access to your contacts. \n \(self.GetAppname()) needs access to your iPhone's contacts to help you connect with other people on \(self.GetAppname()). To enable access, tap Settings and turn on Contacts.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    func RemoveNonnumericEntitites(PassedValue:NSString)->String
    {
        let stringArray = PassedValue.components(
            separatedBy: NSCharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        return newString
        
    }
    
    var deviceID:AnyObject{
        let uuid = UIDevice.current.identifierForVendor?.uuid
        return uuid as AnyObject
    }
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,2":                                 return "iPad Mini 4"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    func getCountryList() -> (NSDictionary) {
        let dict = [
            "AF" : ["Afghanistan", "93"],
            "AX" : ["Aland Islands", "358"],
            "AL" : ["Albania", "355"],
            "DZ" : ["Algeria", "213"],
            "AS" : ["American Samoa", "1"],
            "AD" : ["Andorra", "376"],
            "AO" : ["Angola", "244"],
            "AI" : ["Anguilla", "1"],
            "AQ" : ["Antarctica", "672"],
            "AG" : ["Antigua and Barbuda", "1"],
            "AR" : ["Argentina", "54"],
            "AM" : ["Armenia", "374"],
            "AW" : ["Aruba", "297"],
            "AU" : ["Australia", "61"],
            "AT" : ["Austria", "43"],
            "AZ" : ["Azerbaijan", "994"],
            "BS" : ["Bahamas", "1"],
            "BH" : ["Bahrain", "973"],
            "BD" : ["Bangladesh", "880"],
            "BB" : ["Barbados", "1"],
            "BY" : ["Belarus", "375"],
            "BE" : ["Belgium", "32"],
            "BZ" : ["Belize", "501"],
            "BJ" : ["Benin", "229"],
            "BM" : ["Bermuda", "1"],
            "BT" : ["Bhutan", "975"],
            "BO" : ["Bolivia", "591"],
            "BA" : ["Bosnia and Herzegovina", "387"],
            "BW" : ["Botswana", "267"],
            "BV" : ["Bouvet Island", "47"],
            "BQ" : ["BQ", "599"],
            "BR" : ["Brazil", "55"],
            "IO" : ["British Indian Ocean Territory", "246"],
            "VG" : ["British Virgin Islands", "1"],
            "BN" : ["Brunei Darussalam", "673"],
            "BG" : ["Bulgaria", "359"],
            "BF" : ["Burkina Faso", "226"],
            "BI" : ["Burundi", "257"],
            "KH" : ["Cambodia", "855"],
            "CM" : ["Cameroon", "237"],
            "CA" : ["Canada", "1"],
            "CV" : ["Cape Verde", "238"],
            "KY" : ["Cayman Islands", "345"],
            "CF" : ["Central African Republic", "236"],
            "TD" : ["Chad", "235"],
            "CL" : ["Chile", "56"],
            "CN" : ["China", "86"],
            "CX" : ["Christmas Island", "61"],
            "CC" : ["Cocos (Keeling) Islands", "61"],
            "CO" : ["Colombia", "57"],
            "KM" : ["Comoros", "269"],
            "CG" : ["Congo (Brazzaville)", "242"],
            "CD" : ["Congo, Democratic Republic of the", "243"],
            "CK" : ["Cook Islands", "682"],
            "CR" : ["Costa Rica", "506"],
            "CI" : ["Côte d'Ivoire", "225"],
            "HR" : ["Croatia", "385"],
            "CU" : ["Cuba", "53"],
            "CW" : ["Curacao", "599"],
            "CY" : ["Cyprus", "537"],
            "CZ" : ["Czech Republic", "420"],
            "DK" : ["Denmark", "45"],
            "DJ" : ["Djibouti", "253"],
            "DM" : ["Dominica", "1"],
            "DO" : ["Dominican Republic", "1"],
            "EC" : ["Ecuador", "593"],
            "EG" : ["Egypt", "20"],
            "SV" : ["El Salvador", "503"],
            "GQ" : ["Equatorial Guinea", "240"],
            "ER" : ["Eritrea", "291"],
            "EE" : ["Estonia", "372"],
            "ET" : ["Ethiopia", "251"],
            "FK" : ["Falkland Islands (Malvinas)", "500"],
            "FO" : ["Faroe Islands", "298"],
            "FJ" : ["Fiji", "679"],
            "FI" : ["Finland", "358"],
            "FR" : ["France", "33"],
            "GF" : ["French Guiana", "594"],
            "PF" : ["French Polynesia", "689"],
            "TF" : ["French Southern Territories", "689"],
            "GA" : ["Gabon", "241"],
            "GM" : ["Gambia", "220"],
            "GE" : ["Georgia", "995"],
            "DE" : ["Germany", "49"],
            "GH" : ["Ghana", "233"],
            "GI" : ["Gibraltar", "350"],
            "GR" : ["Greece", "30"],
            "GL" : ["Greenland", "299"],
            "GD" : ["Grenada", "1"],
            "GP" : ["Guadeloupe", "590"],
            "GU" : ["Guam", "1"],
            "GT" : ["Guatemala", "502"],
            "GG" : ["Guernsey", "44"],
            "GN" : ["Guinea", "224"],
            "GW" : ["Guinea-Bissau", "245"],
            "GY" : ["Guyana", "595"],
            "HT" : ["Haiti", "509"],
            "VA" : ["Holy See (Vatican City State)", "379"],
            "HN" : ["Honduras", "504"],
            "HK" : ["Hong Kong, Special Administrative Region of China", "852"],
            "HU" : ["Hungary", "36"],
            "IS" : ["Iceland", "354"],
            "IN" : ["India", "91"],
            "ID" : ["Indonesia", "62"],
            "IR" : ["Iran, Islamic Republic of", "98"],
            "IQ" : ["Iraq", "964"],
            "IE" : ["Ireland", "353"],
            "IM" : ["Isle of Man", "44"],
            "IL" : ["Israel", "972"],
            "IT" : ["Italy", "39"],
            "JM" : ["Jamaica", "1"],
            "JP" : ["Japan", "81"],
            "JE" : ["Jersey", "44"],
            "JO" : ["Jordan", "962"],
            "KZ" : ["Kazakhstan", "77"],
            "KE" : ["Kenya", "254"],
            "KI" : ["Kiribati", "686"],
            "KP" : ["Korea, Democratic People's Republic of", "850"],
            "KR" : ["Korea, Republic of", "82"],
            "KW" : ["Kuwait", "965"],
            "KG" : ["Kyrgyzstan", "996"],
            "LA" : ["Lao PDR", "856"],
            "LV" : ["Latvia", "371"],
            "LB" : ["Lebanon", "961"],
            "LS" : ["Lesotho", "266"],
            "LR" : ["Liberia", "231"],
            "LY" : ["Libya", "218"],
            "LI" : ["Liechtenstein", "423"],
            "LT" : ["Lithuania", "370"],
            "LU" : ["Luxembourg", "352"],
            "MO" : ["Macao, Special Administrative Region of China", "853"],
            "MK" : ["Macedonia, Republic of", "389"],
            "MG" : ["Madagascar", "261"],
            "MW" : ["Malawi", "265"],
            "MY" : ["Malaysia", "60"],
            "MV" : ["Maldives", "960"],
            "ML" : ["Mali", "223"],
            "MT" : ["Malta", "356"],
            "MH" : ["Marshall Islands", "692"],
            "MQ" : ["Martinique", "596"],
            "MR" : ["Mauritania", "222"],
            "MU" : ["Mauritius", "230"],
            "YT" : ["Mayotte", "262"],
            "MX" : ["Mexico", "52"],
            "FM" : ["Micronesia, Federated States of", "691"],
            "MD" : ["Moldova", "373"],
            "MC" : ["Monaco", "377"],
            "MN" : ["Mongolia", "976"],
            "ME" : ["Montenegro", "382"],
            "MS" : ["Montserrat", "1"],
            "MA" : ["Morocco", "212"],
            "MZ" : ["Mozambique", "258"],
            "MM" : ["Myanmar", "95"],
            "NA" : ["Namibia", "264"],
            "NR" : ["Nauru", "674"],
            "NP" : ["Nepal", "977"],
            "NL" : ["Netherlands", "31"],
            "AN" : ["Netherlands Antilles", "599"],
            "NC" : ["New Caledonia", "687"],
            "NZ" : ["New Zealand", "64"],
            "NI" : ["Nicaragua", "505"],
            "NE" : ["Niger", "227"],
            "NG" : ["Nigeria", "234"],
            "NU" : ["Niue", "683"],
            "NF" : ["Norfolk Island", "672"],
            "MP" : ["Northern Mariana Islands", "1"],
            "NO" : ["Norway", "47"],
            "OM" : ["Oman", "968"],
            "PK" : ["Pakistan", "92"],
            "PW" : ["Palau", "680"],
            "PS" : ["Palestinian Territory, Occupied", "970"],
            "PA" : ["Panama", "507"],
            "PG" : ["Papua New Guinea", "675"],
            "PY" : ["Paraguay", "595"],
            "PE" : ["Peru", "51"],
            "PH" : ["Philippines", "63"],
            "PN" : ["Pitcairn", "872"],
            "PL" : ["Poland", "48"],
            "PT" : ["Portugal", "351"],
            "PR" : ["Puerto Rico", "1"],
            "QA" : ["Qatar", "974"],
            "RE" : ["Réunion", "262"],
            "RO" : ["Romania", "40"],
            "RU" : ["Russian Federation", "7"],
            "RW" : ["Rwanda", "250"],
            "SH" : ["Saint Helena", "290"],
            "KN" : ["Saint Kitts and Nevis", "1"],
            "LC" : ["Saint Lucia", "1"],
            "PM" : ["Saint Pierre and Miquelon", "508"],
            "VC" : ["Saint Vincent and Grenadines", "1"],
            "BL" : ["Saint-Barthélemy", "590"],
            "MF" : ["Saint-Martin (French part)", "590"],
            "WS" : ["Samoa", "685"],
            "SM" : ["San Marino", "378"],
            "ST" : ["Sao Tome and Principe", "239"],
            "SA" : ["Saudi Arabia", "966"],
            "SN" : ["Senegal", "221"],
            "RS" : ["Serbia", "381"],
            "SC" : ["Seychelles", "248"],
            "SL" : ["Sierra Leone", "232"],
            "SG" : ["Singapore", "65"],
            "SX" : ["Sint Maarten", "1"],
            "SK" : ["Slovakia", "421"],
            "SI" : ["Slovenia", "386"],
            "SB" : ["Solomon Islands", "677"],
            "SO" : ["Somalia", "252"],
            "ZA" : ["South Africa", "27"],
            "GS" : ["South Georgia and the South Sandwich Islands", "500"],
            "SS​" : ["South Sudan", "211"],
            "ES" : ["Spain", "34"],
            "LK" : ["Sri Lanka", "94"],
            "SD" : ["Sudan", "249"],
            "SR" : ["Suriname", "597"],
            "SJ" : ["Svalbard and Jan Mayen Islands", "47"],
            "SZ" : ["Swaziland", "268"],
            "SE" : ["Sweden", "46"],
            "CH" : ["Switzerland", "41"],
            "SY" : ["Syrian Arab Republic (Syria)", "963"],
            "TW" : ["Taiwan, Republic of China", "886"],
            "TJ" : ["Tajikistan", "992"],
            "TZ" : ["Tanzania, United Republic of", "255"],
            "TH" : ["Thailand", "66"],
            "TL" : ["Timor-Leste", "670"],
            "TG" : ["Togo", "228"],
            "TK" : ["Tokelau", "690"],
            "TO" : ["Tonga", "676"],
            "TT" : ["Trinidad and Tobago", "1"],
            "TN" : ["Tunisia", "216"],
            "TR" : ["Turkey", "90"],
            "TM" : ["Turkmenistan", "993"],
            "TC" : ["Turks and Caicos Islands", "1"],
            "TV" : ["Tuvalu", "688"],
            "UG" : ["Uganda", "256"],
            "UA" : ["Ukraine", "380"],
            "AE" : ["United Arab Emirates", "971"],
            "GB" : ["United Kingdom", "44"],
            "US" : ["United States of America", "1"],
            "UY" : ["Uruguay", "598"],
            "UZ" : ["Uzbekistan", "998"],
            "VU" : ["Vanuatu", "678"],
            "VE" : ["Venezuela (Bolivarian Republic of)", "58"],
            "VN" : ["Viet Nam", "84"],
            "VI" : ["Virgin Islands, US", "1"],
            "WF" : ["Wallis and Futuna Islands", "681"],
            "EH" : ["Western Sahara", "212"],
            "YE" : ["Yemen", "967"],
            "ZM" : ["Zambia", "260"],
            "ZW" : ["Zimbabwe", "263"]
        ]
        
        return dict as (NSDictionary)
    }
    
    func returnupdatedSecrettimestamp(incognito_timer_mode:String)->String
    {
        let calendar = Calendar.current
        var newDate:Date = Date()
        if(incognito_timer_mode == "5 seconds"){
            newDate = calendar.date(byAdding: .second, value: 5, to: newDate)!
        }else if(incognito_timer_mode == "10 seconds"){
            newDate = calendar.date(byAdding: .second, value: 10, to: newDate)!
            
        }else if(incognito_timer_mode == "30 seconds"){
            newDate = calendar.date(byAdding: .second, value: 30, to: newDate)!
            
        }else if(incognito_timer_mode == "1 minute"){
            newDate = calendar.date(byAdding: .minute, value: 1, to: newDate)!
            
        }else if(incognito_timer_mode == "1 hour"){
            newDate = calendar.date(byAdding: .hour, value: 1, to: newDate)!
            
        }else if(incognito_timer_mode == "1 day"){
            newDate = calendar.date(byAdding: .day, value: 1, to: newDate)!
        }else if(incognito_timer_mode == "1 week"){
            
            newDate = calendar.date(byAdding: .day, value: 7, to: newDate)!
        }
        return String(Int64(newDate.ticks))
    }
    var current_Time:String{
        let todaysDate:NSDate = NSDate()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let  DateInFormat:String = dateFormatter.string(from: todaysDate as Date)
        print(DateInFormat)
        return DateInFormat
    }
    func alertView(title:NSString,Message:NSString,ButtonTitle:NSString)
    {
        
        
    }
    func ConverttimeStamp(timestamp:String)->String
    {
        if(timestamp.length > 0)
        {
            var servertimeStr:String = self.getServerTime()
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
            let date = Date(timeIntervalSince1970: TimeInterval("\(timeDiff)")!/1000)
            let dateFormatters = DateFormatter()
            dateFormatters.dateFormat = "h:mm a"
            dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatters.timeZone = NSTimeZone.system
            let dateStr:String = dateFormatters.string(from: date as Date)
            return dateStr
        }
        
        return timestamp
    }
    
    func checkTimeStampMorethan10Mins(timestamp : String) -> Bool
    {
        if(timestamp.length > 0)
        {
            var servertimeStr:String = self.getServerTime()
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
            var date = Date(timeIntervalSince1970: TimeInterval("\(timeDiff)")!/1000)
            date = date.addingTimeInterval(10.0 * 60.0)
            let currentDate = Date()
            if date >= currentDate  {
                return true
            }
            else
            {
                return false
            }
        }
        return false
    }
    
    func checkTimeStampMorethan24Hours(timestamp : String) -> Bool
    {
        if(timestamp.length > 0)
        {
            var servertimeStr:String = self.getServerTime()
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
            var date = Date(timeIntervalSince1970: TimeInterval("\(timeDiff)")!/1000)
            date = date.addingTimeInterval(24 * 60.0 * 60.0)
            let currentDate = Date()
            if date >= currentDate  {
                return true
            }
            else
            {
                return false
            }
        }
        return false
    }
    
    func ConverttimeStamptodate(timestamp:String)->String
    {
        if(timestamp.length > 0)
        {
            var servertimeStr:String = self.getServerTime()
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
            let date = Date(timeIntervalSince1970: TimeInterval("\(timeDiff)")!/1000)
            let dateFormatters = DateFormatter()
            dateFormatters.dateFormat = "dd/MM/yyyy"
            dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatters.timeZone = NSTimeZone.system
            let dateStr:String = dateFormatters.string(from: date as Date)
            return dateStr
        }
        return timestamp
    }
    func ReturnTimeForChat(timestamp:String)->String
    {
        var servertimeStr:String = self.getServerTime()
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
        let date = Date(timeIntervalSince1970: TimeInterval("\(timeDiff)")!/1000)
        let dateFormatters = DateFormatter()
        dateFormatters.dateFormat = "h:mm a"
        dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatters.timeZone = NSTimeZone.system
        let dateStr:String = dateFormatters.string(from: date as Date)
        return dateStr
    }
    func ConverttimeStamptodateentity(timestamp:String)->Date!
    {
        var date:Date!
        if(timestamp != "")
        {
            var servertimeStr:String = self.getServerTime()
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
            date  = Date(timeIntervalSince1970: TimeInterval("\(timeDiff)")!/1000)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            //dateFormatter.timeZone = NSTimeZone.local //Edit
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }
        else
        {
            date = nil
        }
        return date
    }
    
    func ReturnDateTimeSeconds(timestamp:String, to format:String = "MM-dd-yyyy hh:mm:ss a")->String{
        let date = Date(timeIntervalSince1970: TimeInterval((timestamp as NSString).longLongValue/1000))
        let dateFormatters = DateFormatter()
        dateFormatters.dateFormat = format
        dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatters.timeZone = NSTimeZone.system
        let dateStr:String = dateFormatters.string(from: date as Date)
        return dateStr
    }
    
    func returnTime(from timeStamp: String) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval((timeStamp as NSString).longLongValue/1000))
        let dateFormatters = DateFormatter()
        dateFormatters.dateFormat = "h:mm a"
        dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatters.timeZone = NSTimeZone.system
        let dateStr:String = dateFormatters.string(from: date as Date)
        return dateStr
    }
    
    func getTimeStamp() -> String {
        return String(Date().ticks)
    }
    
    func returnStatusTime(from timestamp: String) -> String{
        
        var servertimeStr:String = self.getServerTime()
        var timestamp = timestamp
        if(timestamp != "")
        {
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
            
            timestamp = "\(timeDiff)"
        }
        let date1 = Date()
        let date2 = Date(timeIntervalSince1970: TimeInterval((timestamp as NSString).longLongValue/1000))
        
        let diff = Int(date1.timeIntervalSince1970 - date2.timeIntervalSince1970)
        
        let hours = diff / 3600
        if hours > 24 {
            
            let DayStr:String = ReturnDateTimeFormat(timestamp: timestamp)
            let TimeStr:String = ReturnTimeForChat(timestamp: timestamp)
            return "\(DayStr), \(TimeStr)"
        }else{
            if(hours == 0)
            {
                let minutes = (diff - hours * 3600) / 60
                if minutes > 0{
                    return "\(minutes)m ago"
                }
                else{
                    return "just now"
                }
            }
            else
            {
                return "\(hours)h ago"
            }
        }
    }
    
    
    func ReturnDateTimeFormat(timestamp:String)->String
    {
        var dateFormatStr:String = ""
        var servertimeStr:String = self.getServerTime()
        if(timestamp != "")
        {
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            let timeDiff = (timestamp as NSString).longLongValue + serverTimestamp
            
            let timestamp:String = "\(timeDiff)"
            
            var date = Date(timeIntervalSince1970: TimeInterval(timestamp)!/1000)
            let dateFormatters = DateFormatter()
            dateFormatters.dateFormat = "dd/MM/yyyy"
            dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatters.timeZone = NSTimeZone.system
            let dateStr:String = dateFormatters.string(from: date as Date)
            date = dateFormatters.date(from: dateStr as String)!
            let fromdate:Date = date
            let todate:Date = Date()
            let numberOfDays:Int! = self.ReturnNumberofDays(fromdate: fromdate, todate: todate)
            if(numberOfDays == 0)
            {
                if(Calendar.current.isDate(fromdate, inSameDayAs: todate))
                {
                    
                    dateFormatStr = NSLocalizedString("Today", comment:"Today")
                }
                else
                {
                    dateFormatStr = NSLocalizedString("Yesterday", comment:"Yesterday")
                    
                }
            }
                
            else if(Calendar.current.isDateInYesterday(fromdate))
            {
                dateFormatStr = NSLocalizedString("Yesterday", comment:"Yesterday")
            }
            else if(numberOfDays < 4)
            {
                
                dateFormatters.dateFormat = "EEE"
                dateFormatStr = dateFormatters.string(from: fromdate)
                
            }
            else if(numberOfDays > 365)
            {
                dateFormatters.dateFormat = "dd/MM/YYYY"
                dateFormatStr = dateFormatters.string(from: fromdate)
            }
            else{
                dateFormatters.dateFormat = "dd/MM/YYYY"
                dateFormatStr = dateFormatters.string(from: fromdate)
            }
        }
        
        return dateFormatStr
        
    }
    func ReturnNumberofDays(fromdate:Date,todate:Date)->Int?
    {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: fromdate, to: todate)
        if(components.day! == 0)
        {
            
            if(Calendar.current.isDate(fromdate, inSameDayAs: todate))
            {
                return 0
            }
            else
            {
                return 0
            }
            
        }
        return components.day
        
    }
    
    func saveDeviceToken(DeviceToken:String)
    {
        
        UserDefaults.standard.set(DeviceToken, forKey: "device_token")
        UserDefaults.standard.synchronize()
    }
    
    func saveFirstTime(firsttime: String) {
        UserDefaults.standard.set(firsttime, forKey: "first_time")
        UserDefaults.standard.synchronize()
    }
    
    func getFirstTime() -> String {
        return self.CheckNullvalue(Passed_value: UserDefaults.standard.value(forKey: "first_time"))
    }
    
    func saveCallToken(DeviceToken:String)
    {
        
        UserDefaults.standard.set(DeviceToken, forKey: "call_token")
        UserDefaults.standard.synchronize()
    }
    func saveServerTime(serverDiff:String, serverTime:String)
    {
        let detail = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: self.Getuser_id(), SortDescriptor: nil) as! [User_detail]
        if detail.count > 0 {
            let param = ["serverDiff" : serverDiff, "serverTime" : serverTime]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: self.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary)
        }
    }
    
    
    func savesecurityToken(DeviceToken:String)
    {
        
        UserDefaults.standard.set(DeviceToken, forKey: "securityToken")
        UserDefaults.standard.synchronize()
    }
    
    func getsecurityToken() -> String
    {
        var encrypted_token : String? =   self.CheckNullvalue(Passed_value: UserDefaults.standard.value(forKey: "securityToken"))
        if(encrypted_token == ""  || encrypted_token == nil)
        {
            encrypted_token = ""
        }
        return encrypted_token!
    }
    
    func savesPrivatekey(DeviceToken:String)
    {
        
        UserDefaults.standard.set(DeviceToken, forKey: "Privatekey")
        UserDefaults.standard.synchronize()
    }
    
    func getPrivatekey() -> String
    {
        var encrypted_token : String? =   self.CheckNullvalue(Passed_value: UserDefaults.standard.value(forKey: "Privatekey"))
        if(encrypted_token == ""  || encrypted_token == nil)
        {
            encrypted_token = ""
        }
        return encrypted_token!
    }
    
    
    func savepublicKey(DeviceToken:String)
    {
        
        UserDefaults.standard.set(DeviceToken, forKey: "publicKey")
        UserDefaults.standard.synchronize()
    }
    
    func getpublicKey() -> String
    {
        var encrypted_token : String? =   self.CheckNullvalue(Passed_value: UserDefaults.standard.value(forKey: "publicKey"))
        if(encrypted_token == ""  || encrypted_token == nil)
        {
            encrypted_token = ""
        }
        return encrypted_token!
    }
    
    
    func saveToken(Str:String)
    {
        let publickey:String = KeychainService.loadPassword(service:  "\(self.Getuser_id())-public_key")! as String
        
        let privatekey:String = KeychainService.loadPassword(service:  "\(self.Getuser_id())-private_key")! as String
        if(publickey != "" || privatekey != "")
        {
            KeychainService.removeSpecificPassword(service: "\(self.Getuser_id())-public_key")
            KeychainService.removeSpecificPassword(service: "\(self.Getuser_id())-private_key")
        }
        KeychainService.removeSpecificPassword(service: self.Getuser_id())
        KeychainService.removePassword()
        KeychainService.savePassword(service: self.Getuser_id(), data: Str)
    }
    func getToken() -> String
    {
        var encrypted_token : String? =   KeychainService.loadPassword(service: self.Getuser_id())
        if(encrypted_token == ""  || encrypted_token == nil)
        {
            encrypted_token = ""
        }
        return encrypted_token!
    }
    func ReturnjsonStr(jsonStr:[String:Any])->String
    {
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonStr, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }
    
    func ReturnStrtojson(jsonStr:String)->[String:Any]?
    {
        if let data = jsonStr.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getServerTime() -> String
    {
        var serverDiff = self.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: self.Getuser_id(), returnStr: "serverDiff")
        serverDiff = serverDiff == "" ? "0" : serverDiff
        return serverDiff
    }
    
    func getActualServerTime() -> String
    {
        var serverTime = self.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: self.Getuser_id(), returnStr: "serverTime")
        serverTime = serverTime == "" ? "0" : serverTime
        return serverTime
    }
    
    
    
    func getDeviceToken() -> String
    {
        var token : String =  self.CheckNullvalue(Passed_value: UserDefaults.standard.value(forKey: "device_token"))
        if(token == "")
        {
            token = "21a6d650d0063c66fca06e0dc5426d23a3a823be5ac8af13f004e9e415085a7a"
        }
        
        return token
    }
    
    func getCallToken() -> String
    {
        var token : String =  self.CheckNullvalue(Passed_value: UserDefaults.standard.value(forKey: "call_token"))
        if(token == "")
        {
            token = "21a6d650d0063c66fca06e0dc5426d23a3a823be5ac8af13f004e9e415085a7a"
        }
        
        return token
    }
    func saveCountryCode(_ countrycode: String) {
        UserDefaults.standard.set(countrycode, forKey: "country_code")
        UserDefaults.standard.synchronize()
    }
    
    func getCountryCode() -> String
    {
        var token : String =  self.CheckNullvalue(Passed_value: UserDefaults.standard.value(forKey: "country_code"))
        if(token == "")
        {
            token = "+1"
        }
        
        return token
    }
    func getDownloadURL(_ url : String) -> String {
        return url + "?at=site" + "&au=" + self.Getuser_id() + "&atoken=" + self.getToken()
    }
    
    func transformedValue(_ value: String) -> Any {
        guard var convertedValue = Double(value) else{return ""}
        if(convertedValue < 1)
        {
            convertedValue = 0
        }
        var multiplyFactor: Int = 0
        let tokens: [Any] = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        while convertedValue > Double(1024)
        {
            convertedValue = convertedValue/Double(1024)
            convertedValue = round(convertedValue)
            multiplyFactor += 1
        }
        return String(format:"%4.2f %@",convertedValue, tokens[multiplyFactor] as! String)
    }
    
    
    func checkBlock(id : String) -> Bool {
        return DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Blocked_user, attribute: "id", FetchString: id)
    }
    
    func showBlockalert(id : String)
    {
        let TitleStr = self.checkBlock(id: id) ? "Unblock" : "Block"
        
        let optionMenu = UIAlertController(title: nil, message: TitleStr == "Unblock" ? "Unblock contact to send a message" : "Blocked Contact will no longer be able to call you or send you messages", preferredStyle: .actionSheet)

        let BlockAction = UIAlertAction(title: TitleStr, style: TitleStr == "Unblock" ? .default : .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.executeBlockUser(id : id)
        })
        
        let ReportAction = UIAlertAction(title: "Report Spam", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.executeReportUser(id : id)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(BlockAction)
        if(TitleStr == "Block") {
            optionMenu.addAction(ReportAction)
        }
        optionMenu.addAction(cancelAction)
        
        AppDelegate.sharedInstance.navigationController?.presentView(optionMenu, animated: true)
    }
    
    func executeBlockUser(id: String)
    {
        if(URLhandler.sharedinstance.isConnectedToNetwork())
        {
            let status:String = self.checkBlock(id: id) ? "0" : "1"
            let Dict:NSDictionary = ["from":self.Getuser_id(),"to":id,"secret_type":"no","status":status]
            if(SocketIOManager.sharedInstance.iSSocketDisconnected == false){
                SocketIOManager.sharedInstance.EmitBlockUsers(Dict: Dict)
            }else{
                _ = JSSAlertView().show((AppDelegate.sharedInstance.navigationController?.topViewController)!,title: self.GetAppname(),text: "Unable to connect to server",buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
            }
            
            
        }
        else
        {
            _ = JSSAlertView().show((AppDelegate.sharedInstance.navigationController?.topViewController)!,title: self.GetAppname(),text: "Unable to connect to internet",buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
        }
    }
    
    func executeReportUser(id: String)
    {
        if(URLhandler.sharedinstance.isConnectedToNetwork())
        {
            let Dict:NSDictionary = ["from":Getuser_id(),"to":id]
            if(SocketIOManager.sharedInstance.iSSocketDisconnected == false){
                SocketIOManager.sharedInstance.EmitReportUsers(Dict: Dict)
                AppDelegate.sharedInstance.window?.makeToast(message: "Report has been recorded" , duration: 3, position: HRToastActivityPositionDefault)
            }else{
                _ = JSSAlertView().show((AppDelegate.sharedInstance.navigationController?.topViewController)!,title: self.GetAppname(),text: "Unable to connect to server",buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
            }
        }
        else
        {
            _ = JSSAlertView().show((AppDelegate.sharedInstance.navigationController?.topViewController)!,title: self.GetAppname(),text: "Unable to connect to internet",buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
        }
    }
    
    func isIminPrivacyContactList(_ id: String) -> Bool {
        let contacts = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: id, SortDescriptor: nil) as! [Favourite_Contact]
        var isMe = false
        if contacts.count > 0 {
            _ = contacts.map {
                if $0.contactUserList != nil {
                    let contactUserList = $0.contactUserList is Data ? NSKeyedUnarchiver.unarchiveObject(with: $0.contactUserList as! Data) as! [String] :  $0.contactUserList as! [String]
                    if contactUserList.contains(Themes.sharedInstance.Getuser_id()) {
                        isMe = true
                    }

                }
            }
        }
        return isMe
    }
    
    func isImBlocked(_ id : String) -> Bool {
        return DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_Blocked_user, attribute: "id", FetchString: id)
    }
    
    func isShowProfilePic(_ id : String) -> Bool {
        let is_blocked = isImBlocked(id)
        var profile_privacy = GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "profile_photo")
        if(profile_privacy == "mycontacts") {
            profile_privacy = !isIminPrivacyContactList(id) ? "nobody" : profile_privacy
        }
        return !is_blocked && profile_privacy != "nobody"
    }
    
    func isShowStatusLbl(_ id : String) -> Bool {
        let is_blocked = isImBlocked(id)
        var status_privacy = GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "show_status")
        if(status_privacy == "mycontacts") {
            status_privacy = !isIminPrivacyContactList(id) ? "nobody" : status_privacy
        }
        return !is_blocked && status_privacy != "nobody"
    }
    
    func isShowLastSeenLbl(_ id : String) -> Bool {
        let is_blocked = isImBlocked(id)
        var last_seen_privacy = GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "last_seen")
        let my_last_seen_privacy = GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Getuser_id(), returnStr: "last_seen")

        if(last_seen_privacy == "mycontacts") {
            last_seen_privacy = !isIminPrivacyContactList(id) ? "nobody" : last_seen_privacy
        }
        return !is_blocked && last_seen_privacy != "nobody" && my_last_seen_privacy != "nobody"
    }
    
    func LastSeenTxt(_ id : String) -> String {
        let is_online = GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "is_online")
        let time_stamp = GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "time_stamp")
        
        var txt = ""
        
        if(time_stamp != "") {
            if(isShowLastSeenLbl(id))
            {
                let DayStr:String = ReturnDateTimeFormat(timestamp: time_stamp)
                let TimeStr:String = ReturnTimeForChat(timestamp: time_stamp)
                txt = NSLocalizedString("last seen", comment: "last seen") + " " + (DayStr) + " " + NSLocalizedString("at", comment: "at") + " " + (TimeStr)
            }
        }
        if(is_online != "") {
            txt = is_online == "1" && !isImBlocked(id) ? NSLocalizedString("Online", comment: "Online")  : txt
        }
        
        txt = AppDelegate.sharedInstance.IsInternetconnected && SocketIOManager.sharedInstance.socket.status == .connected ? txt : ""
        
        return txt
    }
    
    func setProfilePic(_ id : String, _ type : String) -> String {
        var profilePic = ""
        if(type == "group"){
            profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: id, returnStr: "displayavatar")
        }
        else {
            if(id == Themes.sharedInstance.Getuser_id()) {
                profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "profilepic")
            }
            else {
                if(contactExist(id)) {
                    if(Themes.sharedInstance.isShowProfilePic(id)) {
                        profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "profilepic")
                    }
                }
                else
                {
                    profilePic = Themes.sharedInstance.getProfilePicFromGroup(id)
                }
            }
            
        }
        return profilePic
    }
    
    func setNameTxt(_ id: String, _ type : String) -> String {
        var name = ""
        if(type == "group") {
            name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: id, returnStr: "displayName")
            
        }
        else{
            if id == Themes.sharedInstance.Getuser_id() {
                name = type == "" ? Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "name") : "You"
            }
            else{
                if(Themes.sharedInstance.contactExist(id)) {
                    let msisdn = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "msisdn")
                    name = Themes.sharedInstance.ReturnFavName(opponentDetailsID: id, msginid: msisdn)
                }
                else
                {
                    name = Themes.sharedInstance.getNameFromGroup(id)
                }
            }
        }
        
        if(name == "") {
            let param_userDetails:[String:Any]=["userId":id]
            SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
        }
        return name
    }
    
    func setStatusTxt(_ id: String) -> String {
        var status = ""
        if id == Themes.sharedInstance.Getuser_id() {
            status = Themes.sharedInstance.base64ToString(Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "status"))
        }
        else {
            if(Themes.sharedInstance.contactExist(id)) {
                if(Themes.sharedInstance.isShowStatusLbl(id)) {
                    status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "status")
                    status = Themes.sharedInstance.base64ToString(status)
                }
            }
            else
            {
                status = Themes.sharedInstance.base64ToString(Themes.sharedInstance.getStatusFromGroup(id))
            }
        }
        return status
    }
    
    func setPhoneTxt(_ id: String) -> String {
        var msisdn = ""
        if id == Themes.sharedInstance.Getuser_id() {
            msisdn = Themes.sharedInstance.base64ToString(Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "mobilenumber"))
        }
        else {
            if(contactExist(id)) {
                msisdn = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "formatted")
            }
            else {
                msisdn = getPhoneFromGroup(id)
            }
        }
        return msisdn
    }
    
    func getNameFromGroup(_ id : String) -> String
    {
        var groupUsers = [NSDictionary]()
        let GroupDetail = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [Group_details]
        var name = ""
        _ = GroupDetail.map {
            if let groupData:Data = $0.groupUsers as? Data {
                groupUsers = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as! [NSDictionary]
                _ = groupUsers.map {
                    if(id == Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "id")))
                    {
                        name = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "msisdn"))
                        
                        let isExitsContact = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "isExitsContact"))
                        if(isExitsContact == "1")
                        {
                            name = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "ContactName"))
                        }
                    }
                }
            }
        }
        return name == "" ? getPhoneFromGroup(id) : name
    }
    
    func getPhoneFromGroup(_ id : String) -> String
    {
        var groupUsers = [NSDictionary]()
        let GroupDetail = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [Group_details]
        var msisdn = ""
        _ = GroupDetail.map {
            if let groupData:Data = $0.groupUsers as? Data {
                groupUsers = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as! [NSDictionary]
                _ = groupUsers.map {
                    if(id == Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "id")))
                    {
                        msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "msisdn"))
                    }
                }
            }
        }
        return msisdn
    }
    
    func getStatusFromGroup(_ id : String) -> String
    {
        var groupUsers = [NSDictionary]()
        let GroupDetail = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [Group_details]
        var status = ""
        _ = GroupDetail.map {
            if let groupData:Data = $0.groupUsers as? Data {
                groupUsers = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as! [NSDictionary]
                _ = groupUsers.map {
                    if(id == Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "id")))
                    {
                        status = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "Status"))
                    }
                }
            }
        }
        return status
    }
    
    func getProfilePicFromGroup(_ id : String) -> String
    {
        var groupUsers = [NSDictionary]()
        let GroupDetail = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [Group_details]
        var avatar = ""
        _ = GroupDetail.map {
            if let groupData:Data = $0.groupUsers as? Data {
                groupUsers = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as! [NSDictionary]
                _ = groupUsers.map {
                    if(id == Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "id")))
                    {
                        avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "avatar"))
                    }
                }
            }
        }
        return avatar.replacingOccurrences(of: "/./", with: "/")
    }
    
    func contactExist_Fav(_ id: String) -> Bool {
        return Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "is_fav") == "1"
    }
    
    func contactExist(_ id: String) -> Bool {
        return Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "is_fav") != ""
    }
    
    func returnGroupUsers(_ id: String) -> [String] {
        let opponentArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "id", FetchString: id, SortDescriptor: nil) as! [Group_details]
        
        var idArr = [String]()
        _ = opponentArr.map{
            let opponent = $0
            let groupUsers = NSKeyedUnarchiver.unarchiveObject(with: opponent.groupUsers as! Data) as! NSArray
            _ = groupUsers.map {
                let dict = $0 as! [String : Any]
                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: dict["id"])
                if(id != Themes.sharedInstance.Getuser_id()) {
                   idArr.append(id)
                }
            }
        }
        return idArr
    }
    
    func insertMessageStatus(_ msgId : String, _ id : String) {
        let groupUsers = NSKeyedArchiver.archivedData(withRootObject: returnGroupUsers(id))
        let param = ["read_arr" : groupUsers, "deliver_arr" : groupUsers, "msgId" : msgId, "convId" : id] as [String : Any]
        let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_message_ack, attribute: "msgId", FetchString: msgId)
        if(!checkMessage) {
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Group_message_ack)
        }
    }
    
    func returnOtherMessages(_ from : String, _ to : String, _ type : String) -> String {
        var message = ""
        if(type == "1")
        {
            message = "\(Themes.sharedInstance.setNameTxt(from, "single")) created the group"
        }
        if(type == "2")
        {
            message = "\(Themes.sharedInstance.setNameTxt(from, "single")) changed the group icon"
        }
        if(type == "4" || type == "5")
        {
            let from = Themes.sharedInstance.setNameTxt(from, "single")
            let to = Themes.sharedInstance.setNameTxt(to, "single")
            
            if(type == "4")
            {
                message = "\(from) removed \(to)"
            }
            else
            {
                message = "\(from) added \(to)"
            }
            
        }
        if(type == "6")
        {
            message = "\(Themes.sharedInstance.setNameTxt(from, "single")) changed the subject name"
            
        }
        if(type == "7")
        {
            
            var to = Themes.sharedInstance.setNameTxt(to, "single")
            
            if(to == "You")
            {
                to = to.appending("'re")
            }
            else {
                to = to.appending(" is")
            }
            message = "\(to) now admin"
        }
        if(type == "8")
        {
            message = "\(Themes.sharedInstance.setNameTxt(from, "single")) left"
        }
        return message
    }
    
    func shareContacttoMultiple(rec: NSMutableArray, opponent_id: String, Chat_type : String)
    {
        
        let from:String=self.CheckNullvalue(Passed_value: self.Getuser_id())
        let to:String=self.CheckNullvalue(Passed_value: opponent_id)
        let  user_common_id = self.CheckNullvalue(Passed_value: from + "-" + to)
        _ = rec.map {
            let record:FavRecord = $0 as! FavRecord
            print(record.profilepic)
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = self.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let Name:String = setNameTxt(Themes.sharedInstance.Getuser_id(), "")
            let Phonenumber:String=setPhoneTxt(Themes.sharedInstance.Getuser_id())
            
            var toDocId:String="\(from)-\(to)-\(timestamp)"
            
            if(Chat_type == "group")
            {
                toDocId="\(from)-\(to)-g-\(timestamp)"
            }
            
            var dic:[AnyHashable: Any]!
            var ArrDict = [String : Any]()
            if(record.msisdn == "")
            {
                ArrDict = getContact_details(phone:record.phnumber)
                _ = ArrDict["contacts_AArrObj"]
                _ = ArrDict["contactNoArrId"]
                _ = ArrDict["contactNameArrId"]
            }
            else
            {
                ArrDict = getContact_details(phone:record.msisdn)
                _ = ArrDict["contacts_AArrObj"]
                _ = ArrDict["contactNoArrId"]
                _ = ArrDict["contactNameArrId"]
            }
            
            let contact_details = ArrDict["contact_details"]
            
            dic = ["type": "5","convId":"","doc_id":self.CheckNullvalue(Passed_value:toDocId
                ),"filesize":"","from":self.CheckNullvalue(Passed_value:from
                ),"to":self.CheckNullvalue(Passed_value:to
                ),"isStar":self.CheckNullvalue(Passed_value:"0"
                ),"message_status":self.CheckNullvalue(Passed_value:"0"
                ),"id":timestamp,"name":self.CheckNullvalue(Passed_value:Name
                ),"payload":self.CheckNullvalue(Passed_value:record.name),"recordId":"","timestamp":self.CheckNullvalue(Passed_value:timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":self.CheckNullvalue(Passed_value:timestamp
                ),"contactmsisdn":self.CheckNullvalue(Passed_value:Phonenumber
                ),"user_common_id":self.CheckNullvalue(Passed_value:user_common_id
                ),"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"contact_profile":self.CheckNullvalue(Passed_value:record.profilepic),"contact_phone":self.CheckNullvalue(Passed_value:record.msisdn),"contact_id":self.CheckNullvalue(Passed_value:record.id),"contact_name":self.CheckNullvalue(Passed_value:record.name),"contact_details":self.CheckNullvalue(Passed_value:contact_details),"secret_msg_id":"","secret_timestamp":"", "date" : getTimeStamp()]
            //addRefreshViews()
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

            let contact_dic:[AnyHashable: Any] = ["doc_id":self.CheckNullvalue(Passed_value:toDocId
                ),"contact_profile":self.CheckNullvalue(Passed_value:record.profilepic),"contact_phone":self.CheckNullvalue(Passed_value:record.phnumber),"contact_id":self.CheckNullvalue(Passed_value:record.id),"contact_name":self.CheckNullvalue(Passed_value:record.name),"contact_details":self.CheckNullvalue(Passed_value:contact_details)]
            
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: contact_dic as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
            
            
            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
            if(!chatarray)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":self.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                
            }
            else
            {
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":self.Getuser_id(),"chat_count":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
            
            let details:NSMutableDictionary = ["contact_profile":self.CheckNullvalue(Passed_value:record.profilepic),"contact_phone":self.CheckNullvalue(Passed_value:record.phnumber),"id":self.CheckNullvalue(Passed_value:record.id),"contactDetails":self.CheckNullvalue(Passed_value:contact_details)]
            
            if(Chat_type == "single")
            {
                //createdTomsisdn = phonenumber
                //contact_name = id
                
                if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                    // here `json` is your JSON data
                    if let content = String(data: json, encoding: String.Encoding.utf8) {
                        // here `content` is the JSON data decoded as a String
                        print(content)
                        
                        if(Chat_type == "single"){
                            let Dict:Dictionary = ["from":self.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: Chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: Chat_type),"contact_name":self.CheckNullvalue(Passed_value:record.name),"createdTomsisdn":self.CheckNullvalue(Passed_value:record.phnumber),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str: self.CheckNullvalue(Passed_value: contact_details),toid:to, chat_type: Chat_type),"createdTo":self.CheckNullvalue(Passed_value:record.id)] as [String : Any]

                            SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                        }else{
                            let Dict:Dictionary = ["from":self.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: Chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: Chat_type),"contact_name":self.CheckNullvalue(Passed_value:record.name),"createdTomsisdn":self.CheckNullvalue(Passed_value:record.phnumber),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str: self.CheckNullvalue(Passed_value:contact_details),toid:to, chat_type: Chat_type),"createdTo":self.CheckNullvalue(Passed_value:record.id),"chat_type":"secret"] as [String : Any]

                            SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                        }
                        
                    }
                }
            }
            else
            {
                let displayName = self.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                
                if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                    // here `json` is your JSON data
                    if let content = String(data: json, encoding: String.Encoding.utf8) {
                        // here `content` is the JSON data decoded as a String
                        print(content)
                        let Dict:Dictionary = ["from":self.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: Chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: Chat_type),"contact_name":self.CheckNullvalue(Passed_value:record.name),"createdTomsisdn":self.CheckNullvalue(Passed_value:record.phnumber),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str: self.CheckNullvalue(Passed_value:contact_details),toid:to, chat_type: Chat_type),"groupType":"9","userName":displayName,"convId":to,"createdTo":self.CheckNullvalue(Passed_value:record.id)] as [String : Any]
                        SocketIOManager.sharedInstance.Groupevent(param: Dict)
                    }
                }
                
            }
            
        }
    }
    
    func getContact_details(phone:String) -> [String : Any]{
        
        var contacts_AArrObj = [NSManagedObject]()
        let contactNoArrId = NSMutableArray()
        let contactNameArrId = NSMutableArray()
        var contact_details = ""
        
        let checkContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString:phone);
        
        if(checkContact)
        {
            
            let contactsArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: phone, SortDescriptor: nil) as! [NSManagedObject]
            
            //let CheckFavcontactArr:NSMutableArray=NSMutableArray()
            _ = contactsArray.map {
                let constactObj = $0
                let i = contactsArray.index(of: $0)!
                contacts_AArrObj.append(constactObj)
                contactNoArrId.add(contacts_AArrObj[i].value(forKey: "contact_id")!)
                contactNameArrId.add(contacts_AArrObj[i].value(forKey: "contact_name")!)
                contact_details = contacts_AArrObj[i].value(forKey: "contact_details")! as! String
                
            }
            
            
        }
        
        return ["contacts_AArrObj" : contacts_AArrObj, "contactNoArrId" : contactNoArrId, "contactNameArrId" : contactNameArrId, "contact_details" : contact_details]
        
    }
    
    
    
    func base64ToString(_ string : String) -> String {
        let decodedData = Data(base64Encoded: string, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
        if decodedData != nil
        {
            let decodedString = NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue)
            if(decodedString != nil)
            {
                if(string != "" && decodedString == "")
                {
                    return string
                }
                else
                {
                    return decodedString! as String
                }
            }
            else
            {
                return string
            }
        }
        else
        {
            return string
        }
    }
    
    
    
    func returnSizeinMB(byteCount:Int)->Double
    {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        var string = bcf.string(fromByteCount: Int64(byteCount))
        string = string.replacingOccurrences(of: "MB", with: "")
        string = string.replacingOccurrences(of: " ", with: "")
        if(string == "")
        {
            string = "0.0"
        }
        return Double(string)!
    }
    
    func returnSizeinMBStr(byteCount:Int)->String
    {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        var string = bcf.string(fromByteCount: Int64(byteCount))
        if(string == "")
        {
            string = "0.0"
        }
        return string
    }
    
    func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }
    
    func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    
    func setShadowonLabel(_ label : UILabel, _ color: UIColor)
    {
        label.layer.shadowColor = color.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.masksToBounds = false
    }
    
    func blurredImage(with sourceImage: UIImage?) -> UIImage? {
        //  Create our blurred image
        let context = CIContext(options: nil)
        var inputImage: CIImage? = nil
        if let anImage = sourceImage?.cgImage {
            inputImage = CIImage(cgImage: anImage)
        }
        //  Setting up Gaussian Blur
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(15.0, forKey: "inputRadius")
        let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage
        /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
         *  up exactly to the bounds of our original image */
        var cgImage: CGImage? = nil
        if let aResult = result {
            cgImage = context.createCGImage(aResult, from: inputImage?.extent ?? CGRect.zero)
        }
        var retVal: UIImage? = nil
        if let anImage = cgImage {
            retVal = UIImage(cgImage: anImage)
        }
        
        return retVal
    }
    
    func jssAlertView(viewController:UIViewController,title:String,text:String,buttonTxt:String,color:UIColor){
        _ = JSSAlertView().show(viewController,title: title,text: text,buttonText: buttonTxt,color:color)
        //  return alertView
    }
    
    
    func showprogressAlert(controller : UIViewController)
    {
        progressAlert = UIAlertController(title: "Preparing", message: " ", preferredStyle: .alert)
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.setProgress(0.0, animated: true)
        progressBar.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
        progressAlert.view.addSubview(progressBar)
        controller.presentView(progressAlert, animated: true)
    }
    
    func setprogressinAlert(controller : UIViewController, progress : Float, completionHandler: (() -> Swift.Void)? = nil)
    {
        self.progressBar.setProgress(progress, animated: true)

        if(progress == 1.0)
        {
            if(completionHandler != nil)
            {
                controller.navigationController?.dismissView(animated: true, completion: {
                    if(completionHandler != nil)
                    {
                        completionHandler!()
                    }
                })
            }
            else
            {
                controller.navigationController?.dismissView(animated: true, completion: nil)
            }
        }
    }

    func activityView(View:UIView){
        

        spinner.frame = CGRect(x: View.center.x - 30, y: View.center.y - 30, width: 60, height: 60)
        spinner.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 237/255, alpha: 1.0);
        
        spinner.layer.masksToBounds = true
        spinner.layer.cornerRadius = spinner.frame.width / 2
        
        spinnerView.frame=CGRect(x: 2.5, y: 2.5, width: 55, height: 55)
        spinnerView.lineWidth = 2.5;
        spinnerView.tintColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0);
        
        spinnerView.startAnimating()
        
        spinner.addSubview(spinnerView)
        View.addSubview(spinner)
        // Add it as a subview
    }
    
    func progressView(View:UIView, Message: String){
        progressView = UIView()
        progressView.frame = CGRect(x: View.center.x - 100, y: View.center.y - 100, width: 200, height: 200)
        progressView.backgroundColor = UIColor.lightGray
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 10
        
        autoCircularProgressView = MRCircularProgressView()
        autoCircularProgressView.backgroundColor = UIColor.clear
        autoCircularProgressView.frame = CGRect(x: 50, y: 30, width: 100, height: 100)
        autoCircularProgressView.progressColor = UIColor.white
        autoCircularProgressView.progressArcWidth = 3.0
        
        success_img = UIImageView()
        success_img.frame = CGRect(x: 70, y: 50, width: 60, height: 60)
        success_img.backgroundColor = UIColor.clear
        success_img.isHidden = true
        
        restore_lbl = UILabel()
        restore_lbl.frame = CGRect(x: 0, y: 140, width: 200, height: 40)
        restore_lbl.text = Message
        restore_lbl.textColor = UIColor.white
        restore_lbl.textAlignment = .center
        restore_lbl.font = UIFont.systemFont(ofSize:16.0)
        
        progressView.addSubview(self.autoCircularProgressView)
        progressView.addSubview(success_img)
        progressView.addSubview(restore_lbl)
        
        let doesContain = View.subviews.contains(progressView)
        if(!doesContain)
        {
            View.addSubview(progressView)
        }
        // Add it as a subview
    }
    
    func Setprogress(progress:CGFloat)
    {
        self.autoCircularProgressView.setProgress(progress, animated: true)
    }
    
    func successProgressView(View:UIView, Message : String)
    {
        success_img.image = #imageLiteral(resourceName: "singletick_white")
        success_img.isHidden = false
        restore_lbl.text = Message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.progressView.removeFromSuperview()
            self.autoCircularProgressView = nil
        })
    }
    
    func failureprogressView(View:UIView)
    {
        success_img.image = #imageLiteral(resourceName: "close_view")
        success_img.isHidden = false
        restore_lbl.text = "Error Occurred"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.progressView.removeFromSuperview()
            self.autoCircularProgressView = nil
        })
    }
    
    func RemoveactivityView(View:UIView)
    {
        spinnerView.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        if let img = cache.object(forKey: url.absoluteString as NSString){
            return img
        }
        else{
            let asset: AVAsset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            
            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                cache.setObject(UIImage(cgImage: thumbnailImage), forKey: url.absoluteString  as NSString)
                return UIImage(cgImage: thumbnailImage)
            } catch let error {
                print(error)
            }
            
            return nil
        }
    }
    
    func AddTopBorder(View:UIView,color:UIColor,width:CGFloat)
    {
        let border:CALayer = CALayer()
        border.backgroundColor = color.cgColor;
        border.frame = CGRect(x: 0, y: 0, width: View.frame.size.width, height: width)
        View.layer.addSublayer(border)
        
    }
    func AddBottomBorder(View:UIView,color:UIColor,width:CGFloat)
    {
        let border:CALayer = CALayer()
        border.backgroundColor = color.cgColor;
        border.frame = CGRect(x: 0, y: View.frame.size.height - width, width: View.frame.size.width, height: width)
        View.layer.addSublayer(border)
        
    }
    func AddTwoBorder(View:UIView,color:UIColor,width:CGFloat)
    {
        
        let topborder:CALayer = CALayer()
        topborder.backgroundColor = color.cgColor;
        topborder.frame = CGRect(x: 0, y: 0, width: View.frame.size.width, height: width)
        let bottomborder:CALayer = CALayer()
        bottomborder.backgroundColor = color.cgColor;
        bottomborder.frame = CGRect(x: 0, y: View.frame.size.height - width, width: View.frame.size.width, height: width)
        View.layer.addSublayer(topborder)
        View.layer.addSublayer(bottomborder)
        
        
    }
    func isNumeric(value: String) -> Bool{
        let onlyDigits: CharacterSet = CharacterSet.decimalDigits.inverted
        if value.rangeOfCharacter(from: onlyDigits) == nil {
            return true
        }
        return false
        //        let num = "[^0-9]"
        //        let test = NSPredicate(format: "SELF MATCHES %@", num)
        //        let result =  test.evaluate(with: value)
        //        return result
    }
    func isValidPhNo(value: String) -> Bool {
        let num = "[0-9]{10}$";
        let test = NSPredicate(format: "SELF MATCHES %@", num)
        let result =  test.evaluate(with: value)
        return result
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    func saveLanguage( str:NSString) {
        var str = str
        if(str.isEqual(to: "ta"))      {
            str="ta"
        }
        if(str.isEqual(to: "en")) {
            str="en"
        }
        UserDefaults.standard.set(str, forKey: "LanguageName")
        UserDefaults.standard.synchronize()
    }
    func SetLanguageToApp(){
        let savedLang=UserDefaults.standard.object(forKey: "LanguageName") as! NSString
        if(savedLang == "ta") {
            languageHandler.setApplicationLanguage(language: languageHandler.TamilLanguageShortName)
        }
        if(savedLang == "en"){
            
            languageHandler.setApplicationLanguage(language: languageHandler.EnglishUSLanguageShortName)
        }
    }
    func setLang(title:String) -> String{
        
        return languageHandler.VJLocalizedString(key:title , comment: nil)
        
    }
    
    func CheckNullvalue(Passed_value:Any?) -> String {
        var Param:Any?=Passed_value
        if(Param == nil || Param is NSNull)
        {
            Param=""
        }
        else
        {
            Param = String(describing: Passed_value!)
        }
        return Param as! String
    }
    
    func Getuser_id()->String
    {
        var user_id:NSString=""
        let user_Arr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: nil, FetchString: nil, SortDescriptor: nil) as! NSArray
        
        if(user_Arr.count > 0)
        {
            
            for i in 0..<user_Arr.count
            {
                let ManagedObj=user_Arr[i] as! NSManagedObject
                user_id = self.CheckNullvalue(Passed_value:ManagedObj.value(forKey: "user_id"))  as NSString;
                
            }
        }
        
        
        return user_id as String
    }
    
    func GetMyProfilePic()->String
    {
        var profilepic:NSString=""
        let user_Arr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil, SortDescriptor: nil) as! NSArray
        
        if(user_Arr.count > 0)
        {
            
            for i in 0..<user_Arr.count
            {
                let ManagedObj=user_Arr[i] as! NSManagedObject
                profilepic = self.CheckNullvalue(Passed_value:ManagedObj.value(forKey: "profilepic"))  as NSString;
                
            }
        }
        
        
        return profilepic as String
    }
    
    func GetMyPhonenumber()->String
    {
        return self.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "mobilenumber")
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    func returnisSecret(user_id:String)->String
    {
        return "no"
    }
    
    
    func GetsingleDetail(entityname:String,attrib_name:String,fetchString:String,returnStr:String)->String
    {
        var ReturnString:String = ""
        let predic = NSPredicate(format: "\(attrib_name) = %@",fetchString)
        
        var ManagedObj:NSManagedObject?
        let USerArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: entityname, SortDescriptor: nil, predicate: predic, Limit: 1) as! NSArray
        if(USerArr.count > 0)
        {
            for i in 0..<USerArr.count
            {
                ManagedObj=USerArr[i] as? NSManagedObject
                ReturnString = self.CheckNullvalue(Passed_value: ManagedObj?.value(forKey: returnStr))
            }
        }
        return ReturnString
    }
    
    func getOriginalPhoneInCountryformat(id: String, alternate_id : String) -> String
    {
        let number = self.GetsingleDetail(entityname: Constant.sharedinstance.Contact_add, attrib_name: "contact_id", fetchString: id, returnStr: "contact_original")
        if(number == "")
        {
            return self.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: alternate_id, returnStr: "msisdn")
        }
        return number
    }
    
    
    
    func saveCounrtyphone(countrycode: String) {
        UserDefaults.standard.set(countrycode, forKey: "countryphone")
        UserDefaults.standard.synchronize()
    }
    func ShowNotification(_ subtitle:String, _ success : Bool)
    {
        SWMessage.sharedInstance.showNotificationWithTitle(
            Themes.sharedInstance.GetAppname(),
            subtitle: subtitle,
            type: success ? .success : .warning
        )
        if UIDevice.isIphoneX{
            SWMessage.sharedInstance.offsetHeightForMessage = 0
        }
        else{
            SWMessage.sharedInstance.offsetHeightForMessage = 0
        }
        
    }
    func convertImageToBase64(imageData: Data) -> String {
        let base64String = imageData.base64EncodedString()
        
        return base64String
    }
    
    func GetAppname()->String
    {
        let appname:String = self.CheckNullvalue(Passed_value: Bundle.main.infoDictionary!["CFBundleDisplayName"])
        return appname
        
    }
    
    func compressTo(_ expectedSizeInMb:Int, _ image : UIImage) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = image.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return self.resizeImage(image: UIImage(data: data)!)
            }
        }
        return nil
    }
    
    func resizeImage(image: UIImage) -> Data? {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = (actualHeight >= actualWidth) ? Float(UIScreen.main.bounds.size.height) : Float(UIScreen.main.bounds.size.width)
        let maxWidth: Float = (actualHeight >= actualWidth) ? Float(UIScreen.main.bounds.size.width) : Float(UIScreen.main.bounds.size.height)
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img!.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return imageData
    }
    
    func ReturnFavName(opponentDetailsID:String, msginid:String)->String
    {
        let FavArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: opponentDetailsID, SortDescriptor: nil) as! [Favourite_Contact]
        
        var name:String = ""
        if(FavArr.count > 0)
        {
            let ResponseDict = FavArr[0]
            name = CheckNullvalue(Passed_value: ResponseDict.name)
            if(name == "")
            {
                name = CheckNullvalue(Passed_value: ResponseDict.formatted)
            }
        }
        else
        {
            name = msginid.parseNumber
        }
        return name
        
    }
    
    func shouldSortChatObj(first:Any, second:Any) -> Bool{
        var date1 = ""
        var date2 = ""
        if let localObj = first as? Chatpreloadrecord{
            date1 = localObj.opponentlastmessageDate
        }else if let localObj = first as? GroupDetail{
            date1 = localObj.opponentlastmessageDate
        }
        
        if let localObj = second as? Chatpreloadrecord{
            date2 = localObj.opponentlastmessageDate
        }else if let localObj = second as? GroupDetail{
            date2 = localObj.opponentlastmessageDate
        }
        let x = date1 > date2
        return x
        
    }
    
    func shouldSortChatMessage(first:Any, second:Any) -> Bool{
        var date1 = ""
        var date2 = ""
        if let localObj = first as? Chatpreloadrecord{
            date1 = localObj.messageCount
        }
        
        if let localObj = second as? Chatpreloadrecord{
            date2 = localObj.messageCount
        }
        return date1 > date2
    }
    
    func getAppVersion() -> String
    {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        return "\(version)"
    }
    
    func getMediaDuration(url: NSURL!) -> String{
        let asset : AVURLAsset = AVURLAsset(url: url as URL)
        let duration : CMTime = asset.duration
        
        let seconds : CLong = CLong(CMTimeGetSeconds(duration) * 1000)
        return "\(seconds)"
    }
    
    func getMonth(monthInInt : Int) -> String
    {
        let monthParam = [1 : "January", 2 : "Febraury", 3 : "March", 4 : "April", 5 : "May", 6 : "June", 7 : "July", 8 : "August", 9 : "September", 10 : "October", 11 : "November", 12 : "December"]
        
        return CheckNullvalue(Passed_value: monthParam[monthInInt])
    }
    
    
    func AddDifferenceinTimeStamp(timestamp : String) -> String
    {
        return timestamp
    }
    
    func getID_Range_Payload_Name(message : String) -> [Any]
    {
        var payload = message
        var groupUsers = [NSDictionary]()
        let GroupDetail : [NSManagedObject] = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: nil, FetchString: nil, SortDescriptor: nil) as! [NSManagedObject]
        var ids = [String]()
        var ranges = [NSRange]()
        var names = [String]()
        if((payload.slice(from: "@@***", to: "@@***")?.removingWhitespaces() != nil && payload.slice(from: "@@***", to: "@@***")?.removingWhitespaces() != ""))
        {
            repeat{
                let checkID = self.CheckNullvalue(Passed_value: payload.slice(from: "@@***", to: "@@***"))
                let id = self.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkID, returnStr: "id")
                var name = self.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkID, returnStr: "name")
                if(name == "")
                {
                    name = self.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkID, returnStr: "msisdn")
                }
                if(id != "")
                {
                    var idArr = [String]()
                    var NameArr = [String]()
                    idArr.append(id)
                    NameArr.append(name)
                    
                    _ = idArr.map{
                        let index = idArr.index(of: $0)!
                        let id = "@@***" + $0 + "@@***"
                        var range = payload.nsRange(from: payload.range(of: id)!)
                        ids.append($0)
                        payload = (payload as NSString).replacingCharacters(in: range, with: "@" + NameArr[index]) as String
                        range = NSMakeRange(range.location + 1, NameArr[index].length)
                        ranges.append(range)
                        names.append("@" + NameArr[index])
                    }
                }
                else
                {
                    if(GroupDetail.count > 0)
                    {
                        var dict : NSDictionary?
                        for i in 0..<GroupDetail.count {
                            let ReponseDict = GroupDetail[i]
                            let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                            groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! [NSDictionary]
                            for dic in groupUsers {
                                if(self.CheckNullvalue(Passed_value: dic.value(forKey: "id")) == checkID)
                                {
                                    dict = dic
                                    break
                                }
                            }
                        }
                        if(dict != nil)
                        {
                            name = self.CheckNullvalue(Passed_value: dict?.value(forKey: "Name"))
                            
                            let isExitsContact = self.CheckNullvalue(Passed_value: dict?.value(forKey: "isExitsContact"))
                            if(isExitsContact == "1")
                            {
                                name = self.CheckNullvalue(Passed_value: dict?.value(forKey: "ContactName"))
                            }
                            if(name == "")
                            {
                                name = self.CheckNullvalue(Passed_value: dict?.value(forKey: "msisdn"))
                            }
                            let id = "@@***" + self.CheckNullvalue(Passed_value: dict?.value(forKey: "id")) + "@@***"
                            var range = payload.nsRange(from: payload.range(of: id)!)
                            ids.append(self.CheckNullvalue(Passed_value: dict?.value(forKey: "id")))
                            payload = (payload as NSString).replacingCharacters(in: range, with: "@" + name) as String
                            range = NSMakeRange(range.location+1, name.length)
                            ranges.append(range)
                            names.append("@" + name)
                        }
                        else
                        {
                            let id = "@@***" + checkID + "@@***"
                            var range = payload.nsRange(from: payload.range(of: id)!)
                            ids.append(self.CheckNullvalue(Passed_value: checkID))
                            payload = (payload as NSString).replacingCharacters(in: range, with: "") as String
                            range = NSMakeRange(range.location, 0)
                            ranges.append(range)
                            names.append("")
                        }
                    }
                }
            }
                while(payload.slice(from: "@@***", to: "@@***")?.removingWhitespaces() != nil && payload.slice(from: "@@***", to: "@@***")?.removingWhitespaces() != "")
            
            return [ids, ranges, payload, names]
        }
        else
        {
            return [ids, ranges, payload, names]
        }
    }
    
    func createUniqueContactID(ID: String, index: Int) -> String {
        if(index == 0)
        {
            return ID
        }
        return ID + "@\(index)"
    }
    
    func removeUniqueContactID(ID: String) -> String {
        return CheckNullvalue(Passed_value: ID.components(separatedBy: "@").first)
    }
    
    // MARK: Lock Actions
    
    func isChatLocked(id:String, type: String) -> Bool{
        
        let attribute = (type == "single") ? "id" : "groupId"
        let lockedArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: id, SortDescriptor: nil) as! [Lock_Details]
        if(lockedArr.count > 0)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func LockAction(id:String, type: String){}
    
    func enterTochat(id: String, type: String, completion: @escaping (_ success: Bool) -> Void)
    {
        AppDelegate.sharedInstance.navigationController?.dismissView(animated: true, completion: nil)

        let attribute = (type == "single") ? "id" : "groupId"
        
        let lockedArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: id, SortDescriptor: nil) as! [Lock_Details]

        var convId:String = ""
        var encrypt_password:String = ""
        if(lockedArr.count > 0){
            let response = lockedArr[0]
            convId = CheckNullvalue(Passed_value: response.convId)
            encrypt_password = CheckNullvalue(Passed_value: response.encrypt_password)
        }
        let alert = UIAlertController(title: GetAppname(), message: "Enter Chat Password", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        
        alert.addTextField(configurationHandler: {
            (textField) in
            textField.placeholder = "Enter Chat Password"
            textField.isSecureTextEntry = true
        })
        
        let confirmAction = UIAlertAction(title: "Chat", style: .default) { (_) in
            print((alert.textFields?[0].text!)!)
            let password:String = (alert.textFields?[0].text!)!
            let str:NSData = password.data(using: String.Encoding.utf8)! as NSData
            let key:NSData = convId.data(using: String.Encoding.utf8)! as NSData
            let iv:NSData = (self.GetAppname()).data(using: String.Encoding.utf8)! as NSData
            var base64:String = ""
            do{
                let encrypt:NSData = try CC.crypt(.encrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: str as Data, key: key as Data, iv: iv as Data) as NSData
                let encrypted:NSData = encrypt.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0)) as NSData
                base64 = NSString(data: encrypted as Data, encoding: String.Encoding.utf8.rawValue)! as String
                print(base64)
            }catch{
                
            }
            // decrypt String(data: (CC.crypt(.decrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: Data(base64Encoded: encrypt_password)!, key: key as Data, iv: iv as Data) as Data), encoding: String.Encoding.utf8)
            if(base64 == encrypt_password){
                completion(true)
            }else{
                Themes.sharedInstance.ShowNotification("Password incorrect", false)
                completion(false)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        AppDelegate.sharedInstance.navigationController?.presentView(alert, animated: true)
    }
    
    func Mute_unMutechats(id:String, type: String)
    {
        
        let attribute = (type == "group") ? "groupId" : "id"
        let muteArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Mute_chats, attribute: attribute, FetchString: id, SortDescriptor: nil) as! [Mute_chats]
        var convId:String = ""
        if(muteArr.count > 0)
        {
            let response = muteArr[0]
            convId = CheckNullvalue(Passed_value: response.convId)
            let dic:[AnyHashable: Any] = ["from":Getuser_id(),"to":id,"option":"","type":type,"status":"0","secret_type":"0","notify_status":"0","convId":convId]
            SocketIOManager.sharedInstance.muteChat(param: dic as! [String : Any])
        }
        else
        {
            convId = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "opponent_id", fetchString: id, returnStr: "conv_id")
            let optionMenu = UIAlertController(title: nil, message:  "Choose option", preferredStyle: .actionSheet)
            
            // 2
            let eightHrAction = UIAlertAction(title: "8 Hours", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("File Deleted")
                let dic:[AnyHashable: Any] = ["from":self.Getuser_id(),"to":id,"option":"8 Hours","type":type,"status":"1","secret_type":"0","notify_status":"0","convId":convId]
                SocketIOManager.sharedInstance.muteChat(param: dic as! [String : Any])
                
            })
            let oneWeekAction = UIAlertAction(title: "1 Week", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("File Saved")
                let dic:[AnyHashable: Any] = ["from":self.Getuser_id(),"to":id,"option":"1 Week","type":type,"status":"1","secret_type":"0","notify_status":"0","convId":convId]
                SocketIOManager.sharedInstance.muteChat(param: dic as! [String : Any])
                
            })
            let oneYearAction = UIAlertAction(title: "1 Year", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("File Saved")
                let dic:[AnyHashable: Any] = ["from":self.Getuser_id(),"to":id,"option":"1 Year","type":type,"status":"1","secret_type":"0","notify_status":"0","convId":convId]
                SocketIOManager.sharedInstance.muteChat(param: dic as! [String : Any])
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            optionMenu.addAction(eightHrAction)
            optionMenu.addAction(oneWeekAction)
            optionMenu.addAction(oneYearAction)
            optionMenu.addAction(cancelAction)
            AppDelegate.sharedInstance.navigationController?.presentView(optionMenu, animated: true)
        }
    }
    
    func CheckMuteChats(id:String, type: String) -> Bool
    {
        let muteArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Mute_chats, attribute: "user_id", FetchString: Getuser_id(), SortDescriptor: nil) as! [Mute_chats]
        
        _ = muteArr.map {
            let option = $0.option
            var date = Date(timeIntervalSince1970: TimeInterval(Int($0.timestamp ?? "0")!/1000))
            let calendar = Calendar.current
            var date_component = DateComponents()
            
            if(option == "8 Hours"){
                date_component.hour = 8
                date = calendar.date(byAdding: date_component, to: date)!
            }else if(option == "1 Week"){
                date_component.day = 7
                date = calendar.date(byAdding: date_component, to: date)!
            }else if(option == "1 Year"){
                date_component.year = 1
                date = calendar.date(byAdding: date_component, to: date)!
            }
            let currentDate = Date()
            if date < currentDate  {
                let convId = CheckNullvalue(Passed_value: $0.convId)
                
                let predicate:NSPredicate = NSPredicate(format: "convId == %@", convId)
                
                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Mute_chats, Predicatefromat: predicate, Deletestring: convId, AttributeName: "convId")
            }
        }
        let attribute = (type == "group") ? "groupId" : "id"
        let mute = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Mute_chats, attribute: attribute, FetchString: id)
        return mute
    }
    
    func muteOption(id:String, type: String) -> String{
        let attribute = (type == "group") ? "groupId" : "id"
        let muteArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Mute_chats, attribute: attribute, FetchString: id, SortDescriptor: nil) as! [Mute_chats]
        if muteArr.count > 0 {
            let response = muteArr[0]
            return CheckNullvalue(Passed_value: response.option)
        }
        return "No"
    }
    
    func saveToGallryOption(id:String) -> String{
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: id, attribute: "user_common_id", UpdationElements: ["isSavetocamera":"0"])
        let muteArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: id, SortDescriptor: nil) as! [Chat_intiated_details]
        if muteArr.count > 0 {
            let options = CheckNullvalue(Passed_value: muteArr[0].isSavetocamera)
            switch options {
            case "0":
                return "Never"
            case "1":
                return "Always"
            case "2":
                return "Default"
            default:
                return "Never"
            }
        }
        return "Default"
    }
    
    
    func savetoCameraRollUpdate(_ id : String){
        let optionMenu = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Default(On)", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let UpdateDict:NSDictionary =  ["isSavetocamera":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: id, attribute: "user_common_id", UpdationElements: UpdateDict)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
            
        })
        let alwaysAction = UIAlertAction(title: "Always", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let UpdateDict:NSDictionary =  ["isSavetocamera":"1"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: id, attribute: "user_common_id", UpdationElements: UpdateDict)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
        })
        
        let neverAction = UIAlertAction(title: "Never", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let UpdateDict:NSDictionary =  ["isSavetocamera":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: id, attribute: "user_common_id", UpdationElements: UpdateDict)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
        })
        
        optionMenu.addAction(defaultAction)
        optionMenu.addAction(alwaysAction)
        optionMenu.addAction(neverAction)
        optionMenu.addAction(cancelAction)
        AppDelegate.sharedInstance.navigationController?.presentView(optionMenu, animated: true)
        
    }
    
    func shareOnTwitter(){
        if UIApplication.shared.canOpenURL(URL(string:"twitter://")!) {
            let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
            vc?.setInitialText(Constant.sharedinstance.ShareText)
            AppDelegate.sharedInstance.navigationController?.presentView(vc!, animated: true)
        } else {
            AppDelegate.sharedInstance.window?.makeToast(message: "Please Install Twitter to share", duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    func shareOnFacebook() {
        if UIApplication.shared.canOpenURL(URL(string:"fb://")!) {
            let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
            vc?.setInitialText(Constant.sharedinstance.ShareText)
            AppDelegate.sharedInstance.navigationController?.presentView(vc!, animated: true)
        } else {
            AppDelegate.sharedInstance.window?.makeToast(message: "Please Install Facebook to share", duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    func getBaseURL() -> String
    {
        let checkBaseURLs = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: "BaseURL", attribute: nil, FetchString: nil)
        if(!checkBaseURLs)
        {
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: ["baseURL" : BaseURLArray[0]], Entityname: "BaseURL")
        }
        let BaseURLs = DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: "BaseURL") as! [BaseURL]
        var url = String()
        _ = BaseURLs.map {
            url = CheckNullvalue(Passed_value: $0.baseURL)
        }
        return url
    }
    
    func getURL() -> String {
        return Signing.Development ? getBaseURL() : BaseURLArray[0]
    }
    
    func changeURL() {
        let url = getBaseURL()
        var setURL = ""
        if BaseURLArray.contains(url) {
            setURL = BaseURLArray[((BaseURLArray as NSArray).index(of: url) + 1 > BaseURLArray.count - 1) ? 0 : (BaseURLArray as NSArray).index(of: url) + 1]
        }
        else
        {
            setURL = BaseURLArray[0]
        }
        print(setURL)
        DatabaseHandler.sharedInstance.UpdateData(Entityname: "BaseURL", FetchString: url, attribute: "baseURL", UpdationElements: ["baseURL" : setURL])
        AppDelegate.sharedInstance.window?.makeToast(message: "URL Changed to " + setURL, duration: 3, position: HRToastActivityPositionDefault)
    }
    func executeClearOpponentChat(_ star_status:String, _ opponentID : String ,_ timestamp : String)
    {
        activityView(View: (AppDelegate.sharedInstance.window?.view)!)
        if(opponentID == "") {
            let ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Getuser_id(), SortDescriptor: "timestamp") as! [Chat_intiated_details]
            _ = ChatArr.map {
                let conv_id : String = CheckNullvalue(Passed_value: $0.conv_id)
                let type : String = CheckNullvalue(Passed_value: $0.chat_type)
                if(conv_id != "")
                {
                    let DataDict = ["from":Getuser_id(),"convId":conv_id,"type":type,"star_status":star_status,"lastId":timestamp]
                    SocketIOManager.sharedInstance.clearChat(Param: DataDict)
                    
                }
            }
        }
        else
        {
            let user_common_id = "\(Getuser_id())-\(opponentID)"
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "conv_id")
                let chat_type:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "chat_type")
                
                if(conv_id != "")
                {
                    let DataDict = ["from":Getuser_id(),"convId":conv_id,"type":chat_type,"star_status":star_status,"lastId":timestamp]
                    SocketIOManager.sharedInstance.clearChat(Param: DataDict)
                }
            }
        }
    }
    func deleteOpponentChats(_ opponentID: String,_ convId: String, is_delete: Bool ,_ lastId:String) {
        
        if(convId != "")
        {
            let param:[String : Any] = ["from":Getuser_id(),"convId":convId,"type":"single","lastId":lastId]
            SocketIOManager.sharedInstance.deleteHistory(Param: param)
        }
        
    }
    func executeDeleteHistory(_ star_status:String, _ opponentID : String, _ is_delete : Bool ,_ timestamp:String)
    {
        if(opponentID == "") {
            let ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Getuser_id(), SortDescriptor: "timestamp") as! [Chat_intiated_details]
            _ = ChatArr.map {
                let conv_id : String = CheckNullvalue(Passed_value: $0.conv_id)
                let type : String = CheckNullvalue(Passed_value: $0.chat_type)
                if(conv_id != "")
                {
                    var isdelete : String = "0"
                    if(is_delete)
                    {
                        isdelete = "1"
                    }
                    let param:[String : Any] = ["from":Getuser_id(),"convId":conv_id,"type":type,"star_status":star_status,"lastId":timestamp,"delete_opponent":isdelete]
                    SocketIOManager.sharedInstance.deleteChat(Param: param)
                }
            }
        }
        else
        {
            let user_common_id = "\(Getuser_id())-\(opponentID)"
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "conv_id")
                let chat_type:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "chat_type")
                
                if(conv_id != "")
                {
                    
                    
                    var isdelete : String = "0"
                    if(is_delete)
                    {
                        isdelete = "1"
                    }
                    let param:[String : Any] = ["from":Getuser_id(),"convId":conv_id,"type":chat_type,"star_status":star_status,"lastId":timestamp,"delete_opponent":isdelete]
                    SocketIOManager.sharedInstance.deleteChat(Param: param)
                }
            }
        }
    }
    
    func ClearChat(_ star_status:String, _ opponentID : String, _ is_delete : Bool ,_ timestamp:String)
    {
        activityView(View: (AppDelegate.sharedInstance.window?.view)!)
        if(opponentID == "") {
            let ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Getuser_id(), SortDescriptor: "timestamp") as! [Chat_intiated_details]
            _ = ChatArr.map {
                let conv_id : String = CheckNullvalue(Passed_value: $0.conv_id)
                let type : String = CheckNullvalue(Passed_value: $0.chat_type)
                if(conv_id != "")
                {
                    var status = "0"
                    if is_delete {
                        status = "1"
                    }
                    let DataDict:NSDictionary = ["from":Getuser_id(),"convId":conv_id,"type":type,"star_status":star_status,"delete_opponent":status,"lastId":timestamp]
                    print("DataDict =>\(DataDict)")
                    SocketIOManager.sharedInstance.ClearChatDetails(Dict: DataDict)
                }
            }
        }
        else
        {
            let user_common_id = "\(Getuser_id())-\(opponentID)"
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "conv_id")
                let chat_type:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "chat_type")
                
                if(conv_id != "")
                {
                    var status = "0"
                    if is_delete {
                        status = "1"
                    }
                    let DataDict:NSDictionary = ["from":Getuser_id(),"convId":conv_id,"type":chat_type,"star_status":star_status,"delete_opponent":status]
                    SocketIOManager.sharedInstance.ClearChatDetails(Dict: DataDict)
                    
                }
            }
        }
    }
    
    func executeClearChat(_ star_status:String, _ opponentID : String, _ is_delete : Bool)
    {
        activityView(View: (AppDelegate.sharedInstance.window?.view)!)
        if(opponentID == "") {
            let ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Getuser_id(), SortDescriptor: "timestamp") as! [Chat_intiated_details]
            _ = ChatArr.map {
                let conv_id : String = CheckNullvalue(Passed_value: $0.conv_id)
                let type : String = CheckNullvalue(Passed_value: $0.chat_type)
                if(conv_id != "")
                {
                    let DataDict:NSDictionary = ["from":Getuser_id(),"convId":conv_id,"type":type,"star_status":star_status]
                    SocketIOManager.sharedInstance.ClearChatDetails(Dict: DataDict)
                    if(is_delete)
                    {
                        let param:[String : Any] = ["from":Getuser_id(),"convId":conv_id,"type":type]
                        SocketIOManager.sharedInstance.deleteChat(Param: param)
                    }
                }
            }
        }
        else
        {
            let user_common_id = "\(Getuser_id())-\(opponentID)"
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "conv_id")
                let chat_type:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "chat_type")
                
                if(conv_id != "")
                {
                    let DataDict:NSDictionary = ["from":Getuser_id(),"convId":conv_id,"type":chat_type,"star_status":star_status]
                    SocketIOManager.sharedInstance.ClearChatDetails(Dict: DataDict)
                    print("DataDict =>\(DataDict)")
                    if(is_delete)
                    {
                        let param:[String : Any] = ["from":Getuser_id(),"convId":conv_id,"type":chat_type]
                        SocketIOManager.sharedInstance.deleteChat(Param: param)
                    }
                }
            }
        }
    }
    
    func clearExceptStarChats(_ star_status: String, _ opponentID: String, is_delete: Bool, timeStamp:String) {
        var time_stamp = ""
        if timeStamp == "" {
            time_stamp = "0"
        }else {
            time_stamp = timeStamp
        }
        let user_common_id = "\(Getuser_id())-\(opponentID)"
        let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
        if(CheckinitiatedDetails)
        {
            let conv_id:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "conv_id")
            let opponent_id:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "opponent_id")
            let chat_type:String = GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "chat_type")
            
            var localDate = [Chat_one_one]()
            var filteredData = [Chat_one_one]()
            var staredFilteredData = [Chat_one_one]()
            if let timeStamp = Int(time_stamp){
                localDate = DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: Constant.sharedinstance.Chat_one_one) as! [Chat_one_one]
                filteredData = localDate.filter{((Int($0.timestamp ?? "0")!) > timeStamp)}
                staredFilteredData = localDate.filter{(((Int($0.timestamp ?? "0")!) > timeStamp) || ($0.isStar == "1"))}
            }
            
            if(conv_id != "")
            {
                if(star_status == "0")
                {
                    if filteredData.count > 0{
                        let messageDataArray = filteredData.map{(converChatToDict($0))}
                        DatabaseHandler.sharedInstance.truncateDataForTables([Constant.sharedinstance.Chat_one_one])
                        for Dict in  messageDataArray{
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Chat_one_one)
                        }
                    }else{
                        let except_star_predicate = NSPredicate(format: "user_common_id == %@",user_common_id)
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: except_star_predicate, Deletestring: user_common_id, AttributeName: "user_common_id")
                    }
                    
                }
                else
                {
                    if staredFilteredData.count > 0{
                        let messageDataArray = staredFilteredData.map{(converChatToDict($0))}
                        DatabaseHandler.sharedInstance.truncateDataForTables([Constant.sharedinstance.Chat_one_one])
                        for Dict in  messageDataArray{
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Chat_one_one)
                        }
                    }else{
                        let predic1 = NSPredicate(format: "user_common_id = %@",user_common_id)
                        let predic2 = NSPredicate(format: "isStar = %@ OR isStar = %@","0", "")
                        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predic1, predic2])
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: predicate, Deletestring: user_common_id, AttributeName: "user_common_id")
                    }
                    
                }
                
                let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: nil) as! NSArray
                if(uploadDetailArr.count > 0)
                {
                    for i in 0..<uploadDetailArr.count
                    {
                        let uploadDict = uploadDetailArr[i] as! Upload_Details
                        let isStar = GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: CheckNullvalue(Passed_value: uploadDict.upload_data_id), returnStr: "isStar")
                        let localTimeStamp = Int(GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: CheckNullvalue(Passed_value: uploadDict.upload_data_id), returnStr: "timestamp"))
                        if(isStar == "0" || star_status == "0") {
                            if let intTimeStamp = Int(time_stamp){
                                if (localTimeStamp ?? 0) < intTimeStamp{
                                    let upload_Path:String = CheckNullvalue(Passed_value: uploadDict.upload_Path)
                                    Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                                    let predic = NSPredicate(format: "upload_data_id == %@", CheckNullvalue(Passed_value: uploadDict.upload_data_id))
                                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Upload_Details, Predicatefromat: predic, Deletestring: CheckNullvalue(Passed_value: uploadDict.upload_data_id), AttributeName: "user_common_id")
                                }
                            }else{
                                let upload_Path:String = CheckNullvalue(Passed_value: uploadDict.upload_Path)
                                Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                                let predic = NSPredicate(format: "upload_data_id == %@", CheckNullvalue(Passed_value: uploadDict.upload_data_id))
                                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Upload_Details, Predicatefromat: predic, Deletestring: CheckNullvalue(Passed_value: uploadDict.upload_data_id), AttributeName: "user_common_id")
                            }
                            
                        }
                    }
                }
            }
            if(is_delete)
            {
                if(chat_type == "group")
                {
                    self.ClearOtherGroupmessages(opponent_id)
                }
                else
                {
                    if !(filteredData.count > 0){
                        self.deleteChat(opponent_id)
                    }
                }
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, userInfo: nil)
            }
            AppDelegate.sharedInstance.setBadgeCount()
            RemoveactivityView(View: (AppDelegate.sharedInstance.window?.view)!)
        }
    }
    
    func converChatToDict (_ obj : Chat_one_one)-> NSDictionary{
        let dictValue:NSDictionary = ["chat_type": Themes.sharedInstance.CheckNullvalue(Passed_value: obj.chat_type),
                                      "contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.contactmsisdn),
                                      "convId":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.convId),
                                      "created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.created_by),
                                      "date":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.date),
                                      "delivered_msg_time":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.delivered_msg_time),
                                      "doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.doc_id),
                                      "filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.filesize),
                                      "from":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.from),
                                      "height":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.height),
                                      "id":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.id),
                                      "info_type":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.info_type),
                                      "is_deleted":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.is_deleted),
                                      "is_forward":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.is_forward),
                                      "is_reply":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.is_reply),
                                      
                                      "isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.isStar),
                                      "message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.message_from),
                                      "message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.message_status),
                                      "msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.msgId),
                                      "msgrecordId":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.msgrecordId),
                                      "msgType":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.msgType),
                                      "name":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.name),
                                      "payload":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.payload),
                                      "read_msg_time":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.read_msg_time),
                                      "recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.recordId),
                                      "reply_type":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.reply_type),
                                      "secret_msg_id":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.secret_msg_id),
                                      "secret_timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.secret_timestamp),
                                      "thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.thumbnail),
                                      
                                      "contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.timestamp),
                                      "to":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.to),
                                      "type":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.type),
                                      "user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.user_common_id),
                                      "while_blocked":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.while_blocked),
                                      "width":Themes.sharedInstance.CheckNullvalue(Passed_value: obj.width)
        ]
        return dictValue
    }
    
    func ClearOtherGroupmessages(_ opponentID : String) {
        let groupDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "id", FetchString: opponentID, SortDescriptor: nil) as! [Group_details]
        _ = groupDetails.map {
            let is_deleted = CheckNullvalue(Passed_value: $0.is_deleted)
            if(is_deleted == "1")
            {
                let predic1 = NSPredicate(format: "id = %@",opponentID)
                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Group_details, Predicatefromat: predic1, Deletestring: opponentID, AttributeName: "id")
                self.deleteChat(opponentID)
            }
        }
    }
    
    func deleteChat(_ opponentID : String) {
        let user_common_id = "\(Getuser_id())-\(opponentID)"
        
        let predicate = NSPredicate(format: "user_common_id == %@", user_common_id)
        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_intiated_details, Predicatefromat: predicate, Deletestring: user_common_id, AttributeName: "user_common_id")
    }
    
    func makeGroupActionNotification(id : String) {
        if(!(AppDelegate.sharedInstance.navigationController?.topViewController is InitiateChatViewController)) {
            let from = GetsingleDetail(entityname: Constant.sharedinstance.Other_Group_message, attrib_name: "id", fetchString: id, returnStr: "from")
            let to = GetsingleDetail(entityname: Constant.sharedinstance.Other_Group_message, attrib_name: "id", fetchString: id, returnStr: "person_id")
            let group_type = GetsingleDetail(entityname: Constant.sharedinstance.Other_Group_message, attrib_name: "id", fetchString: id, returnStr: "group_type")

            if(from != self.Getuser_id())
            {
                let groupName = GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: GetsingleDetail(entityname: Constant.sharedinstance.Other_Group_message, attrib_name: "id", fetchString: id, returnStr: "group_id"), returnStr: "displayName")
                let Message = self.returnOtherMessages(from, to, group_type)
                let state = UIApplication.shared.applicationState
                if(state == .active) {
                    if(notificationBar.CheckNotificationbarisHidden())
                    {
                        var style:GLNotificationStyle!
                        style = .detailedBanner
                        notificationBar = GLNotificationBar(title: groupName, message:Message , preferredStyle:style) { (bool) in
                        }
                        notificationBar.showTime(2.0)
                        self.playSound(nil)
                    }
                }
                else{
                    
                    let content = UNMutableNotificationContent()
                    content.title = groupName 
                    content.body = Message
                    self.playSound(content)
                    let request = UNNotificationRequest(identifier:"group" + "-" + fourUniqueDigits, content: content, trigger: nil)
                    
                    UNUserNotificationCenter.current().delegate = self
                    UNUserNotificationCenter.current().add(request){(error) in
                        if (error != nil){
                        }
                    }
                }
            }
        }
    }
    
    func playSound( _ content : UNMutableNotificationContent?) {
        
        let getsound = GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Getuser_id(), returnStr: "group_sound")
        
        if(getsound == "Default") {
            let isSound = (GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Getuser_id(), returnStr: "is_sound") as NSString).boolValue
            let isVibrate = (GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Getuser_id(), returnStr: "is_vibrate") as NSString).boolValue
            if(isSound) {
                if(content != nil){
                    content?.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notification.caf"))
                }
                else{
                    AppDelegate.sharedInstance.PlayAudio(tone: "notification", type: "caf", isrepeat: false)
                }
            }
            if(isVibrate) {
                AppDelegate.sharedInstance.playNotificationSound(vibrate: isVibrate, systemSound: 0)
            }
        }
        else
        {
            AppDelegate.sharedInstance.setNotificationSound()
        }

    }
    
    func getUnreadChatCount(_ isTotal : Bool) -> Int {
        let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
        if(CheckLogin)
        {
            let CheckPreloadRecord=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Getuser_id())
            if(CheckPreloadRecord){
                var count = 0
                var predicate = NSCompoundPredicate()
                if isTotal {
                    let p1 = NSPredicate(format: "is_archived = %@", "0")
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
                    
                    let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! [Chat_intiated_details]
                    
                    
                    _ = chatintiatedDetailArr.map {
                        let chat_count = CheckNullvalue(Passed_value: $0.chat_count)
                        count = count + Int(chat_count == "" ? "0" : chat_count)!
                    }
                }
                else {
                    let p1 = NSPredicate(format: "is_archived = %@", "0")
                    let p2 = NSPredicate(format: "chat_type != %@", "secret")
                    
                    let p3 = NSPredicate(format: "is_read = %@", "1")
                    let p4 = NSPredicate(format: "chat_count != %@", "0")
                    
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2, NSCompoundPredicate(orPredicateWithSubpredicates: [p3, p4])])

                    let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! [Chat_intiated_details]
                    
                    count = chatintiatedDetailArr.count
                }
                
                if(count > 0)
                {
                    return count
                }
                else
                {
                    return 0
                }
            }
            else
            {
                return 0
            }
        }
        else
        {
            return 0
        }
    }
    func showDeleteView (_ view : UIView ,_ isfromDelete : Bool){
        DispatchQueue.main.async {
            let nibView = Bundle.main.loadNibNamed("DeleteView", owner: self, options: nil)![0] as! DeleteView
            var y:CGFloat = 0.0
            if UIDevice.isIphoneX {
                y = UIScreen.main.bounds.y + UIScreen.main.bounds.height - 150
            }else{
                y = UIScreen.main.bounds.y + UIScreen.main.bounds.height - 110
            }
            nibView.frame = CGRect(x: 20, y: y, width:UIScreen.main.bounds.width - 40 , height: 40)
            nibView.hint_lbl.text = "Deleted for both side"
            if !isfromDelete {
                nibView.hint_lbl.text = "Clear for both side"
            }
            nibView.showTimerProgressViaNIB()
            UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                view.addSubview(nibView)
            }, completion: nil)
            
            DispatchQueue.main.async {
                nibView.layer.cornerRadius = 8
                nibView.clipsToBounds = true
                view.layoutIfNeeded()
            }
            
        }
    }
    func showWaitingNetwork(_ isNetwork:Bool , state:Bool){
        DispatchQueue.main.async {
            AppDelegate.sharedInstance.waitingForNetwork(isNetwork, state: state)
        }
    }
    func getCurrentLocationCountryCode(){
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            self.saveCountryCode(countryCode)
            
        }
    }
    func setCountryCode(_ countryCode : UILabel ,_ WithFlag : UIImageView){
        let CallingCodes = { () -> [[String: String]] in
            let resourceBundle = Bundle(for: MICountryPicker.classForCoder())
            guard let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist") else { return [] }
            return NSArray(contentsOfFile: path) as! [[String: String]]
        }()
        let CtryCode:String = self.getCountryCode()
        let bundle = "assets.bundle/"
        let countryData = CallingCodes.filter { $0["code"] == CtryCode }
        if countryData.count > 0
        {
            print("dialcode",countryData[0])
            let dict = countryData[0]
            countryCode.text = dict["dial_code"]
            WithFlag.image = UIImage(named: "\(bundle)\(CtryCode.uppercased())\(".png")", in:Bundle (for: type(of: self)), compatibleWith: nil)!
        }
        else
        {
            countryCode.text = "+966"
            WithFlag.image = UIImage(named: "\(bundle)\("SA")\(".png")", in:Bundle (for: type(of: self)), compatibleWith: nil)!
        }
    }
    
    func GetuserDetails() -> User_detail?
    {
        
        var ManagedObj = NSManagedObject()
        let USerArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: nil, FetchString: nil, SortDescriptor: nil) as! NSArray
        if(USerArr.count > 0)
        {
            for i in 0..<USerArr.count
            {
                ManagedObj=USerArr[i] as! NSManagedObject
                
            }
        }
        return ManagedObj as? User_detail
    }
}


extension Themes : openLock {
    func openLock(updated: Bool, id: String, type: String) {
        if(updated)
        {
            //self.LockAction(id: id, type: type)
        }
    }
}


extension String {
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    var encoded: Any {
        //        if((self.data(using: String.Encoding.isoLatin1)) != nil)
        //        {
        //            let data : NSData =  self.data(using: String.Encoding.isoLatin1)! as NSData
        //            let str = String(data: data as Data, encoding: String.Encoding.utf8)!
        //            print(str)
        //            return str
        //        }
        return self
    }
    
    var decoded: String {
        //        if(self.data(using: String.Encoding.utf8) != nil)
        //        {
        //            let data : NSData = self.data(using: String.Encoding.utf8)! as NSData
        //            let str = String(data: data as Data, encoding: String.Encoding.isoLatin1)!
        //            print(str)
        //            return str
        //        }
        return self
    }
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(from: Int) -> String {
        return self[min(from, length) ..< length]
    }
    
    func substring(to: Int) -> String {
        return self[0 ..< max(0, to)]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: start, upper: end))
        return String(self[indexRange])
//        return self[start ..< end]
    }
    
    
    
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    var parseNumber: String {
        guard self != "" else { return self }
        do {
            let kit = PhoneNumberKit.shared
            let phoneNumber = try kit.parse(self)
            return kit.format(phoneNumber, toType: .international)
        }
        catch {
            print("Something went wrong....\(error.localizedDescription)")
            return self
        }
    }
    

}

extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        //        textContainer.lineBreakMode = label.lineBreakMode
        //        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
        
    }
    
    
    func didTapAttributedTextInTxtView(TxtView: UITextView, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: TxtView.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        //        textContainer.lineBreakMode = TxtView.li lineBreakMode
        //        textContainer.maximumNumberOfLines = TxtView.numb
        let TxtViewSize = TxtView.bounds.size
        textContainer.size = TxtViewSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInTxtView = self.location(in: TxtView)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (TxtViewSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (TxtViewSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInTxtView.x - textContainerOffset.x, y: locationOfTouchInTxtView.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
        
    }
    
}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

extension Date {
    var ticks: UInt64
    {
        return currentTimeInMiliseconds()
    }
    //Date to milliseconds
    func currentTimeInMiliseconds() -> UInt64 {
        let currentDate = self
        let since1970 = currentDate.timeIntervalSince1970
        return UInt64(since1970 * 1000)
    }
}

extension UINavigationController {
//    func pop(animated: Bool) {
//        AppDelegate.sharedInstance.navigationController?.popViewController(animated: animated)
//    }
//
//    func popToRoot(animated: Bool) {
//        AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: animated)
//    }
    
//    func presentView(_ view : UIViewController, animated: Bool, _ completion : (() -> Void)? = nil) {
//        AppDelegate.sharedInstance.navigationController?.present(view, animated: animated, completion: completion)
//    }
    
//    func dismissView(animated: Bool, completion : (() -> Void)? = nil) {
//        AppDelegate.sharedInstance.navigationController?.dismiss(animated: animated, completion: completion)
//    }
    
//    func pushView(_ view : UIViewController, animated: Bool) {
//        AppDelegate.sharedInstance.navigationController?.pushViewController(view, animated: true)
//    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x:0, y:0, width:self.frame.height, height:thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x:0, y:self.frame.height - thickness, width:UIScreen.main.bounds.width, height:thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x:0, y:0, width:thickness, height:self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x:self.frame.width - thickness, y:0, width:thickness, height:self.frame.height)
            break
        default:
            break
        }
        
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func isPanaroma() -> Bool {
        let smallest = min(self.size.width, self.size.height)
        let largest = max(self.size.width, self.size.height)
        let ratio = largest/smallest
        if (ratio >= CGFloat(2/1)) || (ratio >= CGFloat(4/1)) || (ratio >= CGFloat(10/1)) {
            return true
        } else {
            return false
        }
    }
}

extension UIImageView {
    func setProfilePic(_ id : String, _ type : String) {
        self.image = type == "group" ? #imageLiteral(resourceName: "groupavatar") : #imageLiteral(resourceName: "avatar")
        var profilePic = ""
        if(type == "group"){
            profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: id, returnStr: "displayavatar")
        }
        else {
            if(id == Themes.sharedInstance.Getuser_id()) {
                profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "profilepic")
            }
            else {
                if(Themes.sharedInstance.isShowProfilePic(id)) {
                    profilePic = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "profilepic")
                }
            }

        }
//        self.sd_setImage(with: URL(string: Themes.sharedInstance.CheckNullvalue(Passed_value: profilePic)), placeholderImage: type == "group" ? #imageLiteral(resourceName: "groupavatar") : #imageLiteral(resourceName: "avatar"), options: .refreshCached)
        self.sd_setImage(with: URL(string: Themes.sharedInstance.CheckNullvalue(Passed_value: profilePic)), placeholderImage: type == "group" ? #imageLiteral(resourceName: "groupavatar") : #imageLiteral(resourceName: "avatar"))
    }
}

extension FileManager {
    func clearTmpDirectory() {
    }
}
extension UIViewController {
    func isModal() -> Bool {
        if AppDelegate.sharedInstance.navigationController?.topViewController == self {
            return true
        }
        else if AppDelegate.sharedInstance.navigationController?.presentedViewController == self {
            return true
        }
        else {
            return false
        }
    }
    
    func pop(animated: Bool) {
        AppDelegate.sharedInstance.navigationController?.popViewController(animated: animated)
        AppDelegate.sharedInstance.navigationController?.navigationBar.isHidden = true
    }
    
    func popToRoot(animated: Bool) {
        AppDelegate.sharedInstance.navigationController?.popToRootViewController(animated: animated)
        AppDelegate.sharedInstance.navigationController?.navigationBar.isHidden = true
    }
    
    func presentView(_ view : UIViewController, animated: Bool, completion : (() -> Void)? = nil) {
        if let vc = AppDelegate.sharedInstance.navigationController?.presentedViewController {
            vc.present(view, animated: animated, completion: completion)
        }
        else
        {
            AppDelegate.sharedInstance.navigationController?.topViewController?.present(view, animated: animated, completion: completion)
        }
    }
    
    func dismissView(animated: Bool, completion : (() -> Void)? = nil) {
        AppDelegate.sharedInstance.navigationController?.dismiss(animated: animated, completion: completion)
        AppDelegate.sharedInstance.navigationController?.navigationBar.isHidden = true
    }
    
    func pushView(_ view : UIViewController, animated: Bool) {
        AppDelegate.sharedInstance.navigationController?.pushViewController(view, animated: true)
    }
}

extension UIView {
    
    @objc func dropShadow(scale: Bool = true , shadowOpacity : Float = 0.2 , shadowRadius : CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = .zero
        layer.shadowRadius = shadowRadius
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    @objc func setView(cornerRadius:CGFloat = 0 , Bgcolor:UIColor , titleColor:UIColor) {
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = Bgcolor
        
        if self.isKind(of: UIButton.self){
            (self as! UIButton).setTitleColor(titleColor, for: .normal)
        }else if self.isKind(of: UILabel.self){
            (self as! UILabel).textColor = titleColor
        }
    }
    
    @objc func SetBackButtonShadow(){
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 8
        layer.shouldRasterize = true
        layer.cornerRadius = self.frame.width/2
        self.backgroundColor = PlumberThemeColor
    }
    
    
    func setShadowWithColor(color: UIColor?, opacity: Float?, offset: CGSize?, radius: CGFloat, viewCornerRadius: CGFloat?) {
        //layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: viewCornerRadius ?? 0.0).CGPath
        layer.shadowColor = color?.cgColor
        layer.shadowOpacity = opacity ?? 0.5
        layer.shadowOffset = offset ?? CGSize.zero
        layer.shadowRadius = radius
    }
}

extension UIFont{
    
    @objc class func MyMediumFont(_ fontSize: CGFloat) -> UIFont?
    {
        return UIFont(name: "AvenirNext-Medium", size: fontSize)!
        //        return UIFont.systemFont(ofSize: fontSize)
    }
    
    @objc class func MyboldFont(_ fontSize: CGFloat) -> UIFont?
    {
        return UIFont(name: "AvenirNext-DemiBold", size: fontSize)!
        //        return UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    @objc class func MyitalicFont(_ fontSize: CGFloat) -> UIFont?
    {
        return UIFont(name: "AvenirNext-Italic", size: fontSize)!
        //        return UIFont.italicSystemFont(ofSize: fontSize)
    }
    
    @objc class func MyRegularFont(_ fontSize: CGFloat) -> UIFont?
    {
        return UIFont(name: "AvenirNext-Regular", size: fontSize)!
        //        return UIFont.systemFont(ofSize:fontSize)
    }
    
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(MyMediumFont(_:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }
        
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(MyboldFont(_:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }
        
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(MyitalicFont(_:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
    }
}

extension UILabel {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.font =  UIFont.systemFont(ofSize: (self.font?.pointSize)!)
    }
    
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
    
    func decideTextDirection () {
        let tagScheme = [NSLinguisticTagScheme.language]
        let tagger    = NSLinguisticTagger(tagSchemes: tagScheme, options: 0)
        tagger.string = self.text
        print(self.text ?? "")
        if((self.text?.length)! > 0)
        {
            let lang      = tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language,
                                       tokenRange: nil, sentenceRange: nil)

            if lang?.rawValue.range(of: "he") != nil ||  lang?.rawValue.range(of: "ar") != nil {
                self.textAlignment = .right
            } else {
                self.textAlignment = .left
            }
        }
        else
        {
            self.textAlignment = .left
        }
    }
    
    func setNameTxt(_ id: String, _ type : String) {
        var name = ""
        if(type == "group") {
            name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: id, returnStr: "displayName")

        }
        else{
            if id == Themes.sharedInstance.Getuser_id() {
                name = type == "" ? Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "name") : "You"
            }
            else{
                if(Themes.sharedInstance.contactExist(id)) {
                    let msisdn = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "msisdn")
                    name = Themes.sharedInstance.ReturnFavName(opponentDetailsID: id, msginid: msisdn)
                }
                else
                {
                    name = Themes.sharedInstance.getNameFromGroup(id)
                }
            }
        }
        if(name == "") {
            let param_userDetails:[String:Any]=["userId":id]
            SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
        }
        self.text = name
    }
    
    func setStatusTxt(_ id: String) {
        var status = ""
        if id == Themes.sharedInstance.Getuser_id() {
            status = Themes.sharedInstance.base64ToString(Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "status"))
        }
        else {
            if(Themes.sharedInstance.contactExist(id)) {
                if(Themes.sharedInstance.isShowStatusLbl(id)) {
                    status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "status")
                    status = Themes.sharedInstance.base64ToString(status)
                }
            }
            else
            {
                status = Themes.sharedInstance.base64ToString(Themes.sharedInstance.getStatusFromGroup(id))
            }
        }
        self.text = status
    }
    
    func setPhoneTxt(_ id: String) {
        var msisdn = ""
        if id == Themes.sharedInstance.Getuser_id() {
            msisdn = Themes.sharedInstance.base64ToString(Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: id, returnStr: "mobilenumber")).parseNumber
        }
        else {
            if(Themes.sharedInstance.contactExist(id)) {
                msisdn = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: id, returnStr: "formatted")
            }
            else {
                msisdn = Themes.sharedInstance.getPhoneFromGroup(id)
            }
        }
        self.text = msisdn
    }
}

extension UIButton
{
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.font =  UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!)
    }
}

extension UITextField {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.font =  UIFont.systemFont(ofSize: (self.font?.pointSize)!)
        self.tintColor = CustomColor.sharedInstance.themeColor
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIBarButtonItem {
    override open func awakeFromNib() {
        self.tintColor = CustomColor.sharedInstance.themeColor
    }
}

extension UINavigationBar {
    override open func awakeFromNib() {
        self.tintColor = CustomColor.sharedInstance.themeColor
        self.backgroundColor = .white
    }
}


extension UIToolbar {
    override open func awakeFromNib() {
        self.tintColor = CustomColor.sharedInstance.themeColor
    }
}

extension UITabBar {
    override open func awakeFromNib() {
        self.tintColor = CustomColor.sharedInstance.themeColor
    }
}

extension UITextView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.font =  UIFont.systemFont(ofSize: (self.font?.pointSize)!)
        self.tintColor = CustomColor.sharedInstance.themeColor
    }
    
    func hyperLink(originalText: String, hyperLink: String, urlString: String) {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
        self.attributedText = attributedOriginalText
    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}


struct Platform {
    static let isSimulator: Bool = {
        #if arch(i386) || arch(x86_64)
        return true
        #else
        return false
        #endif
    }()
}

struct Signing {
    static let Development: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
}

extension UIDevice {
    static var isIphoneX: Bool {
        
        var returnVal = Bool()
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            print("iPhone 5 or 5S or 5C")
            returnVal = false
            break
        case 1334:
            print("iPhone 6/6S/7/8")
            returnVal = false
            break
        case 1920, 2208:
            print("iPhone 6+/6S+/7+/8+")
            returnVal = false
            break
        case 2436:
            print("iPhone X, XS")
            returnVal = true
            break
        case 2688:
            print("iPhone XS Max")
            returnVal = true
            break
        case 1792:
            print("iPhone XR")
            returnVal = true
            break
        default:
            returnVal = false
            break
        }
        return returnVal
    }
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

extension UISearchBar {
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.barTintColor = UIColor.clear
        self.backgroundImage = UIImage()
    }
}
