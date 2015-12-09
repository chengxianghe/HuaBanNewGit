//
//  WebImageExt.swift
//  JokeMusic
//
//  Created by chengxianghe on 15/10/15.
//  Copyright © 2015年 CXH. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

public typealias CXHDownloadSuccessBlock = ((imageURL: NSURL , image: UIImage) -> ())
public typealias CXHDownloadFailureBlock = ((error: NSError) -> ())
public typealias CXHDownloadProgressBlock = ((receivedSize: Int, totalSize: Int, progress: CGFloat) -> ())

extension UIImageView {
    
    //MARK: - 图片下载
    /**
    下载图片 带进度的
    
    :param: progress 进度百分比
    */
    func downloadImageProgress(Url url: NSURL?, placeholder place: UIImage?, progress: CXHDownloadProgressBlock?,success: CXHDownloadSuccessBlock?, failure: CXHDownloadFailureBlock?) {
        
        if url == nil {
            return
        }
        
        self.sd_setImageWithURL(url!, placeholderImage: place, options: SDWebImageOptions.LowPriority, progress: { (receivedSize, totalSize) -> Void in
            if totalSize < 0 {
                progress?(receivedSize: receivedSize, totalSize: -totalSize, progress: -CGFloat(receivedSize)/CGFloat(totalSize))
            } else {
                progress?(receivedSize: receivedSize, totalSize: totalSize, progress: CGFloat(receivedSize)/CGFloat(totalSize))
            }
            }) { (image, error, cacheType, imageURL) -> Void in
                if (error != nil) {
                    failure?(error: error!);
                }else{
                    self.image = image;
                    success?(imageURL: imageURL!,image: image!);
                }

        }
        
    }
    
    /**
    下载图片 有成功和失败回调
    */
    func downloadImage(Url url: NSURL?, placeholder place: UIImage?, success: CXHDownloadSuccessBlock?, failure: CXHDownloadFailureBlock?) {
        
        self.downloadImageProgress(Url: url, placeholder: place, progress: { (receivedSize, totalSize, progress) -> () in
            }, success: success, failure: failure)
        
    }
    
    /**
    下载图片
    */
    func downloadImage(Url url: NSURL?, placeholder place: UIImage?) {
        
        self.downloadImageProgress(Url: url, placeholder: place, progress: { (receivedSize, totalSize, progress) -> () in
            }, success: { (imageURL, image) -> () in
            }) { (error) -> () in
        }
        
    }
    
    /**
    下载图片
    */
    func downloadImage(Url url: NSURL?) {
        
        self.downloadImageProgress(Url: url, placeholder: nil, progress: { (receivedSize, totalSize, progress) -> () in
            }, success: { (imageURL, image) -> () in
            }) { (error) -> () in
        }
        
    }
}

extension UIButton {
    //MARK: - 图片下载
    /**
    下载图片 带进度的
    
    :param: progress 进度百分比
    */
    func downloadImageProgress(Url url: NSURL?, forState state: UIControlState, placeholder place: UIImage?, progress: CXHDownloadProgressBlock?,success: CXHDownloadSuccessBlock?, failure: CXHDownloadFailureBlock?) {
        
        if url == nil {
            return
        }
        
        self.sd_setImageWithURL(url!, forState: state, placeholderImage: place, options: SDWebImageOptions.RetryFailed) { (image, error, cacheType, imageURL) -> Void in 
            if (error != nil) {
                failure?(error: error!);
            }else{
                success?(imageURL: imageURL!,image: image!);
            }
        }
    }
    
    /**
    下载图片 有成功和失败回调
    */
    func downloadImage(Url url: NSURL?, forState state: UIControlState, placeholder place: UIImage?, success: CXHDownloadSuccessBlock?, failure: CXHDownloadFailureBlock?) {
        
        self.downloadImageProgress(Url: url, forState: state, placeholder: place, progress: { (receivedSize, totalSize, progress) -> () in
            
            }, success: success, failure: failure)
        
    }
    
    /**
    下载图片
    */
    func downloadImage(Url url: NSURL?, forState state: UIControlState, placeholder place: UIImage?) {
        
        self.downloadImageProgress(Url: url, forState: state, placeholder: place, progress: { (receivedSize, totalSize, progress) -> () in
            
            }, success: { (imageURL, image) -> () in
                
            }) { (error) -> () in
        }
    }
    
    
    /**
    下载图片
    */
    func downloadImage(Url url: NSURL?, forState state: UIControlState) {
        
        self.downloadImageProgress(Url: url, forState: state, placeholder: nil, progress: { (receivedSize, totalSize, progress) -> () in
            
            }, success: { (imageURL, image) -> () in
                
            }) { (error) -> () in
                
        }
        
    }
}

