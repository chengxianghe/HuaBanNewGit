//
//  CategoryModel.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/3.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class CategoryModel: NSObject {
    
    var group: NSNumber = 0

    var es_id: String?

    var name: String?

    var nav_link: String?
    
    //MARK: - MJExtension ReplaceKey ["自己的key" : "网络的key"]
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["es_id" : "id"]
    }
    
}

//{"id":"home","name":"家居/装饰","group":0,"nav_link":"/favorite/home/"}