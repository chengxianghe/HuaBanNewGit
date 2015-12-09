//
//  PinDetail.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class PinDetail: Pin {

    // 下面的在详情才会有
    var siblings: [Pin]?
    var repins: [Pin]?
    var likes: [User]?
    var category: String?
    var via_pin: Pin?
    var original_pin: Pin?
    var breadcrumb: String?
    var next: Pin?
    var prev: Pin?

    //MARK: - MJExtension ClassInArray
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return [
            "siblings" : Pin.classForCoder(),
            "repins" : Pin.classForCoder(),
            "likes" : User.classForCoder(),
        ]
    }
}
