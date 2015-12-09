//
//  Topic.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/14.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class Topic: BaseModel {

    var topic_id: NSNumber = 0

    var creator_id: NSNumber = 0

    var follower_count: NSNumber = 0

    var created_at: NSNumber = 0

    var title: String?

    var post_count: NSNumber = 0

    var es_description: String?

    var updated_at: NSNumber = 0

    var icon_id: NSNumber = 0

    var icon: File?
    
    //MARK: - MJExtension ReplaceKey ["自己的key" : "网络的key"]
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["es_description" : "description"]
    }

}

