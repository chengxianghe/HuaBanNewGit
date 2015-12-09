//
//  PopularRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/15.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

//http://huaban.com/popular/
class PopularPinRequest: BaseRequest {
    var page: Int = 1
    var pins: [Pin]?
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // TODO
        // http://huaban.com/mobile_topics/75/posts? 个人关注的采集 这里暂用热门采集代替
        return baseUrl + AppURL.PopularType.pin.rawValue + "?page=\(page)"
    }
    
    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson["pins"] as? NSArray
        } else {
            result = self.responseJSONObject["pins"] as? NSArray
        }
        
        if let arr = result {
            pins = arr.map({ Pin().mj_setKeyValues($0) })
            for (_,element) in pins!.enumerate() {
                element.needUser = true
            }
        }
    }

}
