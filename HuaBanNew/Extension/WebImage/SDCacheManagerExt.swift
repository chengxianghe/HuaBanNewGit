//
//  SDCacheManagerExt.swift
//  JokeMusic
//
//  Created by chengxianghe on 15/10/16.
//  Copyright © 2015年 CXH. All rights reserved.
//

import Foundation
import SDWebImage

extension UIViewController {
    //清除缓存
    func clearCache(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //这里写需要大量时间的代码
            let size = SDImageCache.sharedImageCache().getSize() / 1000 //KB
            print("clear: 缓存:" + "\(size)")

            dispatch_async(dispatch_get_main_queue(), {
                //这里返回主线程，写需要主线程执行的代码
                var string: String
                if size/1000 >= 1{
                    string = "清除缓存 \(size/1000)M"
                }else{
                    string = "清除缓存 \(size)K"
                }
                
                self.showLoading("正在清除缓存:\(string)")
                SDImageCache.sharedImageCache().cleanDiskWithCompletionBlock { () -> Void in
                    self.showSuccess("清除成功")
                }
                
                
            })
        })
    }
}