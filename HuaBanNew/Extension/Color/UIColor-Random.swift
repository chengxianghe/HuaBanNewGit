//
//  UIColor-Random.swift
//  ScrollMenu
//
//  Created by zn on 15/7/17.
//  Copyright © 2015年 zn. All rights reserved.
//

import UIKit

extension UIColor {
    //获取随机颜色
   class func randomColor() ->UIColor {
        let randomRed = CGFloat(arc4random_uniform(256))
        let randomGreen = CGFloat(arc4random_uniform(256))
        let randomBlue = CGFloat(arc4random_uniform(256))
       return UIColor(red: randomRed/255.0, green: randomGreen/255.0, blue: randomBlue/255.0, alpha: 1.0)
    }


}
