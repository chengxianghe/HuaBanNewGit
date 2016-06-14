//
//  XHSaveHelper.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/3.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class XHSaveHelper {
    
    /** 本地缓存 */
    static func save(object: AnyObject?, forKey: String!) {
        NSUserDefaults.standardUserDefaults().setValue(object, forKey: forKey)
    }
    
    static func getAnyObjectForKey(key: String!) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    static func saveCacheForRequest(request: BaseRequest) {
        if !request.isDataFromCache() {
            let json = request.responseJSONObject
            if json != nil && json.conformsToProtocol(NSCoding) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

                    let result = NSKeyedArchiver.archiveRootObject(json, toFile: request.cachePath())
                    if result {
                        print("\(request.classForCoder)" + "本地缓存--完成! --> \(request.cachePath())")
                    } else {
                        print("\(request.classForCoder)" + "本地缓存--失败! --> \(request.cachePath())")
                    }
                })
            }
        }
    }
    
    static func getCacheForRequest(request: BaseRequest) -> AnyObject? {
        // 包括参数的当前请求的缓存路径
        let currentPath = XHSaveHelper.cachePathForRequest(request)
        
        // 固定的缓存路径
        let path = request.cachePath()
        
        if currentPath == path {
            if request.cacheJson != nil {
                return request.cacheJson
            } else {
                if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: nil) {
                    // 防止异常
                    SwiftTryCatch.swtry({ () -> Void in
                        request.cacheJson = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
                        }, swcatch: { (exception) -> Void in
                            print("------- 擦! 数据损坏了!")
                            print(exception)
                        }, swfinally: { () -> Void in
                    })
                }
                return request.cacheJson;
            }
        }
        
        print("没有缓存!")
        return nil
    }
    
    static func cacheBasePathForRequest(request: BaseRequest) -> String {
        
        let pathOfLibrary = self.cacheDirPath()
        
        // userId/requestClassName
        let path = pathOfLibrary.stringByAppendingString(String(format: "/%@/\(request.classForCoder)", self.cachePathUserId()))
        
        self.createBaseDirectoryAtPath(path)
        
        return path;
    }
    
    static func cachePathUserId() -> String {
        return AppUser.defaultUser().user_id.stringValue
    }
    
    static func cachePathForRequest(request: BaseRequest) -> String {
        let cacheFileName = self.cacheFileNameForRequest(request)
        let path = self.cacheBasePathForRequest(request)
        let requestCachePath = path.stringByAppendingString("/" + cacheFileName)
        return requestCachePath;
    }
    
    static func cacheFileNameForRequest(request: BaseRequest) -> String {
        var requestInfo = String(format: "AppVersion:%@ Method:%ld ", AFNetworkHelper.appVersionString(),request.requestMethod().rawValue);
        
        if request.requestUrl() != nil {
           requestInfo = requestInfo.stringByAppendingString(String(format: "Url:%@", request.requestUrl()!))
 
        }
        
        if request.requestParameters() != nil {
            requestInfo = requestInfo.stringByAppendingString("Argument:\(request.requestParameters()!)")
        }
        
        let cacheFileName = AFNetworkHelper.md5StringFromString(requestInfo)
        
        return String(format: "%@.json", cacheFileName);
    }
    
    static func createBaseDirectoryAtPath(path: String) {
        
        if NSFileManager.createDirectory(path) {
            // cloud 不用备份
            AFNetworkHelper.addDoNotBackupAttribute(path)
        } else {
            print ("create cache directory failed")
        }
        
    }
    
    static func clearCacheForRequest(request: BaseRequest) {
        NSFileManager.removeItem(request.cachePath())
    }
    
    static func clearAllCache() {
        NSFileManager.removeItem(self.cacheDirPath());
    }
    
    static func cacheDirPath() -> String {
        let pathOfLibrary = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        
        let dirPath = String(format:"%@/RequestCache", pathOfLibrary)
        
        return dirPath;
    }
    
    static func getCacheSizeOfAll() -> CGFloat {
        return NSFileManager.folderSizeAtPath(self.cacheDirPath())/(1024*1024)
    }
    
    static func getCacheSizeWithRequest(request: BaseRequest) -> CGFloat {
        return NSFileManager.fileSizeAtPath(request.cachePath())
    }
    
}
