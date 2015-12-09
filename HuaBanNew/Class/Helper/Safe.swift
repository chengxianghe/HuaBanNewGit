//
//  Safe.swift
//  JokeMusic
//
//  Created by chengxianghe on 15/10/16.
//  Copyright © 2015年 CXH. All rights reserved.
//

import Foundation

class Safe {
    static func safeNSNumber(num: NSNumber?) -> NSNumber {
        if num != nil {
            return num!
        } else {
            return NSNumber(int: 0)
        }
    }
    
    static func safeString(str: String?) -> String {
        if str != nil {
            return str!
        } else {
            return ""
        }
    }
    
    static func safeFloatValue(str: String?) -> Float {
        if str != nil {
            return (str! as NSString).floatValue
        } else {
            return 0
        }
    }
    
    static func safeIntValue(str: String?) -> Int {
        if str != nil {
            return (str! as NSString).integerValue
        } else {
            return 0
        }
    }
}

