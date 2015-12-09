//
//  Recommends.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class Recommends: BaseModel {

    var file: File?
    
    var is_private: NSNumber = 0

    var status: NSNumber = 0

    var title: String?

    var pin_count: NSNumber = 0

    var url: String?

    var user_id: NSNumber = 0

    var updated_at: NSNumber = 0

    var like_count: NSNumber = 0

    var follow_count: NSNumber = 0

    var recommendation_id: NSNumber = 0

    var cover: Cover?

    var type: String?

    var user: User?

    var target_id: NSNumber = 0

    var seq: NSNumber = 0

    var created_at: NSNumber = 0

    var board_id: NSNumber = 0

    var category_id: String?

    var deleting: NSNumber = 0

    var es_description: String?

    var raw_text: String?
    
    var media_type: NSNumber = 0
    
    var source: String?
    
    var link: String?
    
    var pin_id: NSNumber = 0
    
    var repin_count: NSNumber = 0
    
    var file_id: NSNumber = 0
    
    var via_user: User?
    
    var original: NSNumber = 0
    
    var orig_source: String?
    
    var via: NSNumber = 0
    
    var text_meta: Text_Meta?
    
    var board: Board?
    
    var via_user_id: NSNumber = 0
    
    var comment_count: NSNumber = 0
    

    //MARK: - MJExtension ReplaceKey ["自己的key" : "网络的key"]
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["es_description" : "description"]
    }
}