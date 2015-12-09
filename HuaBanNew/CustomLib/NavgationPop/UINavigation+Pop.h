//
//  UINavigation+Pop.h
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/1.
//  Copyright © 2015年 CXH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UINavigationControllerShouldPop <NSObject>

- (BOOL)navigationControllerShouldPop:(UINavigationController *)navigationController;

- (BOOL)navigationControllerShouldStartInteractivePopGestureRecognizer:(UINavigationController *)navigationController;

@end

@interface UINavigationController (Pop)<UIGestureRecognizerDelegate>

@end
