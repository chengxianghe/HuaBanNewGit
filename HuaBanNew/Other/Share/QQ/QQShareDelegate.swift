//
//  QQShareDelegate.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class QQShareDelegate: NSObject,QQApiInterfaceDelegate {
    
    class var currenQQshareDelegate: QQShareDelegate {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: QQShareDelegate? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = QQShareDelegate()
        }
        return Static.instance!
    }
    
    /**
     处理来至QQ的请求
     */
    func onReq(req: QQBaseReq!) {
        
    }
    
    /**
    处理来至QQ的响应
    */
    func onResp(resp: QQBaseResp!) {
        
        if resp.isKindOfClass(SendMessageToQQResp.classForCoder()) {
                        
            var codeStr = "分享成功";
            if(resp.errorDescription.length == 0)
            {
                // 发出通知 返积分
     
            }
            else if(resp.result == "-4")
            {
                codeStr = "取消分享";
            }
            else{
                codeStr = "分享失败";
            }
            
            print("处理来至QQ的响应:" + codeStr);
        }

    }

    /**
     处理QQ在线状态的回调
     */
    func isOnlineResponse(response: [NSObject : AnyObject]!) {
        
    }
}
