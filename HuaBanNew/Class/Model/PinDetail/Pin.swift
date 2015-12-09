//
//  Pin.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

//igm9c5t8
//http ://api.huaban.com/pins/511217303/recommend/?igm9c5t8&page=8&per_page=10&wfl=1

// 只有page有用 每页固定10条
//http://huaban.com/pins/511217211/relatedboards/
//http://huaban.com/pins/511217211/recommend/?igm9ovsi&page=1&per_page=10&wfl=1
//http://api.huaban.com/pins/511217211/recommend?page=1&per_page=10&wfl=1

import UIKit


class Pin: BaseModel {

    var hide_origin: Bool = false
    var liked: Bool = false

    var pin_id: NSNumber = 0
    var user_id: NSNumber = 0
    var file_id: NSNumber = 0
    var board_id: NSNumber = 0
    var seq: NSNumber = 0 // like的id

    var media_type: NSNumber = 0
    var source: String?
    var link: String?
    var raw_text: String?


    var via: NSNumber = 0
    var via_user_id: NSNumber = 0
    var original: NSNumber = 0
    var created_at: NSNumber = 0
    var repin_count: NSNumber = 0
    var like_count: NSNumber = 0
    var comment_count: NSNumber = 0
    
    var is_private: NSNumber = 0
    var orig_source: String?

    var text_meta: Text_Meta?
    var file: File?
    var user: User?
    var board: Board?
    var via_user: User?

    // 缓存
    var cellSize: CGSize?
    var fileHeight: CGFloat = 0
    var needUser: Bool = false

}