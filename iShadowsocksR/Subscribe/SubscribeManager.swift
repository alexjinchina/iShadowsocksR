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
    
    var updatingLock: NSLock = NSLock();
    var updatingTask: URLSessionDataTask? = nil;
    
    //    func update(completion: ((_ error: String)->Void)?){
    //
    //
    ////        let content = String(contentsOf: URL?(string:subscribeUrl))
    ////
    ////        completion?(true)
    //    }
    
    func update(completionHandler: ((_ error:String?)->Void)?){
        DDLogDebug("Subscribe: update")
        self.updatingLock.lock();
        defer {
            DDLogDebug("Subscribe: update unlock")
            self.updatingLock.unlock()
            DDLogDebug("Subscribe: update unlock ok")
        }
        if self.updatingTask != nil{
            completionHandler?("Updating")
            return;
        }
        
        guard let url = URL(string: self.subscribeUrl) else {
            completionHandler?( "Invalid URL!");
            return
        }
        
        let request = URLRequest(url:url)
        let session = URLSession.shared
        self.updatingTask = session.dataTask(
            with: request,
            completionHandler: {(data, response, error) -> Void in
                DDLogDebug("Subscribe.updateTaskCompleted: update task completed")
                DispatchQueue.main.async {
                    //                if true{
                    //                    DDLogDebug("Subscribe.updateTaskCompleted: update lock")
                    //                    self.updatingLock.lock()
                    //                    defer {
                    //                        self.updatingTask = nil
                    //                        DDLogDebug("Subscribe.updateTaskCompleted: update unlock")
                    //                        self.updatingLock.unlock()
                    //                        DDLogDebug("Subscribe.updateTaskCompleted: update unlock ok")
                    //                    }
                    defer {
                        DDLogDebug("Subscribe.updateTaskCompleted: update lock")
                        self.updatingLock.lock()
                        self.updatingTask = nil
                        DDLogDebug("Subscribe.updateTaskCompleted: update unlock")
                        self.updatingLock.unlock()
                        DDLogDebug("Subscribe.updateTaskCompleted: update unlock ok")
                    }
                    if error != nil {
                        completionHandler?(error.debugDescription)
                        return
                    }
                    
                    if data == nil {
                        completionHandler?("nil data!")
                        return
                    }
                    
                    guard let dataString = String(data: data!, encoding: String.Encoding.utf8) else{
                        completionHandler?("Invalid data encoding!")
                        return
                    }
                    
                    if !self.parseData(data: dataString){
                        completionHandler?("Parse data error!")
                        return
                    }
                    
                    completionHandler?(nil);
                }
        })
        
        DDLogDebug("Subscribe: update task resume")
        self.updatingTask?.resume()
    }
    
    private static func updateProxy(proxy: Proxy) throws{
        do {
            try proxy.validate(inRealm: defaultRealm)
            
            var updated = false
            for p in DBUtils.allNotDeleted(Proxy.self){
                if (proxy.group.isEmpty || (p.group == proxy.group)) && p.name == proxy.name {
                    updated = true
                    let upstream = Proxy(value: proxy)
                    upstream.uuid = p.uuid
                    try DBUtils.add(upstream)
                }
            }
            if !updated {
                try DBUtils.add(proxy)
            }
        }catch{
            DDLogError("update proxy item:\(proxy) failed(\(error))!")
            throw error
        }
    }
    
    private func parseDecodedData(data: String) ->Bool{
        
        self.updatingLock.lock()
        defer {
            self.updatingLock.unlock()
        }
        
        if Proxy.uriIsShadowsocks(data){
            do{
                let uris = data.components(separatedBy: CharacterSet(charactersIn: "\r\n")).filter { (uri) -> Bool in
                    return !uri.isEmpty
                }
                let proxies: [Proxy] = try uris.map { (uri) in
                    do {
                        let proxy = try Proxy(
                            dictionary: [
                                "name": "" as AnyObject,
                                "uri": uri as AnyObject],
                            inRealm: defaultRealm)
                        try proxy.validate(inRealm: defaultRealm)
                        return proxy
                    }catch{
                        DDLogError("subscribe proxy item:\(uri) failed(\(error))!")
                        throw error
                    }
                }
                try proxies.forEach{(proxy) in
                    try SubscribeManager.updateProxy(proxy: proxy)
                }
                return true
            }catch{
                DDLogError("import subscribe ssr failed!")
                return false
            }
            
        }
        
        return false;
    }
    
    private func parseData(data: String)-> Bool{
        if self.parseDecodedData(data: data){
            return true
        }
        
        
        if let data = Data(base64Encoded:
            data.padding(toLength: ((data.count+3)/4)*4,withPad: "=",startingAt: 0)){
            guard let str = String(data:data, encoding: String.Encoding.utf8) else {
                return false
            }
            if self.parseDecodedData(data: str){
                return true
            }
        }
        
        return false;
    }
}
