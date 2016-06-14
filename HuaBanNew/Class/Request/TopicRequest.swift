//
//  TopicRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/14.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

//MARK: - TopicRequest 话题部分
class TopicRequest: BaseRequest {
    var topics: [Topic]?
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        return baseUrl + AppURL.getDataList.topicIds.rawValue
    }
    
    override func handleResult() {
        var result: NSArray?
        
        if self.isDataFromCache() {
            result = self.cacheJson["topics"] as? NSArray
        } else {
            result = self.responseJSONObject["topics"] as? NSArray
        }
        
        if let arr = result {
            topics = arr.map({ Topic().mj_setKeyValues($0) })
        }
    }
}

//MARK: - TopicDetailRequest 话题圈子
class TopicDetailRequest: BaseRequest {
    var page: Int = 1
    var topicId: NSNumber!
    var posts: [Post]?
    
    override func requestMethod() -> BaseRequestMethod {
        return  .Get
    }
    
    override func requestUrl() -> String? {
        // TODO
        // http://huaban.com/mobile_topics/75/posts? 个人页 用户的发言 这里暂用朋友圈发言代替
        return baseUrl + "/mobile_topics/\(topicId)/posts?"
    }
    
    override func handleResult() {
        var result: NSArray!
        
        if self.isDataFromCache() {
            result = self.cacheJson["posts"] as! NSArray
        } else {
            result = self.responseJSONObject["posts"] as! NSArray
        }
        
        posts = result.map({ Post().mj_setKeyValues($0) })
    }
}

