//
//  Board.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class Board: BaseModel {

    var board_id: NSNumber = 0
    
    var user_id: NSNumber = 0
    
    var title: String?
    
    var es_description: String?

    //"extra":{"cover":{"pin_id":"315929648"}}
    var extra: Extra?

    var category_id: String?

    var follow_count: NSNumber = 0

    var created_at: NSNumber = 0

    var seq: NSNumber = 0

    var pin_count: NSNumber = 0

    var like_count: NSNumber = 0

    //1445562853
    var updated_at: NSNumber = 0

    var is_private: NSNumber = 0

    var deleting: NSNumber = 0
    
    var pins: [Pin]?

    var user: User?

    //MARK: - MJExtension ReplaceKey ["自己的key" : "网络的key"]
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["es_description" : "description"]
    }
    //MARK: - MJExtension ClassInArray
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["pins" : Pin.classForCoder()]
    }
}

class Extra: BaseModel {
    var cover: Cover?
}