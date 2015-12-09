//
//  Text_Meta.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class Text_Meta: BaseModel {

    var tags: [Tags]?
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["tags" : Tags.classForCoder()]
    }
}