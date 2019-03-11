//
//  SubscribeManager.swift
//  iShadowsocksR
//
//  Created by Alex Jin on 2019/3/11.
//  Copyright © 2019 ssrLive. All rights reserved.
//

import Foundation
import Async

open class SubscribeManager {
    
    static let shared = SubscribeManager()
    
    static let subscribeUrlKey = "subscpublicUrl"
    public static let subscriptionSettingsUpdatedNotification = "subscriptionSettingsUpdatedNotification"
    
    
    init(){}
    
    var subscribeUrl: String{
        get {
            if let config = UserDefaults.standard.object(forKey: SubscribeManager.subscribeUrlKey) as? String {
                return config
            }
            return ""
        }
        set(new) {
            guard subscribeUrl != new else {
                return
            }
            //            getCurrentSyncService()?.stop()
            UserDefaults.standard.set(new, forKey:SubscribeManager.subscribeUrlKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: SubscribeManager.subscriptionSettingsUpdatedNotification), object: nil)
        }
    }
    
//    func update(completion: ((_ error: String)->Void)?){
//
//
////        let content = String(contentsOf: URL?(string:subscribeUrl))
////
////        completion?(true)
//    }
    
    func update() -> String?{
//        guard let url = URL(string: self.subscribeUrl) else {
//            return "Invalid URL"
//        }
//        guard let content = String(contentsOf: url) else {
//            return ""
//        }
        return nil
    }
    
}
