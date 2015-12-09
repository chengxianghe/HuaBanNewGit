//
//  Avatar.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class Avatar: BaseModel {

    var bucket: String?

    var height: NSNumber = 0

    var farm: String?

    var es_id: NSNumber = 0

    var frames: NSNumber = 0

    var width: NSNumber = 0

    var key: String?{
        didSet {
            if key != nil {
                key = baseImage + key!
            }
        }
    }

    var type: String?



    //MARK: - MJExtension ReplaceKey ["自己的key" : "网络的key"]
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["es_id" : "id"]
    }
}