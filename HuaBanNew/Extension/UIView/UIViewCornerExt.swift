//
//  UIViewCornerExt.swift
//  JokeMusic
//
//  Created by chengxianghe on 15/10/16.
//  Copyright © 2015年 CXH. All rights reserved.
//

import Foundation
import UIKit

//IB_DESIGNABLE//声明类是可设计的， 此处测试无效，分类应该不能实现

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get{
           return self.cornerRadius
        }
        
        set{
            self.layer.cornerRadius = newValue;
            self.layer.masksToBounds = newValue > 0;
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get{
            return self.layer.borderWidth
        }
        
        set{
            self.layer.borderWidth = newValue
        }

    }
    
    @IBInspectable var borderColor: UIColor {
        get{
            return UIColor(CGColor: self.layer.borderColor!)
        }
        
        set{
            self.layer.borderColor = newValue.CGColor
        }
        
    }
    
    @IBInspectable var isOnePx: Bool {
        get{
            return self.isOnePx
        }
        
        set{
            if newValue == true {
                let oneScale =  1.0 / UIScreen.mainScreen().scale
                self.layer.borderWidth = oneScale * borderWidth
            } else {
                self.layer.borderWidth = borderWidth
            }
        }
        
    }
    
    
    func addCorner(cornerRadius: CGFloat, borderWidth: CGFloat = 1, borderColor: UIColor = UIColor.whiteColor(), isOnePx: Bool = false) {
        
        self.layer.masksToBounds = cornerRadius > 0;

        self.layer.cornerRadius = cornerRadius;
        self.layer.borderColor = borderColor.CGColor
        
        if isOnePx == true {
            let oneScale =  1.0 / UIScreen.mainScreen().scale
            self.layer.borderWidth = oneScale * borderWidth
        } else {
            self.layer.borderWidth = borderWidth
        }

    }
}