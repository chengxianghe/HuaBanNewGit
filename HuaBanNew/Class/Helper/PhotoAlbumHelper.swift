//
//  PhotoAlbumHelper.swift
//  HuaBanNew
//
//  Created by chengxianghe on 16/6/13.
//  Copyright © 2016年 CXH. All rights reserved.
//

import Foundation
import Photos

//操作结果枚举
enum PhotoAlbumHelperResult {
    case SUCCESS, ERROR, DENIED
}

//相册操作工具类
@available(iOS 8.0, *)
class PhotoAlbumHelper: NSObject {
    
    //判断是否授权
    class func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized ||
            PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.NotDetermined
    }
    
    /**
     保存图片到相册 相册名默认为空 保存在系统相册
     
     - parameter image:      图片
     - parameter albumName:  相册名
     - parameter completion: completion
     */
    class func saveImageInAlbum(image: UIImage, albumName: String = "",
                                completion: ((result: PhotoAlbumHelperResult, error: NSError?) -> ())?) {
        
        //权限验证
        if !isAuthorized() {
            completion?(result: .DENIED, error: nil)
            return
        }
        var assetAlbum: PHAssetCollection?
        
        //如果指定的相册名称为空，则保存到相机胶卷。（否则保存到指定相册）
        if albumName.isEmpty {
            let list = PHAssetCollection
                .fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary,
                                               options: nil)
            assetAlbum = list[0] as? PHAssetCollection
        } else {
            //看保存的指定相册是否存在
            let list = PHAssetCollection
                .fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
            list.enumerateObjectsUsingBlock{ (album, index, isStop) in
                let assetCollection = album as! PHAssetCollection
                if albumName == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    isStop.memory = true
                }
            }
            //不存在的话则创建该相册
            if assetAlbum == nil {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetCollectionChangeRequest
                        .creationRequestForAssetCollectionWithTitle(albumName)
                    }, completionHandler: { (isSuccess, error) in
                        dispatch_async(dispatch_get_main_queue(), {
                            self.saveImageInAlbum(image, albumName: albumName,
                                completion: completion)
                        })
                })
                return
            }
        }
        
        //保存图片
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            //添加的相机胶卷
            let result = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            //是否要添加到相簿
            if !albumName.isEmpty {
                let assetPlaceholder = result.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(forAssetCollection:
                    assetAlbum!)
                albumChangeRequset!.addAssets([assetPlaceholder!])
            }
            }, completionHandler: { (isSuccess: Bool, error: NSError?) in
                dispatch_async(dispatch_get_main_queue(), {
                    //这里返回主线程，写需要主线程执行的代码
                    if isSuccess {
                        completion?(result: .SUCCESS, error: nil)
                    } else{
                        print(error!.localizedDescription)
                        completion?(result: .ERROR, error: error)
                    }
                })
        })
    }
}