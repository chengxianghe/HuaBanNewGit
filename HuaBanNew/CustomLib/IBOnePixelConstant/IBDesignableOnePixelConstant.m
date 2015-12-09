//
//  IBDesignableOnePixelConstant.m
//  GMBuy
//
//  Created by chengxianghe on 15/11/16.
//  Copyright © 2015年 cn. All rights reserved.
//

#import "IBDesignableOnePixelConstant.h"

@implementation IBDesignableOnePixelConstant

- (void)setOnePixelConstant:(NSInteger)onePixelConstant {
    _onePixelConstant = onePixelConstant;
    self.constant = onePixelConstant * 1.0 / [UIScreen mainScreen].scale;
}

@end
