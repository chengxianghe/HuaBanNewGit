//
//  SinaShareDelegate.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class SinaShareDelegate: NSObject,WeiboSDKDelegate {
    var wbtoken: String?
    var wbCurrentUserID: String?

    class var currenSinaShareDelegate: SinaShareDelegate {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SinaShareDelegate? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SinaShareDelegate()
        }
        return Static.instance!
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        if response.isKindOfClass(WBSendMessageToWeiboResponse.classForCoder()) {
    
            /*
            NSString *title = NSLocalizedString(@"发送结果", nil);
            NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
            message:message
            delegate:nil
            cancelButtonTitle:NSLocalizedString(@"确定", nil)
            otherButtonTitles:nil];
            WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
            NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
            if (accessToken)
            {
            self.wbtoken = accessToken;
            [[SinaShareHelp currentHelp] setWbtoken:accessToken];
            }
            NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
            if (userID) {
            self.wbCurrentUserID = userID;
            [[SinaShareHelp currentHelp] setWbCurrentUserID:userID];
            }
            [alert show];
            */
            
            var codeStr = "";
            if (response.statusCode == WeiboSDKResponseStatusCode.UserCancel) {
                codeStr = "取消分享";
            }
            else if (response.statusCode == WeiboSDKResponseStatusCode.Success) {
                codeStr = "分享成功";
            }
            else{
                codeStr = "分享失败";
            }
            print("WBSendMessageToWeiboResponse: \(codeStr)")

        }
        else if (response.isKindOfClass(WBAuthorizeResponse.classForCoder())) {
            //        NSString *title = NSLocalizedString(@"认证结果", nil);
            //        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
            //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
            //                                                        message:message
            //                                                       delegate:nil
            //                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
            //                                              otherButtonTitles:nil];
            
            //        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
            //        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
            //        [[SinaShareHelp currentHelp] setWbtoken:self.wbtoken];
            //        [[SinaShareHelp currentHelp] setWbCurrentUserID:self.wbCurrentUserID];
            //        [alert show];

            print("WBAuthorizeResponse: \(response)")

            
        } else if (response.isKindOfClass(WBPaymentResponse.classForCoder())) {
//            NSString *title = NSLocalizedString(@"支付结果", nil);
//            NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//            message:message
//            delegate:nil
//            cancelButtonTitle:NSLocalizedString(@"确定", nil)
//            otherButtonTitles:nil];
//            [alert show];
            print("WBPaymentResponse: \(response)")
        }
    }
    
}
