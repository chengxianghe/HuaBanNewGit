//
//  Size.swift
//  LoveLife
//
//  Created by chengxianghe on 15/8/28.
//  Copyright (c) 2015年 CXH. All rights reserved.
//

import UIKit

class Size {
    
    static func sizeWithText(text: String?, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrs: Dictionary = [NSFontAttributeName: font]
        
        let rect = text?.boundingRectWithSize(maxSize, options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        if rect != nil  {
            return rect!.size;
        }
        
        return CGSizeZero;
    }
    
    static func heightWithText(text: String?, font: UIFont, maxWidth: CGFloat) -> CGFloat {
        return ceil(Size.sizeWithText(text, font: font, maxSize:CGSizeMake(maxWidth, CGFloat.max)).height)
    }
    
    static func heightWithMaxLines(text: String?, font: UIFont, maxWidth: CGFloat, maxLines: Int) -> CGFloat {
        // 单行高度
        let oneLineHeight = sizeWithText("单行高度", font: font, maxSize: CGSizeMake(CGFloat.max, CGFloat.max)).height
        
        // 最大允许高度
        let maxHeight = CGFloat(maxLines) * oneLineHeight;
        
        // 计算应得的高度
        let shouldHeight = self.heightWithText(text, font: font, maxWidth: maxWidth)
        
        // 确定实际返回的高度
        return shouldHeight > maxHeight ? maxHeight : shouldHeight;
    }
    
    static func isNeedFoldWithText(text: String?, font: UIFont, maxWidth: CGFloat, maxLines: Int) -> Bool {
        // 单行高度
        let oneLineHeight = sizeWithText("单行高度", font: font, maxSize: CGSizeMake(CGFloat.max, CGFloat.max)).height
        // 最大允许高度
        let maxHeight = CGFloat(maxLines) * oneLineHeight;
        
        // 计算应得的高度
        let shouldHeight = Size.heightWithText(text, font: font, maxWidth: maxWidth)
        
        // 确定实际返回的高度
        return shouldHeight > maxHeight;
    }
}

extension String {
    func sizeWithFontAndWidth(font: UIFont, maxWidth: CGFloat) -> CGSize {
        return Size.sizeWithText(self, font: font, maxSize: CGSizeMake(maxWidth, CGFloat.max))
    }
}

extension NSString {
    func sizeWithFontAndWidth(font: UIFont, maxWidth: CGFloat) -> CGSize {
        return (self as String).sizeWithFontAndWidth(font, maxWidth: maxWidth)
    }
}