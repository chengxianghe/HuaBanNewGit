//
//  FollowRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/9.
//  Copyright © 2015年 CXH. All rights reserved.
//
// http://api.huaban.com/?username=zpalzqleic 首页
// http://api.huaban.com/zpalzqleic/following/boards 关注的画板
// http://api.huaban.com/zpalzqleic/following/ 关注的用户
import UIKit

//MARK: - FollowingPinRequest 用户关注的采集
class FollowingPinRequest: BaseRequest {
    
    var page: Int = 1
    var boardId: String = "12222662"
    var resultBoard: Board?
    var promotions = false
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        ///http://huaban.com?username=zpalzqleic 首页 用户关注的采集
        return baseUrl
    }
    
    override func requestParameters() -> [String : String]? {
        
        return ["username" : AppUser.defaultUser.urlname]
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

//MARK: - FollowingUserRequest 用户关注的人
class FollowingUserRequest: BaseRequest {
    
    var page: Int = 1
    var urlname: String!
    var users: [User]?
    
    var fansCount: NSNumber?
    var followsCount: NSNumber?

    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        ///http://api.huaban.com/zpalzqleic/following/  首页 用户关注的用户
        return baseUrl + "/\(urlname)/\(AppURL.FollowType.following.rawValue)"
    }

    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson["users"] as? NSArray
        } else {
            result = self.responseJSONObject["users"] as? NSArray
        }
        
        if result != nil {
            users = result!.map({ User().mj_setKeyValues($0) })
        }
    }
}

//MARK: - FollowerUserRequest 用户的粉丝
class FollowerUserRequest: BaseRequest {
    
    var page: Int = 1
    var urlname: String!
    var users: [User]?
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        ///http://api.huaban.com/zpalzqleic/followers/  首页 用户关注的用户
        return baseUrl + "/\(urlname)/\(AppURL.FollowType.followers.rawValue)"
    }
    
    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson["users"] as? NSArray
        } else {
            result = self.responseJSONObject["users"] as? NSArray
        }
        
        if result != nil {
            users = result!.map({ User().mj_setKeyValues($0) })
        }
    }
}


//MARK: - FollowBoardRequest 用户关注的画板
class FollowBoardRequest: BaseRequest {
    
    var page: Int = 1
    var resultBoard: Board?
    
    var boards: [Board]?
    var resultUser: User?
    var filter: Bool = false
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // http://api.huaban.com/zpalzqleic/following/boards 首页 用户关注的画板
        return baseUrl + "/\(AppUser.defaultUser.urlname)/\(AppURL.FollowType.followBoards.rawValue)"
    }
    
    override func requestParameters() -> [String : String]? {
        return ["page" : "\(page)"]
    }

    override func handleResult() {
        var result: NSDictionary!
        
        if self.isDataFromCache() {
            result = self.cacheJson as! NSDictionary
        } else {
            result = self.responseJSONObject as! NSDictionary
        }
        
        if let ret = result["filter"] as? Bool {
            filter = ret
        }

        resultUser = User().mj_setKeyValues(result["user"] as? NSDictionary)
        
        if let arr = result["boards"] as? NSArray {
            boards = arr.map({ Board().mj_setKeyValues($0) })
        }
        
    }
    
}

//MARK: - FollowExploreRequest 用户关注的兴趣点
class FollowExploreRequest: BaseRequest {
    
    var page: Int = 1
    var resultBoard: Board?
    
    var boards: [Board]?
    var resultUser: User?
    var filter: Bool = false
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // http://api.huaban.com/zpalzqleic/following/explores 首页 用户关注的画板
        return baseUrl + "/\(AppUser.defaultUser.urlname)/\(AppURL.FollowType.followExplores.rawValue)"
    }
    
    override func requestParameters() -> [String : String]? {
        return ["page" : "\(page)"]
    }
    
    override func handleResult() {
        var result: NSDictionary!
        
        if self.isDataFromCache() {
            result = self.cacheJson as! NSDictionary
        } else {
            result = self.responseJSONObject as! NSDictionary
        }
        
        if let ret = result["filter"] as? Bool {
            filter = ret
        }
        
        resultUser = User().mj_setKeyValues(result["user"] as? NSDictionary)
        
        if let arr = result["boards"] as? NSArray {
            boards = arr.map({ Board().mj_setKeyValues($0) })
        }
        
    }
    
}


