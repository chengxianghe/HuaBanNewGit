//
//  Global.swift
//  LoveLife
//
//  Created by chengxianghe on 15/9/6.
//  Copyright (c) 2015年 CXH. All rights reserved.
//

import UIKit
import Foundation

//MARK: - 替代oc中的#define, 列举一些常用宏

// 屏幕的物理宽度
let kScreenWidth = UIScreen.mainScreen().bounds.size.width
// 屏幕的物理高度
let kScreenHeight = UIScreen.mainScreen().bounds.size.height

let kStatusHeight =  UIApplication.sharedApplication().statusBarFrame.size.height

let kScreenSize = UIScreen.mainScreen().bounds.size

/**
*   除了一些简单的属性直接用常量表达,更推荐用全局函数来定义替代宏
*/
// 判断系统版本
func kIS_IOS7() ->Bool { return (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 }
func kIS_IOS8() -> Bool { return (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0 }

//MARK: - Color
/** RGBA的颜色设置 */
func kRGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

/** 0xFF0000的颜色设置 */
func kColorFromHexA (hex6: UInt32, alpha: CGFloat = 1) -> UIColor {
    let red     =   CGFloat((hex6 & 0xFF0000) >> 16) / 255.0
    let green   =   CGFloat((hex6 & 0x00FF00) >> 8)  / 255.0
    let blue    =   CGFloat((hex6 & 0x0000FF))       / 255.0
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

//MARK: - App沙盒路径
func kAppPath() -> String! {
    return NSHomeDirectory()
}
// Documents路径
func kBundleDocumentPath() -> String! {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
}
// Caches路径
func KCachesPath() -> String! {
    return NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
}

//MARK:- 延时
typealias Task = (cancel : Bool) -> ()
func delay(time:NSTimeInterval, task:()->()) ->  Task? {
    func dispatch_later(block:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(time * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            block)
    }
    var closure: dispatch_block_t? = task
    var result: Task?
    let delayedClosure: Task = {
        cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                dispatch_async(dispatch_get_main_queue(), internalClosure);
            }
        }
        closure = nil
        result = nil
    }
    result = delayedClosure
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(cancel: false)
        }
    }
    return result;
}

func cancel(task:Task?) {
    task?(cancel: true)
}

//MARK:- 通知
let kNotificationCenter = NSNotificationCenter.defaultCenter()

//MARK: - block
typealias kCellActionClosure = ((sender: AnyObject?) -> Void)
