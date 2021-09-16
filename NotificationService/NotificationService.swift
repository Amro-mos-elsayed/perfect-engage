//
//  NotificationService.swift
//  NotificationService
//
//  Created by Ahmed Labeeb on 9/14/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let defaults = UserDefaults(suiteName: "group.com.2p.Engage")
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as! UNMutableNotificationContent)
        var count: Int = defaults?.value(forKey: "BadgeCount") as! Int
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.badge = count as NSNumber
            count = count + 1
            defaults?.set(count, forKey: "BadgeCount")
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
     
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
