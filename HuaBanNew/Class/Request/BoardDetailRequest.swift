//
//  BoardDetailRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/7.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

// 查看画板
// http://api.huaban.com/boards/12222662
//画板推荐
/// http://api.huaban.com/boards/12222662/pins/?limit=20
class BoardDetailRequest: BaseRequest {
    var page: Int = 1
    var boardId: NSNumber = 12222662
    var resultBoard: Board?
    var promotions = false
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        /// http://api.huaban.com/boards/12222662
        return baseUrl + "/boards/" + boardId.stringValue
    }
    
    override func handleResult() {
        var result: NSDictionary!
        
        if self.isDataFromCache() {
            result = self.cacheJson["board"] as! NSDictionary
        } else {
            result = self.responseJSONObject["board"] as! NSDictionary
        }
    
        resultBoard = Board().mj_setKeyValues(result)
    }

}
//
class BoardRecommendRequest: BaseRequest {
    var page: Int = 1
    var max: String?
    var boardId: NSNumber = 12222662
    var pinArray: [Pin]?
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        /// http://api.huaban.com/boards/12222662/pins/?limit=20
        /// http://api.huaban.com/pins/529446904/recommend/?ihjugw5n&page=4&per_page=10&wfl=1
        return baseUrl + "/boards/" + boardId.stringValue + "/pins"
    }
    
    override func requestParameters() -> [String : String]? {
        
        //?limit=\(page * 20) //&max=515467442
        var dict = ["limit": "20"]
        if max != nil {
            dict["max"] = max!
        }
        return dict
    }
    
    override func handleResult() {
        var result: NSArray!
        
        if self.isDataFromCache() {
            result = self.cacheJson["pins"] as! NSArray
        } else {
            result = self.responseJSONObject["pins"] as! NSArray
        }
        
        pinArray = result.map { Pin().mj_setKeyValues($0) }
    }

}
