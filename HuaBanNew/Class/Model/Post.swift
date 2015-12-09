//
//  Post.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/10.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class Post: BaseModel {

    var comment_count: NSNumber = 0

    var comments: [Comment]?

    var file: File?

    var raw_text: String? {
        didSet {
            if self.raw_text != nil {
                self.raw_text = self.raw_text!.emojizedString()
            }
        }
    }

    var created_at: NSNumber = 0

    var topic_id: NSNumber = 0

    var is_hidden: NSNumber = 0

    var user_id: NSNumber = 0

    var file_id: NSNumber = 0

    var post_id: NSNumber = 0

    var like_count: NSNumber = 0

    var text_meta: Text_Meta?

    var user: User?
    
    //MARK: - MJExtension ClassInArray
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["comments" : Comment.classForCoder()]
    }

}

class Comment: BaseModel {

    var comment_id: NSNumber = 0

    var post_id: NSNumber = 0

    var created_at: NSNumber = 0

    var raw_text: String?

    var user_id: NSNumber = 0

    var text_meta: Text_Meta?

    var user: User?

}



