//
//  WeiXinShareHelp.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/8.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class WeiXinShareHelp: NSObject {
    
    static let instance = WeiXinShareHelp()
    class func currentHelp() -> WeiXinShareHelp {
        return instance
    }
    
    /**
     发送文本数据
     
     - parameter text:  文本
     - parameter scene: 场景
     
     - returns: Bool
     */
    func sendText(text: String, InScene scene:WXScene) -> Bool {
        if !self.checkWeiXinClient() {
            return false;
        }

        let req = self.requestWithText(text, mediaMessage: nil, bText: true, InScene: scene)
        
        return WXApi.sendReq(req);
    }
    
    /**
     发送图片数据
     
     - parameter image: 图片
     - parameter scene: 场景
     
     - returns: Bool
     */
    func sendImageData(image: UIImage?, InScene scene:WXScene) -> Bool {
        if !self.checkWeiXinClient() {
            return false;
        }
        // 原图 最多不能超过10M 10485760
        let imageData = ShareManager.scaleImageDataForSize(image!, limitDataSize: 10000000);
        print(imageData?.length)
        
        //
        let ext = WXImageObject()
        ext.imageData = imageData;
        
        let message = WXMediaMessage()
        message.title = "titlesss";
        message.description = "description";
        message.mediaObject = ext;
        
        //缩略图数据大小不能超过32K - 32768
        let thumbImageData = ShareManager.scaleImageDataForSize(image!, limitDataSize: 30000);
        print(thumbImageData?.length)
        message.thumbData = thumbImageData;
        
        let req = SendMessageToWXReq()
        req.bText = false;
        req.message = message;
        req.scene = Int32(scene.rawValue)
        
        return WXApi.sendReq(req);
    }
    
    /**
     发送链接数据
     
     - parameter urlString:   链接
     - parameter title:       标题
     - parameter description: 描述
     - parameter thumbImage:  缩略图
     - parameter scene:       场景
     
     - returns: Bool
     */
    func sendLinkURL(urlString: String, title: String, description: String, thumbImage: UIImage?, InScene scene:WXScene) -> Bool {
        if !self.checkWeiXinClient() {
            return false;
        }
        let ext = WXWebpageObject()
        ext.webpageUrl = urlString;

        let message = WXMediaMessage()
        message.title = title;
        message.description = description;
        message.mediaObject = ext;
        message.mediaTagName = "tagName"
        if thumbImage != nil {
            let thumbImageData = ShareManager.scaleImageDataForSize(thumbImage!, limitDataSize: 30000);
            message.thumbData = thumbImageData;
            print(thumbImageData?.length)
        }
        
        let req = self.requestWithText(nil, mediaMessage: message, bText: false, InScene: scene)
        
        return WXApi.sendReq(req);
    }
    
    func requestWithText(text: String?,
                         mediaMessage: WXMediaMessage?,
                         bText: Bool,
                         InScene scene: WXScene) -> SendMessageToWXReq {
        let req = SendMessageToWXReq();
        req.bText = bText;
        req.scene = Int32(scene.rawValue);
        if (bText) {
            req.text = text;
        } else {
            req.message = mediaMessage;
        }
        return req;
        
    }
    
    /**
     检测微信客户端
     
     - returns: Bool
     */
    func checkWeiXinClient() -> Bool {
        if(WXApi.isWXAppInstalled() == false) {
            print("抱歉,您没有安装微信")
            return false;
        }
        
        if(WXApi.isWXAppSupportApi() == false) {
            print("请下载最新的微信")
            return false;
        }
        
        return true
    }
}
