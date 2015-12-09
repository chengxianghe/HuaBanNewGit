//
//  RecommendRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/5.
//  Copyright © 2015年 CXH. All rights reserved.
//

// 推荐的
//http://api.huaban.com/pins/511217211/recommend?page=1
import UIKit
// Pin推荐的
/// http://api.huaban.com/pins/511217211/recommend?page=1
// 画板推荐的
/// http://api.huaban.com/boards/12222662/pins/?limit=20

class RecommendRequest: BaseRequest {
    var page: Int = 1
    var pinId: NSNumber!
    var pinArray: [Pin]?
    var promotions = false
    
    override func requestMethod() -> BaseRequestMethod {
        return .Get
    }
    
    override func requestUrl() -> String? {
        return baseUrl + "/pins/" + pinId.stringValue + "/recommend?page=\(page)"
    }
    
    override func handleResult() {
        var result: NSArray!
        
        if self.isDataFromCache() {
            result = self.cacheJson as! NSArray
        } else {
            result = self.responseJSONObject as! NSArray
        }
        
        pinArray = result.map { Pin().mj_setKeyValues($0) }
    }
    
}
