//
//  ConnectionTimer.swift
//  ChatApp
//
//  Created by Casp iOS on 09/01/17.
//  Copyright © 2017 Casp iOS. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import CoreMedia

class Themes: NSObject {
    static let sharedInstance = Themes()
    let screenSize:CGRect = UIScreen.main.bounds
    var spinner:UIView=UIView()
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
        dateFormatters.dateFormat = "hh:mm a"
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
        dateFormatters.dateFormat = "hh:mm a"
        dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatters.timeZone = NSTimeZone.system
        let dateStr:String = dateFormatters.string(from: date as Date)
        return dateStr
    }
    
    func getTimeStamp() -> String {
        return String(Date().ticks)
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
    
    func showprogressAlert(controller : UIViewController)
    {
        progressAlert = UIAlertController(title: "Preparing", message: " ", preferredStyle: .alert)
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.setProgress(0.0, animated: true)
        progressBar.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
        progressAlert.view.addSubview(progressBar)
        controller.present(progressAlert, animated: true, completion: nil)
    }
    
    func setprogressinAlert(controller : UIViewController, progress : Float, completionHandler: (() -> Swift.Void)? = nil)
    {
        self.progressBar.setProgress(progress, animated: true)
        
        if(progress == 1.0)
        {
            if(completionHandler != nil)
            {
                controller.dismiss(animated: true) {
                    if(completionHandler != nil)
                    {
                        completionHandler!()
                    }
                }
            }
            else
            {
                controller.dismiss(animated: true, completion: nil)
            }
        }
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
        var phone_number:NSString=""
        let user_Arr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil, SortDescriptor: nil) as! NSArray
        
        if(user_Arr.count > 0)
        {
            
            for i in 0..<user_Arr.count
            {
                let ManagedObj=user_Arr[i] as! NSManagedObject
                phone_number = self.CheckNullvalue(Passed_value:ManagedObj.value(forKey: "mobilenumber"))  as NSString;
                
            }
        }
        
        
        return phone_number as String
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
    
    func GetuserDetails()->NSManagedObject
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
        return ManagedObj
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
        
        return self.CheckNullvalue(Passed_value: monthParam[monthInInt])
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
        let lockedArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: id, SortDescriptor: nil) as! [NSManagedObject]
        if(lockedArr.count > 0)
        {
            return true
        }
        else
        {
            return false
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
            url = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.baseURL)
        }
        return url
    }
    
    func getURL() -> String {
        return Signing.Development ? getBaseURL() : BaseURLArray[0]
    }
    
    func changeURL() {
        let url = getBaseURL()
        let setURL = BaseURLArray[((BaseURLArray as NSArray).index(of: url) + 1 > BaseURLArray.count - 1) ? 0 : (BaseURLArray as NSArray).index(of: url) + 1]
        print(setURL)
        DatabaseHandler.sharedInstance.UpdateData(Entityname: "BaseURL", FetchString: url, attribute: "baseURL", UpdationElements: ["baseURL" : setURL])
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
                    
                    dateFormatStr = NSLocalizedString("Today", comment: "Today")
                }
                else
                {
                    dateFormatStr = NSLocalizedString("Yesterday", comment: "Yesterday")
                    
                }
            }
                
            else if(Calendar.current.isDateInYesterday(fromdate))
            {
                dateFormatStr = NSLocalizedString("Yesterday", comment: "Yesterday")
            }
            else if(numberOfDays < 4)
            {
                
                dateFormatters.dateFormat = "EEE"
                dateFormatStr = dateFormatters.string(from: fromdate)
                
            }
            else if(numberOfDays > 365)
            {
                dateFormatters.dateFormat = "MMM d, yyyy"
                dateFormatStr = dateFormatters.string(from: fromdate)
            }
            else{
                dateFormatters.dateFormat = "MMM d, yyyy"
                dateFormatStr = dateFormatters.string(from: fromdate)
            }
        }
        
        return dateFormatStr
        
    }
    
    func isIminPrivacyContactList(_ id: String) -> Bool {
        let contacts = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: id, SortDescriptor: nil) as! [Favourite_Contact]
        var isMe = false
        _ = contacts.map {
            if let contactUserList = $0.contactUserList, let arr = contactUserList as? NSArray, arr.contains(Themes.sharedInstance.Getuser_id()) {
                isMe = true
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
                txt = NSLocalizedString("last seen", comment:"last seen") + " " + DayStr + NSLocalizedString("at", comment:"at") + TimeStr
            }
        }
        if(is_online != "") {
            txt = is_online == "1" && !isImBlocked(id) ? NSLocalizedString("Online", comment:"Online")  : txt
        }
        
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
        
//        if(name == "") {
//            let param_userDetails:[String:Any]=["userId":id]
//            SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
//        }
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
        return self.count
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
        return self[start.hashValue ..< end.hashValue]
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
    func pop(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool) {
        _ = self.popToRootViewController(animated: animated)
    }
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
}
extension FileManager {
    func clearTmpDirectory() {
        //        do {
        //            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
        //            try tmpDirectory.forEach {[unowned self] file in
        //                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
        //                try self.removeItem(atPath: path)
        //            }
        //        } catch {
        //            print(error)
        //        }
    }
}

extension UIView {
    
    func dropShadow() {
        
        //        self.layer.masksToBounds = false
        //        self.layer.shadowColor = UIColor.darkGray.cgColor
        //        self.layer.shadowOpacity = 0.5
        //        self.layer.shadowOffset = CGSize(width: 1, height: -1)
        //        self.layer.shadowRadius = 1
        //
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        //        self.layer.shouldRasterize = true
        //
        //        self.layer.rasterizationScale = UIScreen.main.scale
        
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
//        if(name == "") {
//            let param_userDetails:[String:Any]=["userId":id]
//            SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
//        }
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
        if(self.currentImage != nil)
        {
            if(self.currentImage == #imageLiteral(resourceName: "goarr_white"))
            {
//                let dir = LanguageHandler().getlanguageDirection()
//                if  dir == .rightToLeft {
//                    self.setImage(#imageLiteral(resourceName: "goarrrev"), for: .normal)
//                }
            }
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
        self.sd_setImage(with: URL(string: Themes.sharedInstance.CheckNullvalue(Passed_value: profilePic)), placeholderImage: type == "group" ? #imageLiteral(resourceName: "groupavatar") : #imageLiteral(resourceName: "avatar"), options: .refreshCached)
    }
}

extension UITextField {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.font =  UIFont.systemFont(ofSize: (self.font?.pointSize)!)
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

extension UITextView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.font =  UIFont.systemFont(ofSize: (self.font?.pointSize)!)
    }
    
    func hyperLink(originalText: String, hyperLink: String, urlString: String) {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
        self.attributedText = attributedOriginalText
    }
}


struct Platform {
    static let isSimulator: Bool = {
        #if arch(i386) || arch(x86_64)
        return true
        #endif
        return false
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
