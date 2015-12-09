//
//  Test.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/7.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class Test: BaseRequest {

    var page: Int = 1
    var pins: [Pin]?
    var max: NSNumber?
    var category: CategoryModel!
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Post
    }
    
    override func requestUrl() -> String? {
        return "https://api.huaban.com/oauth/access_token?"
    }
    
    //http://api.huaban.com/all/?iha4xyua&max=531633117&limit=20&wfl=1
    override func requestParameters() -> [String : String]? {
        var dict = ["username" : "1052252110@qq.com"]
        //        dict["limit"] = "20"
        //        dict["wfl"] = "1"
            dict["password"] = "cheng613637"
        dict["grant_type"] = "password"
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

    //https://api.huaban.com/oauth/access_token?grant_type=password&username=1052252110@qq.com&password=cheng613637

    /*    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
