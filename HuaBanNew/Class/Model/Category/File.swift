//
//  File.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class File: BaseModel {

    var bucket: String?

    var height: NSNumber = 0

    var farm: String?

    var frames: NSNumber = 0

    var width: NSNumber = 0

    var key: String?
    
    var realImageKey: String {
        get {
            if self.key != nil {
                if self.bucket != nil {
                    switch self.bucket! {
                    case "hb-topic-img":
                        return baseTopic + key!
                    case "hbfile":
                        return baseFile + key!
                    default :
                        return baseImage + key!
                    }
                } else {
                    return baseImage + key!
                }
            } else {
                return ""
            }
        }
    }
    
    func realKey(imageType: ImageType) -> String! {
        if imageType == .min {
            return self.realImageKey + imageSize75
        } else if imageType == .small {
            return self.realImageKey + imageSize192
        } else if imageType == .middle {
            return self.realImageKey + imageSize320
        } else if imageType == .big {
            return self.realImageKey + imageSize554
        } else {
            return self.realImageKey + imageSize658
        }
    }
    
    var type: String?


}

enum ImageType: Int {
    case min        = 0
    case small      = 1 //
    case middle     = 2 // 获取id
    case big        = 3 // 获取id
    case max        = 4 // 获取id

}
