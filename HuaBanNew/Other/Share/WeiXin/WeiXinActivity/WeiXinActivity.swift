//
//  WeixinActivity.swift
//  HuaBanNew
//
//  Created by chengxianghe on 16/6/16.
//  Copyright © 2016年 CXH. All rights reserved.
//

import Foundation

class WeiXinBaseActivity: UIActivity {
    var title: String?
    var shareDescription: String?
    var image: UIImage?
    var url: NSURL?
    var scene: WXScene = WXSceneSession
    var thumbImage: UIImage?
    
    override init() {
        super.init()
    }
    
    // 返回值是告诉系统这个是action类型，还是share类型的，一般默认的是action类型的   
    internal override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Share
    }
    
    // 用来区分不用的activity的字符串
    override func activityType() -> String? {
        return "HuaBanNew" + NSStringFromClass(self.classForCoder);
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            for activityItem in activityItems {
                if activityItem.isKindOfClass(UIImage.classForCoder()) {
                    return true
                }
                
                if activityItem.isKindOfClass(NSURL.classForCoder()) {
                    return true
                }
                
                if activityItem.isKindOfClass(NSString.classForCoder()) {
                    return true
                }
            }
        }
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activityItem in activityItems {
            if activityItem.isKindOfClass(UIImage.classForCoder()) {
                image = activityItem as? UIImage
            }
            
            if activityItem.isKindOfClass(NSURL.classForCoder()) {
                url = activityItem as? NSURL
            }
            
            if activityItem.isKindOfClass(NSString.classForCoder()) {
                title = activityItem as? String
            }
        }
    }
    
    override func performActivity() {
        let req = SendMessageToWXReq()
        req.scene = Int32(scene.rawValue)
        req.bText = title != nil && (title! as NSString).length > 0 && image == nil && url == nil

        /** 发送消息的类型，包括文本消息和多媒体消息两种，两者只能选择其一，不能同时发送文本和多媒体消息 */
        if req.bText {
            // 文本长度必须大于0且小于10K
            req.text = title
        } else {
            req.message = WXMediaMessage()
            req.message.title = title
            req.message.description = shareDescription?.length > 100 ? (shareDescription! as NSString).substringToIndex(100) : shareDescription
            
            if url != nil {
                let webObject = WXWebpageObject()
                webObject.webpageUrl = url?.absoluteString
                thumbImage = thumbImage ?? image
                if thumbImage != nil {
                    let thumbImageData = ShareManager.scaleImageDataForSize(thumbImage!, limitDataSize: 30000);
                    print(thumbImageData?.length)
                    req.message.thumbData = thumbImageData;
                }
                req.message.mediaObject = webObject
            } else if image != nil {
                let imageObject = WXImageObject()
                // 原图 最多不能超过10M 10485760
                let imageData = ShareManager.scaleImageDataForSize(image!, limitDataSize: 10000000);
                imageObject.imageData = imageData
                //缩略图数据大小不能超过32K - 32768
                thumbImage = thumbImage ?? image
                let thumbImageData = ShareManager.scaleImageDataForSize(thumbImage!, limitDataSize: 30000);
                print(thumbImageData?.length)
                req.message.thumbData = thumbImageData;
                req.message.mediaObject = imageObject
            }
        }
        WXApi.sendReq(req)
        
        self.activityDidFinish(true)
    }
    
}

class WeiXinSessionActivity: WeiXinBaseActivity {
    override init() {
        super.init()
        scene = WXSceneSession
    }
    
    // ios8.0 是支持彩色团素材的，返回的是你所要点击的图标，
    override func activityImage() -> UIImage? {
//        if Int(UIDevice.currentDevice().systemVersion) >= 8 {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_session-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        } else {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_session" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        }
        
        return UIImage(named: "WeiXinActivity.bundle" + "/icon_session-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
    }
    
    // 返回的是选项图标下面的文字
    override func activityTitle() -> String? {
        return NSLocalizedString("weixin-session", tableName: "WeiXinActivity", bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}

class WeiXinTimelineActivity: WeiXinBaseActivity {
    override init() {
        super.init()
        scene = WXSceneTimeline
    }
    
    override func activityImage() -> UIImage? {
//        if Int(UIDevice.currentDevice().systemVersion) >= 8 {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        } else {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        }
        return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
    }
    
    override func activityTitle() -> String? {
        return NSLocalizedString("weixin-timeline", tableName: "WeiXinActivity", bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}

class WeiXinFavoriteActivity: WeiXinBaseActivity {
    override init() {
        super.init()
        scene = WXSceneFavorite
    }
    // default is UIActivityCategoryAction.
    internal override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Action
    }
    override func activityImage() -> UIImage? {
//        if Int(UIDevice.currentDevice().systemVersion) >= 8 {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        } else {
//            return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
//        }
        return UIImage(named: "WeiXinActivity.bundle" + "/icon_timeline-8" + (UIScreen.mainScreen().scale > 1 ? "@2x" : "")  + ".png")
    }
    
    override func activityTitle() -> String? {
        return NSLocalizedString("weixin-favorite", tableName: "WeiXinActivity", bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}