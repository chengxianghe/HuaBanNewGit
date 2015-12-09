//
//  Covers.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class Covers: BaseModel {

    var raw_text: String?

    var media_type: NSNumber = 0

    var source: String?

    var link: String?

    var pin_id: NSNumber = 0

    var user_id: NSNumber = 0

    var file: File?

    var repin_count: NSNumber = 0

    var like_count: NSNumber = 0

    var file_id: NSNumber = 0

    var via_user: User?

    var original: NSNumber = 0

    var orig_source: String?

    var via: NSNumber = 0

    var user: User?

    var text_meta: Text_Meta?

    var board: Board?

    var created_at: NSNumber = 0

    var via_user_id: NSNumber = 0

    var board_id: NSNumber = 0

    var comment_count: NSNumber = 0

    var is_private: NSNumber = 0


}