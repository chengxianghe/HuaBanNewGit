//
//  ShareManager.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

enum ShareType: Int {
    case
    WeiBoShare = 0, //分享到新浪微博
    WeiXinFriendsShare,    //分享到微信朋友圈
    WeiXinShare,      //分享到微信好友
    WeiXinFavoriteShare,  //分享到微信收藏
    QZoneShare,  //分享到QQ空间
    QQShare       //分享到QQ
};


class ShareManager: NSObject,UITableViewDelegate {
    
    typealias ShareToThirdWithTypeBlock = ((type: ShareType?) -> ())
    
    var shareView: UIView?;//分享具体UI视图
    var backView: UIView?  //背景黑色蒙层
    var targetView: UIView?;  //目标view
    var shareBlock: ShareToThirdWithTypeBlock?
    
    /**
     *  分享管理工具
     */
    static let instance = ShareManager()
    class func manager() -> ShareManager {
        return instance
    }
    
    /**
    *  创建一个可视化分享视图
    */
    private func createShareView() {
        if self.shareView == nil {
            shareView = UIView(frame: CGRectMake(0, kScreenHeight, kScreenWidth, 300*kScreenWidth/320))
            shareView!.backgroundColor = kRGBA(231, g: 231, b: 231, a: 0.95);
            
            let tipLab = UILabel(frame:CGRectMake(0, 18, kScreenWidth, 12))
            tipLab.text = "分享到";
            tipLab.backgroundColor = UIColor.clearColor()
            tipLab.textColor = kColorFromHexA(0x666666, alpha:1)
            tipLab.font = UIFont.systemFontOfSize(14)
            tipLab.textAlignment = NSTextAlignment.Center;
            shareView!.addSubview(tipLab)
            
            /*
            shareIconWeibo
            shareIconQzone
            shareIconTcweibo
            
            */
            let titleArr = ["新浪微博","朋友圈","微信","微信收藏","QQ空间","QQ"];
            let imageArr = ["share_weibo","share_friends","share_weixin","share_weixin_favorite","share_zone","share_qq"];

            var radius = 60*kScreenHeight/560;
            
            if (kScreenWidth>375) {
                
                radius = 80;
            }
            let distance = (kScreenWidth - 36 - radius * 4)/3;
            
            for i in 0 ..< titleArr.count {
                let btn = UIButton()
                btn.frame = CGRectMake(18 + CGFloat(i%4)*(distance + radius), 60 + CGFloat(i/4)*(radius + 52), radius, radius);
                btn.setImage(UIImage(named: imageArr[i]), forState: UIControlState.Normal)
                btn.addTarget(self, action: #selector(ShareManager.shareBtClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                shareView!.addSubview(btn)
                btn.tag = 2000+i;
                
                let lab = UILabel(frame: CGRectMake(btn.frame.origin.x, btn.frame.origin.y + radius + 5, btn.frame.size.width, 12))
                lab.text = titleArr[i];
                lab.textColor = UIColor.lightGrayColor()
                lab.textAlignment = NSTextAlignment.Center;
                lab.font = UIFont.systemFontOfSize(12)
                shareView!.addSubview(lab)
            }
            
            let cancelBtn = UIButton()
            cancelBtn.frame = CGRectMake(0, shareView!.frame.size.height - 50, kScreenWidth, 50);
            cancelBtn.setTitle("取 消", forState:UIControlState.Normal)
            cancelBtn.titleLabel!.font = UIFont.systemFontOfSize(18)
            cancelBtn.titleLabel!.textColor = kColorFromHexA(0x333333, alpha:1)
            cancelBtn.setTitleColor(UIColor.darkGrayColor(), forState:UIControlState.Normal)
            cancelBtn.backgroundColor = UIColor.whiteColor()
            cancelBtn.addTarget(self, action: #selector(ShareManager.tapHideShareView), forControlEvents: UIControlEvents.TouchUpInside)
            shareView!.addSubview(cancelBtn)
            
            self.backView = UIView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight))
            backView!.backgroundColor = UIColor.blackColor()
            backView!.alpha = 0;
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(ShareManager.tapHideShareView))
            self.backView!.addGestureRecognizer(gesture)
        }
    }
    
    /**
    *  显示分享视图
    */
    func showShareViewWithBlock(block: ShareToThirdWithTypeBlock?) {
        self.shareBlock = block
        
        if (shareView == nil) {
            self.createShareView()
        }
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.addSubview(backView!)
        window?.addSubview(shareView!)

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.shareView!.frame = CGRectMake(0, kScreenHeight - self.shareView!.frame.size.height, kScreenWidth, self.shareView!.frame.size.height);
            self.backView!.alpha = 0.4

            }) { (finished) -> Void in
                
        }
    }
    
    /**
    *  隐藏分享视图
    */
    func hideShareView(completion: ((Bool) -> Void)? = nil) {

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.shareView!.frame = CGRectMake(0, kScreenHeight, kScreenWidth,self.shareView!.frame.size.height);
            self.backView!.alpha = 0

            }) {(finished) -> Void in
                self.backView?.removeFromSuperview()
                completion?(finished);
        //completion	(() -> Void)?	0x00000001001f0a40 HuaBanNew`partial apply forwarder for reabstraction thunk helper from @callee_owned () -> (@unowned ()) to @callee_owned (@in ()) -> (@out ()) at ShareManager.swift
        }
    }
    
    // 不能直接selector调用 会默认传参...
    func tapHideShareView() {
        self.hideShareView()
    }
    
    func shareBtClicked(btn: UIButton) {
        self.hideShareView { (finished) in
            self.shareBlock?(type: ShareType(rawValue: btn.tag - 2000))
        }
    }
}

