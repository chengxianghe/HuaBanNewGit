//
//  UINavigation+Pop.m
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/1.
//  Copyright © 2015年 CXH. All rights reserved.
//

#import "UINavigation+Pop.h"
#import <objc/runtime.h>

static NSString *const kOriginDelegate = @"koriginDelegate";

@implementation UINavigationController (Pop)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        //customPop_viewDidLoad
        SEL originalSelectorViewDidLoad = @selector(viewDidLoad);
        SEL swizzledSelectorViewDidLoad = @selector(customPop_viewDidLoad);
        [self swizzledClass:class originalSelector:originalSelectorViewDidLoad swizzledSelector:swizzledSelectorViewDidLoad];

        SEL originalSelector = @selector(navigationBar:shouldPopItem:);
        SEL swizzledSelector = @selector(customPop_navigationBar:shouldPopItem:);
        
        [self swizzledClass:class originalSelector:originalSelector swizzledSelector:swizzledSelector];
                
    });
}

+ (void)swizzledClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector  {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Method Swizzling

- (void)customPop_viewDidLoad {
    
    [self customPop_viewDidLoad];
    
    objc_setAssociatedObject(self, [kOriginDelegate UTF8String], self.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
//    NSLog(@"%@", self.interactivePopGestureRecognizer.delegate);
    
    if (self.interactivePopGestureRecognizer.delegate != self) {
        self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>) self;
    }
    
}

- (BOOL)customPop_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    UIViewController *vc = self.topViewController;
    if (item != vc.navigationItem) {
        return true;
    }
    
//    NSLog(@"navigationBar shouldPopItem:: %@", self);
    
    if ([vc conformsToProtocol:@protocol(UINavigationControllerShouldPop)]) {
        if ([(id<UINavigationControllerShouldPop>)vc navigationControllerShouldPop:self]) {
            return [self customPop_navigationBar:navigationBar shouldPopItem:item];
        } else {
            return false;
        }
    } else {
        return [self customPop_navigationBar:navigationBar shouldPopItem:item];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    NSLog(@"navigationBar gestureRecognizerShouldBegin: %@", self);

    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        UIViewController *vc = self.topViewController;
        if ([vc conformsToProtocol:@protocol(UINavigationControllerShouldPop)]) {

            if ([(id<UINavigationControllerShouldPop>)vc navigationControllerShouldStartInteractivePopGestureRecognizer:self]) {
                return true;
            } else {
                return false;
            }
        }
        
        id<UIGestureRecognizerDelegate> originDelegate = objc_getAssociatedObject(self, [kOriginDelegate UTF8String]);
        
        return [originDelegate gestureRecognizerShouldBegin:gestureRecognizer];
        
    } else {
        return true;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate> originDelegate = objc_getAssociatedObject(self, [kOriginDelegate UTF8String]);
        return [originDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate> originDelegate = objc_getAssociatedObject(self, [kOriginDelegate UTF8String]);
        return [originDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];

    }
    
    return true;
}

@end