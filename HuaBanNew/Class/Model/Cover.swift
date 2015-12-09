//
//  Cover.swift
//  SVProgressHUD
//
//  Created by chengxianghe on 15/11/05
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

import UIKit

class Cover: BaseModel {

    var pin_id: String?
    //hbfile // hbimg
    var bucket: String?

    var key: String? {
        didSet {
            if key != nil {
                key = baseImage + key!
            }
        }
    }


}