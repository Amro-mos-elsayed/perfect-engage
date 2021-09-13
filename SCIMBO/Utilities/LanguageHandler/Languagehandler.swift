//
//  Languagehandler.swift
//  Plumbal
//
//  Created by Casperon Tech on 10/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
let Language_Notification:NSString="VJLanguageDidChage"

class Languagehandler {
    var LocalisedString:Bundle=Bundle()
    
    
    
    let EnglishGBLanguageShortName:NSString="en-GB"
    let EnglishUSLanguageShortName:NSString="en"
    let FrenchLanguageShortName:NSString="fr"
    let SpanishLanguageShortName:NSString="es"
    let ItalianLanguageShortName:NSString="it"
    let TamilLanguageShortName : NSString = "ta"

    let JapaneseLanguageShortName:NSString="ja"

    let KoreanLanguageShortName:NSString="ko"
    let ChineseLanguageShortName:NSString="zh"
    
    let TurkishLanguageShortName:NSString="tr"
    
    let EnglishGBLanguageLongName:NSString="English(UK)"
    let EnglishUSLanguageLongName:NSString="English(US"
    let FrenchLanguageLongName:NSString="French"
    let SpanishLanguageLongName:NSString="Spanish"
    let ItalianLanguageLongName:NSString="Italian"

    let JapaneseLanguageLongName:NSString="Japenese"
    let KoreanLanguageLongName:NSString="한국어"
    let TamilLanguageLongName : NSString = "Tamil"

    let ChineseLanguageLongName:NSString="中国的"
    let TurkishLanguageLongName:NSString="Turkish"


    var  _languagesLong:NSArray!=NSArray()

     var _localizedBundle:Bundle!=Bundle()
    func localizedBundle()->Bundle
    {
        if(_localizedBundle == nil)
        {
        _localizedBundle=Bundle(path: Bundle.main.path(forResource: "\(ApplicationLanguage())", ofType: "lproj")!)!
        }
        return _localizedBundle

    }
    
    func ApplicationLanguage()->String
    {
         let languages:NSArray=UserDefaults.standard.object(forKey: "AppleLanguages") as! NSArray
        return languages.object(at: 0) as! String

    }
    
    
    func setApplicationLanguage(language:NSString){
 
//    let oldLanguage: NSString = ApplicationLanguage() as NSString
//        
//        print("\(oldLanguage)....\(ApplicationLanguage())")
////    if (oldLanguage.isEqualToString(language as String) == false)
////    {
//    UserDefaults.standard.set([language], forKey: "AppleLanguages")
//    UserDefaults.standard.synchronize()
//    _localizedBundle=Bundle(path: Bundle.main.path(forResource: "ar", ofType: "lproj")!)!
//    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Language_Notification as String as String), object: nil)

//    }
    }
    
  func applicationLanguagesLong()->NSArray
  {
    if _languagesLong == nil {
   _languagesLong = [ChineseLanguageLongName, EnglishGBLanguageLongName, EnglishUSLanguageLongName, FrenchLanguageLongName, KoreanLanguageLongName, ItalianLanguageLongName, SpanishLanguageLongName, TurkishLanguageLongName]
    }
    return _languagesLong
    }

    
    func VJLocalizedString(key:String!,comment:String!)->String
{
    
    print("\(localizedBundle())")
    return  localizedBundle().localizedString(forKey: key, value: "", table: nil)
    }
    
    func shortLanguageToLong(shortLanguage:NSString)->NSString
    {
        
        if(shortLanguage.isEqual(to: EnglishGBLanguageLongName as String))
        {
            return EnglishGBLanguageLongName;

        }
        if(shortLanguage.isEqual(to: EnglishUSLanguageShortName as String))
        {
            return EnglishUSLanguageShortName;
            
        }

        if(shortLanguage.isEqual(to: EnglishGBLanguageShortName as String))
        {
            return EnglishGBLanguageLongName;
            
        }

        if(shortLanguage.isEqual(to: ChineseLanguageShortName as String))
        {
            return ChineseLanguageShortName;
            
        }

        if(shortLanguage.isEqual(to: FrenchLanguageShortName as String))
        {
            return FrenchLanguageShortName;
            
        }

        if(shortLanguage.isEqual(to: KoreanLanguageShortName as String))
        {
            return KoreanLanguageShortName;
            
        }

        if(shortLanguage.isEqual(to: ItalianLanguageShortName as String))
        {
            return ItalianLanguageShortName;
            
        }

        if(shortLanguage.isEqual(to: SpanishLanguageShortName as String))
        {
            return SpanishLanguageShortName;
            
        }
        if(shortLanguage.isEqual(to: TamilLanguageLongName as String))
        {
            return TamilLanguageLongName;
            
        }

        else
        {
            
            return ""
            
        }

        
    }
    
    

}
