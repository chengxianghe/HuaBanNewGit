//
//  DiscoverRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/5.
//  Copyright © 2015年 CXH. All rights reserved.
//

// 发现 ESRootClass
//http://api.huaban.com/discovery/
import UIKit

class DiscoverRequest: BaseRequest {

    var page: Int = 1
    var pins: [Pin]?
    var max: NSNumber?
    var category: CategoryModel!
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        return baseUrl + category.nav_link!
    }
    
    //http://api.huaban.com/all/?iha4xyua&max=531633117&limit=20&wfl=1
    override func requestParameters() -> [String : String]? {
        var dict = ["limit" : "20"]
//        dict["limit"] = "20"
//        dict["wfl"] = "1"
        if max != nil {
            dict["max"] = "\(max!.integerValue)"
        }
        return dict
    }
    
    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson["pins"] as? NSArray
        } else {
            result = self.responseJSONObject["pins"] as? NSArray
        }
        
        if let arr = result {
            pins = arr.map { Pin().mj_setKeyValues($0) }
        }
        
//        recommends = (result["recommends"]  as! NSArray).map { Recommends(keyValues: $0) }
//        banners    = (result["banners"]     as! NSArray).map { Banners(keyValues: $0) }
//        hot_words  = (result["hot_words"]   as! NSArray).map { Hot_Words(keyValues: $0) }
//        explores   = (result["explores"]    as! NSArray).map { Explores(keyValues: $0) }
    }

    
}