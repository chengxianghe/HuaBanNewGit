//
//  User.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class User: BaseModel {
    // 可能是对象 也可能是字符串
    var avatar: AnyObject? = "" {
        didSet {
            if (avatar!.isKindOfClass(NSDictionary.classForCoder())) {
                self.avatar = baseImage + ((avatar as! NSDictionary).valueForKey("key") as! String) + imageSize75
            } else if (avatar!.isKindOfClass(NSString.classForCoder())) {
                self.avatar = avatar as! String + imageSize75
            }
        }
    }
    var username: String = ""
    var urlname: String = ""
    var user_id: NSNumber = 0

    var created_at: NSNumber = 0
    var liked_at: NSNumber = 0
    var profile: Profile?
    var status: Status?
    var board_count: NSNumber = 0
    var boards_like_count: NSNumber = 0
    var commodity_count: NSNumber = 0
    var creations_count: NSNumber = 0
    var follower_count: NSNumber = 0
    var following_count: NSNumber = 0
    var like_count: NSNumber = 0
    var pin_count: NSNumber = 0
    
    var seq: NSNumber = 0
    var pins: [Pin]?
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["pins" : Pin.classForCoder()]
    }

}

class Profile: BaseModel {
    
    var location: String?
    var sex: String?
    var birthday: String?
    var job: String?
    var url: String?
    var about: String?
    var show_verification: String?
}

class Status: BaseModel {
    var emailvalid = false
    var newbietask: NSNumber?
    var lr: NSNumber?
    var invites: NSNumber?
    var share: String?
    var default_board: NSNumber?
}