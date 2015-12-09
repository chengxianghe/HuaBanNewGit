//
//  BaseRequest.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/5.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import Alamofire

/*
enum SearchType: String {
case pin = "pin" // 采集
case boards = "boards" // 画板
case people = "people" // 用户
case gift = "gift" // 用户

}

*/
//
enum BaseRequestMethod: Int {
    case Get = 0
    case Post = 1
};

enum BaseRequestCacheOption: Int {
    /**普通网络请求,不会有缓存*/
    case None = 0
    
    /**优先读取网络,成功会缓存,失败会返回本地缓存,本地缓存也没有才会调用failure,只回调一次*/
    case RefreshPriority = 1
    
    /**只读取本地,离线模式*/
    case CacheOnly = 2
    
    /**每次参数不同的请求都会缓存*/
    case CacheAll = 3
    
};

internal typealias BaseRequestSuccess = ((request: BaseRequest) -> ())
internal typealias BaseRequestFailur = ((request: BaseRequest, error: NSError) -> ())

class BaseRequest: NSObject {
    
    var cacheJson: AnyObject!
    var responseJSONObject: AnyObject!
    var alamofireRequest: Request!
    var cacheOption: BaseRequestCacheOption?
    var success: BaseRequestSuccess?
    var failure: BaseRequestFailur?
    
    private var requestCachePath: String!
    private var isFromCache = false
    
    func isDataFromCache() -> Bool {
        return self.isFromCache
    }

    func cachePath() -> String {
        
        if cacheOption == .CacheAll {
            // 每次都存
            self.requestCachePath = XHSaveHelper.cachePathForRequest(self)
        } else {
            // 每个请求只缓存一个
            if self.requestCachePath == nil {
                self.requestCachePath = XHSaveHelper.cachePathForRequest(self)
            }
        }
        return self.requestCachePath
    }
    
    func requestMethod() -> BaseRequestMethod {
        return .Get
    }
    
    func requestUrl() -> String? {
        return ""
    }
    
    func requestParameters() -> [String : String]? {
        return nil
    }
    
    func handleResult() {
        
    }
    
    func requestWithRequestOption(cacheOption:BaseRequestCacheOption, sucess:BaseRequestSuccess?, failur: BaseRequestFailur?) {
        
        self.cacheOption = cacheOption
        self.success = sucess
        self.failure = failur
        
        if cacheOption == .CacheOnly {
            let json = XHSaveHelper.getCacheForRequest(self)
            if json != nil {
                self.cacheJson = json!
                self.isFromCache = true
                self.handleResult()
                sucess?(request: self)
            } else {
                failur?(request: self, error: NSError(domain: "本地缓存读取失败!", code: 400, userInfo: nil))
            }
            
        } else {
            
            let filteredUrl = AFNetworkHelper.urlStringWithOriginUrlString(self.requestUrl(), appendParameters: self.requestParameters())
            
            print("****** AddRequest: \(self.classForCoder) -- " + filteredUrl)
            
            if self.requestMethod() == .Get {
                self.alamofireRequest = Alamofire.request(.GET, filteredUrl, parameters: nil)
                    .validate()
                    .responseJSON { response in
                        self.finishedRequest(response)
                }

            } else if self.requestMethod() == .Post {
                self.alamofireRequest = Alamofire.request(.POST, filteredUrl, parameters: nil)
                    .validate()
                    .responseJSON { response in
                        self.finishedRequest(response)
                }

            }
        }
        
    }
    
    
    func cancelRequest() {
        self.alamofireRequest.cancel()
    }
    
    func finishedRequest(respon: Response<AnyObject, NSError>) {
        
        self.alamofireRequest.responseJSON { (response) -> Void in
            switch response.result {
            case .Success:
                print("****** FinishedRequest: " + "\(self.classForCoder)")
                self.responseJSONObject = response.result.value
                self.isFromCache = false
                
                if (self.cacheOption == .RefreshPriority) || (self.cacheOption == .CacheAll) {
                    XHSaveHelper.saveCacheForRequest(self)
                }
                
                self.handleResult()
                self.success?(request: self)
            case .Failure(let error):
                print(error)
                self.isFromCache = true
                
                var isHaveCache = false
                if (self.cacheOption == .RefreshPriority) || (self.cacheOption == .CacheAll) {
                    let json = XHSaveHelper.getCacheForRequest(self)
                    if json != nil {
                        isHaveCache = true
                        self.cacheJson = json
                    }
                }
                
                if isHaveCache {
                    self.handleResult()
                    self.success?(request: self)
                } else {
                    self.failure?(request: self, error: error)
                }
                
            }
        }
    }
    
}
