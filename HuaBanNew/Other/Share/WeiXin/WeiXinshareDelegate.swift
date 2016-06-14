//
//  WeiXinshareDelegate.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/8.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class WeiXinshareDelegate: NSObject,WXApiDelegate {
    
    typealias WXLogBlock = (code: String) -> Void
    
    var block: WXLogBlock?
    
    class var currenWeiXinshareDelegate: WeiXinshareDelegate {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: WeiXinshareDelegate? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = WeiXinshareDelegate()
        }
        return Static.instance!
    }
    
    func wxLoginStartWithBlock(block: WXLogBlock?) {
        self.block = block
    }
    
    /*! @brief 收到一个来自微信的请求，处理完后调用sendResp
    *
    * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
    * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
    * @param req 具体请求内容，是自动释放的
    */
    func onReq(req: BaseReq!) {
        if req.isKindOfClass(GetMessageFromWXReq.classForCoder()) {
            
            // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
            let strTitle = "微信请求App提供内容"
            let strMsg = "微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
            
            let alert = UIAlertView(title: strTitle, message: strMsg, delegate: self, cancelButtonTitle: "OK")
            alert.tag = 1000;
            alert.show()
        } else if req.isKindOfClass(ShowMessageFromWXReq.classForCoder()) {
            let temp = req as! ShowMessageFromWXReq
            let msg = temp.message;
            
            //显示微信传过来的内容
            let obj = msg.mediaObject;
            
            let strTitle = "微信请求App显示内容"
            let strMsg = String(format: "标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length);
            
            let alert = UIAlertView(title: strTitle, message: strMsg, delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else if req.isKindOfClass(LaunchFromWXReq.classForCoder()) {
            //从微信启动App
            let strTitle = "从微信启动"
            let strMsg = "这是从微信启动的消息"
            let alert = UIAlertView(title: strTitle, message: strMsg, delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
        }
        
    }
    
    /*! @brief 发送一个sendReq后，收到微信的回应
    *
    * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
    * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
    * @param resp具体的回应内容，是自动释放的
    */
    func onResp(resp: BaseResp!) {
        
        //    微信分享处理
        
        if resp.isKindOfClass(SendMessageToWXResp.classForCoder()) {
            
            var codeStr = "分享成功";
            if(resp.errCode == 0) {
                // 发出通知 在当前vc调用爱生活接口
                //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                //    NSString *str = [defaults objectForKey:@"shareFromVC"];
                //    [[NSNotificationCenter defaultCenter] postNotificationName:str object:nil];
                //    NSLog(@"-----%@---接收通知",str);
            }
            else if(resp.errCode == -2)
            {
                codeStr = "取消分享";
            }
            else{
                codeStr = "分享失败";
            }
            print(codeStr)
        }
        //微信登录处理
        if resp.isKindOfClass(SendAuthResp.classForCoder()) {
            
            let aresp = resp as! SendAuthResp
            if (aresp.errCode == 0) {
                let code = aresp.code;
                
                //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                //    [defaults setObject:code forKey:@"wxCode"];
                //    [defaults synchronize];
                
                block?(code: code)
                
                
            }else if (aresp.errCode == -4){
                print("拒绝登录")
                
            }else if (aresp.errCode == -2){
                print("取消登录")
                
            }
        }
        
        //  微信支付处理
        if resp.isKindOfClass(PayResp.classForCoder()) {
            let response = resp as! PayResp
            switch (response.errCode) {
            case 0:
                print("支付成功");
                
                //服务器端查询支付通知或查询API返回的结果再提示成功
                //    [[NSNotificationCenter defaultCenter] postNotificationName:@"GMWXPayResultNotification" object:nil];
                break;
            default:
                print("支付失败， retcode=\(resp.errCode)");
                break;
            }
        }
        
    }
    
    //    //MARK: - delegate
    //    - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    //    {
    //    // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
    //    if (alertView.tag == 1000) {
    //
    //    }
    //    }
    
    
    //    func WXLoginStartWithBlock(block: WXLogBlock) {
    //
    //    block = block;
    //    }

}
