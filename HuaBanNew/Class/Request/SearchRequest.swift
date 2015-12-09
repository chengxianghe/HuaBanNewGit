//
//  SearchRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/5.
//  Copyright © 2015年 CXH. All rights reserved.
//

///http://api.huaban.com/search/?page=1&per_page=20&q=%E5%93%A6

import UIKit

//MARK: - SearchPinsRequest 搜索的采集
class SearchPinsRequest: BaseRequest {
    var page: Int = 0
    var searchStr: String = ""
    var category: String?
    var pins: [Pin]?
    
    var pin_count: NSNumber = 0
    var board_count: NSNumber = 0
    var people_count: NSNumber = 0
    var gift_count: NSNumber = 0
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        return baseUrl + "/search/" + AppURL.SearchType.pin.rawValue
    }
    
    override func requestParameters() -> [String : String]? {
        
        var dict = ["q" : searchStr]
        dict["page"] = "\(page)"
        dict["per_page"] = "\(20)"

        if category != nil {
            dict["category"] = category!
        }
        return dict
    }
    
    override func handleResult() {
        var result: NSDictionary!
        
        if self.isDataFromCache() {
            result = self.cacheJson as! NSDictionary
        } else {
            result = self.responseJSONObject as! NSDictionary
        }
        
        if let arr = result["pins"] as? NSArray {
            pins = arr.map({ Pin().mj_setKeyValues($0) })
        }
        
        if page <= 1 {
            pin_count = Safe.safeNSNumber(result.objectForKey("pin_count") as? NSNumber)
            board_count = Safe.safeNSNumber(result.objectForKey("board_count") as? NSNumber)
            people_count = Safe.safeNSNumber(result.objectForKey("people_count") as? NSNumber)
            gift_count = Safe.safeNSNumber(result.objectForKey("gift_count") as? NSNumber)
        }
        
    }
}

//MARK: - SearchBoardsRequest 搜索的画板
class SearchBoardsRequest: BaseRequest {
    var page: Int = 0
    var searchStr: String = ""
    var category: String?
    var boards: [Board]?

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        return baseUrl + "/search/" + AppURL.SearchType.boards.rawValue
    }
    
    override func requestParameters() -> [String : String]? {
        var dict = ["q" : searchStr]
        dict["page"] = "\(page)"
        dict["per_page"] = "\(20)"
        
        if category != nil {
            dict["category"] = category!
        }
        return dict
    }
    
    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson["boards"] as? NSArray
        } else {
            result = self.responseJSONObject["boards"] as? NSArray
        }
        
        if let arr = result {
            boards = arr.map({ Board().mj_setKeyValues($0) })
        }
    }
    
}

//MARK: - SearchUsersRequest 搜索的用户
class SearchUsersRequest: BaseRequest {
    var page: Int = 0
    var searchStr: String = ""
    var category: String?
    var users: [User]?

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        return baseUrl + "/search/" + AppURL.SearchType.people.rawValue
    }
    
    override func requestParameters() -> [String : String]? {
        var dict = ["q" : searchStr]
        dict["page"] = "\(page)"
        dict["per_page"] = "\(20)"
        
        if category != nil {
            dict["category"] = category!
        }
        return dict
    }
    
    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson["users"] as? NSArray
        } else {
            result = self.responseJSONObject["users"] as? NSArray
        }
        
        if let arr = result {
            users = arr.map({ User().mj_setKeyValues($0) })
        }
    }
    
}