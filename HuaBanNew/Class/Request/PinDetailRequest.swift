//
//  PinDetailRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/5.
//  Copyright © 2015年 CXH. All rights reserved.
//

//http

//http://api.huaban.com/pins/514478057/
//http ://huaban.com/pins/148243409/
import UIKit

class PinDetailRequest: BaseRequest {
    var page: Int = 1
    var pinId: NSNumber!
    var resultPin: PinDetail?
    var promotions = false
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        //api.huaban.com/pins/514478057/
        return baseUrl + "/pins/" + pinId.stringValue
    }
    
    override func handleResult() {
        var result: NSDictionary?
        
        if self.isDataFromCache() {
            result = self.cacheJson["pin"] as? NSDictionary
        } else {
            result = self.responseJSONObject["pin"] as? NSDictionary
        }
        
        if result != nil {
            
            
            if let ret = result!["promotions"] as? Bool {
                promotions = ret
            }
            
            resultPin = PinDetail().mj_setKeyValues(result!)
        }
    }
    
}

// 推荐的
///http://api.huaban.com/pins/511217211/recommend?page=1
class PinRecommendRequest: BaseRequest {
    var page: Int = 1
    var pinId: NSNumber!
    var pinArray: [Pin]?
    var promotions = false
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        return baseUrl + "/pins/" + pinId.stringValue + "/recommend?page=\(page)"
    }
    
    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson as? NSArray
        } else {
            result = self.responseJSONObject as? NSArray
        }
        if result != nil {
            pinArray = result!.map { Pin().mj_setKeyValues($0) }
            for (_,element) in pinArray!.enumerate() {
                element.needUser = true
            }
        }
        
    }
    
}