extension ShareManager {
    static func imageCenterImage(image: UIImage?) -> UIImage? {
        if image == nil {
            return nil
        }
        
        // new size
        let readio = image!.size.width/image!.size.height
        var frame = CGRectMake(0, 0, image!.size.width, image!.size.height)
        if readio >= 1.0 {// 宽的
            frame.origin.x = (image!.size.width - image!.size.height)/2.0
            frame.size.width = frame.size.height
        } else {// 高的
            frame.origin.y = (image!.size.height - image!.size.width)/2.0
            frame.size.height = frame.size.width
        }
        
        // Return the new image.
        let newImage = self.imageFromImage(image!, inRect: frame)
        
        return newImage;
        
    }
    
    //对图片尺寸进行压缩--
    static func imageWithImage(image: UIImage?, scaledToSize newSize: CGSize) -> UIImage? {
        if image == nil {
            return nil
        }
        // Create a graphics image context
        UIGraphicsBeginImageContext(newSize);
        
        // Tell the old image to draw in this new context, with the desired
        image!.drawInRect(CGRectMake(0,0,newSize.width,newSize.height))
        
        // Get the new image from the context
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // End the context
        UIGraphicsEndImageContext();
        
        // Return the new image.
        return newImage;
        
    }
    
    /*!
     *
     *  压缩图片至目标尺寸
     *
     *  @param sourceImage 源图片
     *  @param targetWidth 图片最终尺寸的宽
     *
     *  @return 返回按照源图片的宽、高比例压缩至目标宽、高的图片
     */
    static func compressImage(image: UIImage?, toTargetWidth targetWidth: CGFloat) -> UIImage? {
        if image == nil {
            return nil
        }
        let imageSize = image!.size;
        
        let width = imageSize.width;
        let height = imageSize.height;
        
        let targetHeight = (targetWidth / width) * height;
        
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        image!.drawInRect(CGRectMake(0, 0, targetWidth, targetHeight));
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    static func scaleImageDataForSize(image: UIImage, limitDataSize: UInt) -> NSData? {
        var imageData = UIImageJPEGRepresentation(image, 1.0);
        if imageData?.length == nil {
            return nil
        }
        
        
        if UInt(imageData!.length) > limitDataSize {
            imageData = UIImageJPEGRepresentation(image, 0.5);
            var imageWidth = image.size.width
            while UInt(imageData!.length) > limitDataSize {
                imageWidth = imageWidth * 0.5
                let tempImage = self.compressImage(image, toTargetWidth: imageWidth)
                imageData = UIImageJPEGRepresentation(tempImage!, 0.5);
            }
        }
        return imageData
    }
    
    /**
     *从图片中按指定的位置大小截取图片的一部分
     * UIImage image 原始的图片
     * CGRect rect 要截取的区域
     */
    static func imageFromImage(image: UIImage, inRect rect: CGRect) -> UIImage {
        let sourceImageRef = image.CGImage
        let newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
        let newImage = UIImage(CGImage:newImageRef!)
        return newImage;
    }
}
