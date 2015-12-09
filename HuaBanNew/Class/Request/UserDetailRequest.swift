//
//  UserDetailRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/5.
//  Copyright © 2015年 CXH. All rights reserved.
//

// 访问个人主页 ESRootUser
//http ://api.huaban.com/dinghao8005/
/// http://huaban.com/zpalzqleic/following/boards
import UIKit

//MARK: - UserDetailRequest 用户信息
class UserDetailRequest: BaseRequest {

    var resultUser: User?
    var userId: NSNumber!

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // http://api.huaban.com/users/18016051/ 个人信息
        return baseUrl + "/users/" + userId.stringValue
    }
    
    override func handleResult() {
        var result: NSDictionary!
        
        if self.isDataFromCache() {
            result = self.cacheJson as! NSDictionary
        } else {
            result = self.responseJSONObject as! NSDictionary
        }
        
        resultUser = User().mj_setKeyValues(result)
        
    }
    
}


//MARK: - UserBoardsRequest 用户的画板
class UserBoardsRequest: BaseRequest {
    var page: Int = 1
    var boards: [Board]?
    var user: User!
    var max: NSNumber?

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // http://api.huaban.com/zpalzqleic 个人页 用户的画板
        return baseUrl + "/" + user.urlname
    }
    
    override func requestParameters() -> [String : String]? {
        
        //?limit=\(page * 20) //&max=515467442
        var dict = ["limit": "20"]
        if max != nil {
            dict["max"] = max!.stringValue
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

//MARK: - UserPinsRequest 用户的采集
class UserPinsRequest: BaseRequest {
    var page: Int = 1
    var pins: [Pin]?
    var max: NSNumber?
    var user: User!

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // http://api.huaban.com/zpalzqleic/pins 个人页 用户的采集
        return baseUrl + "/\(user.urlname)" + "/\(AppURL.UserInfoType.pins.rawValue)"
    }
    
    override func requestParameters() -> [String : String]? {

        //?limit=\(page * 20) //&max=515467442
        var dict = ["limit": "20"]
        if max != nil {
            dict["max"] = max!.stringValue
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
            pins = arr.map({ Pin().mj_setKeyValues($0) })
        }
    }
    
}

//MARK: - UserLikesRequest 用户的喜欢
class UserLikesRequest: BaseRequest {
    var page: Int = 1
    var likes: [Pin]?
    var max: NSNumber?
    var user: User!

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        /**
        http://huaban.com/yunyifenglin/likes/?ihjwrjbr&max=40425058&limit=20&wfl=1
        */
        // http://api.huaban.com/zpalzqleic/likes 个人页 用户的采集
        return baseUrl + "/\(user.urlname)" + "/\(AppURL.UserInfoType.likes.rawValue)"
    }
    
    override func requestParameters() -> [String : String]? {
        
        //?limit=\(page * 20) //&max=515467442
        var dict = ["limit": "20"]
        if max != nil {
            dict["max"] = max!.stringValue
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
        
        if result != nil {
            likes = result!.map({ Pin().mj_setKeyValues($0) })
        }
    }
}

//MARK: - UserSaysRequest 用户的发言
class UserSaysRequest: BaseRequest {
    var page: Int = 1
    var says: [Post]?
    var user: User!
    var max: NSNumber?

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // TODO
        // http://huaban.com/mobile_topics/75/posts? 个人页 用户的发言 这里暂用朋友圈发言代替
        return baseUrl + "/mobile_topics/75/posts?"
    }
    
    override func requestParameters() -> [String : String]? {
        
        //?limit=\(page * 20) //&max=515467442
        var dict = ["limit": "20"]
        if max != nil {
            dict["max"] = max!.stringValue
        }
        return dict
    }
    
    override func handleResult() {
        var result: NSArray!
        
        if self.isDataFromCache() {
            result = self.cacheJson["posts"] as! NSArray
        } else {
            result = self.responseJSONObject["posts"] as! NSArray
        }
        
        says = result.map({ Post().mj_setKeyValues($0) })

    }
}
