//
//  TermAndConditionViewController.swift
//
//
//  Created by PremMac on 06/11/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
protocol tick : class {
    func tnc(agree:Bool)
}
class TermAndConditionViewController: UIViewController {
    
    weak var delegate:tick!
    @IBOutlet weak var tnc_text: UITextView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        let string:NSString = "\(Themes.sharedInstance.GetAppname()) Legal Information\n\nBasic Updates\n\nFor us, your privacy is the priority and we have that embedded into our blood, which is how we work for you. Right from the moment, we have created \(Themes.sharedInstance.GetAppname()) we made sure that our privacy terms and conditions are strong enough. We have recently updated it for you, here they are:\n\nUnderstandable terms and conditions\n\nThe terms and conditions which we have updated are understandable to any person who has come across this particular app. With the new update, there a few new features which we have introduced in the app like \(Themes.sharedInstance.GetAppname()) Web.\n\nSecurity Features\n\nWhatever message you send and receive from your friends and family is always yours; there is no access for us to fetch the details of the messages which you have exchanged. Your privacy is our priority, that is why we have secured all your messages and they belong one and only to you but no one else, so you do not need to worry about your privacy.\n\nFree of Advertisements\n\nIn general, you would have come across applications which have advertisements flashing now and then very often and it is an annoying factor. We have taken this aspect into our account and have designed the app free from any kind of advertisements.\n\nAbout our Services\n\nRegistration\n\nIn order to enroll with our services it is essential for you to give us authentic information, and for that purpose you need to provide your personal contact information. In case of any changes in your contact number on \(Themes.sharedInstance.GetAppname()), you can update the number with the change number option on the app. From our third-party providers, you can receive the text messages and phone calls. With the aid of the codes, you can register to use our services in an efficient manner.\n\nAddress Book\n\nIt is not only your contact information which you would be sharing with us. If there are any of your friends or family members who are using our service then by default the contact numbers will be added to contact list of the app from the phone book of your device.\n\nAge Limit\n\nThe minimum age requirement to use our services is a minimum of 13 year old. In case of violating the age bar limit for the user, there will be no problem in that particular aspect. It is better that, the person has the guidance of their parents or guardian to watch over when they are using the app in their presence.\n\nDevices and Software\n\nIn order to use our service, you need to have specific devices along with the required software and the operating system. Only if you possess the requirements you will be able to use our chat application on your device. Once you have downloaded and installed our app on your device by default it will have an update available whenever the updated version of the app is available.\n\nFees and Taxes\n\nYou will be able to use the application only if there is an internet connection available as the app works based on the network connection. You are responsible for the payments and taxes which you pay for your network service provider for using our services. Apart from that, there are possibilities where we will be charging you along with the taxes for our services specifically. There will be no refunds done for the payments which you have done towards our services.\n\nPrivacy Policy and User Data\n\nYou are accepting to the privacy policy as you will be sharing the information which you send and receive messages. Under the policy, we have also mentioned about the ways in which the information will be collected and transferred to other devices. This information sharing is done regardless of the location from where you are using our service along with the facilities and network service providers. You need to agree to all the rules and regulations which are practiced in the respective countries across the world.\n\nDetails we collect\n\nWe need certain information for us to activate your account on the app so you can use it. These will include the information in regards to the installation of the app, access to the app and the services which we provide.\n\nDetails you provide\n\nYou’re Account Information\n\nMobile number is a requirement for you to create an account on the \(Themes.sharedInstance.GetAppname()) app. Once you have created the account by default you will be sharing the contact information of the people who use our service. In order to use the app, there is a verification code sent to your message inbox on your device only after the verification you will be able to use the service. Apart from this, you have an option to update your username, profile picture, and the status as well.\n\nYou’re Message\n\nWhile we are offering you our service we do not read any of your messages (including your share location information, chats, voice, video messages, photos, and files). The messages you’ve sent is deleted from our server the moment when it is delivered to the recipient. The messages that you send are only stored on your mobile device. In case if the messages that you have sent is not delivered to the intended recipient, we keep it on our server for 30 days and try to deliver the message and after 30 days the message will be deleted from our server as well. We might retain a content on our server for a long time only when we deliver media messages.\n\nYou’re Connection\n\nTo efficiently communicate with others, we may create a special favorites list of the contacts, so you can either join, broadcast lists and even get added to various groups. And the lists and groups are associated with the account information.\n\nCustomer Support\n\nWe can provide you customer support regarding the use of our service, so you can send us the information on how to contact you, even include copies of your text messages. For example, you can mail us regarding our app performance or any other concern.\n\nAutomatically Collected Information\n\nUsage and Log Information\n\nWe collect information pertaining to the service, performance and diagnostic and it includes information about your activity (like how you communicate with others using our app service and how you access our service), websites, crash, log files, performance logs, diagnostic and reports.\n\nDevice and Connection information\n\nWe collect information relating to the device when you install, use or access our services. And the information we collect is related to the operating system, the hardware model, IP address, browser, mobile network details including the device identifier and mobile phone number. We also collect device location information, if you use the location feature from our service, like when you view the locations which has been shared, and when you wish to share your location with your contacts, for troubleshooting or diagnostics when you encounter issues with our app location.\n\nCookies\n\nWe use cookies to provide and operate our service including the web-based services, customize the service, enhance your experience and understanding of how our service is being used. For instance, we use the cookies to offer our service for the web-based, web and desktop service. We also use it to understand which of the FAQs from our service is popular and provide relevant content to our service. We even use the cookies to recall your preferences in language and to customize the service to your wish.\n\nStatus information\n\nWe gather information about your status message, online presence on our service like the recent status updates, the online status, and when you have last accessed our service.\n\nThird-party Information\n\nYour friends or family members who use our services may provide your contact number from their contact list instantly available on their mobile phones. They can also send you a message, and send messages to the groups to which you belong. At the same time, you can also provide their information.\n\nThird-Party Providers\n\nWe work with the several third party providers in order to disseminate our applications, provide a complete infrastructure, delivery, and market our services. The app store and play store helps us to analyze and fix the service issues by producing a list of statements.\n\nThird-party Services\n\nYou can also communicate with the third party with the help of our services. With the aid of the Share option, you can share a review which can be broadcasted to the contacts or groups. When you use the third-party services, their terms and conditions will take control of your use of that concerned services.\n\nInformation You and We Share\n\nAccount Information\n\nThe account information which includes a phone number, profile name, and photo, online status, last seen status and status message are visible to anyone who uses our services or the user can customize it according to their wish, with whom they would like to share their information. It can be made visible to everyone, just your contacts on no one apart from yourself.\n\nYour contact and others\n\nYour friends or family members with whom you interact may store, reshare the data like contact number or messages with third-parties. The settings of our service provide you with a block feature which will help you to avoid unknown people and keep them at bay and make your chat experience as a good one.\n\nThird-Party Providers\n\nOnce the data is shared with the third-party providers, we instruct them not to use the information provided to them in any misleading ways. It is important for them to keep it safe and secure without any breach in it.\n\nThird-Party Services\n\nWhen we share information with the third parties by default we will be sharing the information of the user. If the user wants to create a backup of the chat they will be able to use the third-party service such as Google or iCloud. This means that you are sharing your information with the third-party by direct means. You need to note that the service from the third party will have its own privacy policies and terms and conditions. The user is liable to any kind of information which has been shared out of the chat app.\n\nUpdates to Our Policy\n\nWe are bound to revise or update our Privacy Policy and we will provide you with the notice of the revision of the policies and update the last modified date as well. When you access the service after the amendment of the Privacy Policy, we will confirm your acceptance of the policy update. If you deny the revised Privacy Policy you must stop using our service. Frequently review our Privacy Policy." as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14.0)])
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:15.0)]
        let bold_String:NSMutableArray = ["\(Themes.sharedInstance.GetAppname()) Legal Information","Basic Updates","Understandable terms and conditions","Security Features","Free of Advertisements","About our Services","Registration","Address Book","Age Limit","Devices and Software","Fees and Taxes","Privacy Policy and User Data","Details we collect","Details you provide","You’re Account Information","You’re Message","You’re Connection","Customer Support","Automatically Collected Information","Usage and Log Information","Device and Connection information","Cookies","Status information","Third-party Information","Third-Party Providers","Third-party Services","Information You and We Share","Account Information","Your contact and others","Third-Party Providers","Third-Party Services","Updates to Our Policy"]
        
        for i in 0..<bold_String.count {
            attributedString.addAttributes(boldFontAttribute, range: string.range(of: bold_String[i] as! String))
        }
        
        tnc_text.attributedText = attributedString
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tnc_text.setContentOffset(.zero, animated: true)
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func disagree(_ sender: UIButton) {
        self.delegate.tnc(agree: false)
        self.pop(animated: true)
    }
    
    @IBAction func agree(_ sender: UIButton) {
        self.delegate.tnc(agree: true)
        self.pop(animated: true)
    }
    @IBAction func back(_ sender: UIButton) {
        self.pop(animated: true)
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

