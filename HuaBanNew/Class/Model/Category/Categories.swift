//
//  Categories.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class Categories: BaseModel {

    var covers: [Covers]?

    var es_id: String?

    var urlname: String?

    var name: String?

    var col: NSNumber = 0

    var nav_link: String?



    //MARK: - MJExtension ReplaceKey ["自己的key" : "网络的key"]
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["es_id" : "id"]
    }

    //MARK: - MJExtension ClassInArray
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["covers" : Covers.classForCoder()]
    }
}