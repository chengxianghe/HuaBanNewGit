//
//  ControllerExt.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/8.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func loadNib(nibName: String!) -> AnyObject? {
        return NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil).first
    }
    
    func loadVCFromSB(vc: String!, stroyBoard: String? = nil) -> UIViewController? {
        
        var sb = stroyBoard == nil ? self.storyboard : UIStoryboard(name: stroyBoard!, bundle: nil)
        
        if sb == nil {
            sb = UIStoryboard(name: "Main", bundle: nil)
        }
        
        let vc = sb?.instantiateViewControllerWithIdentifier(vc)
        
        return vc

    }
    
    func hidesTabBar(isHidden: Bool) {
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        if self.tabBarController?.view.subviews == nil {
            return;
        }
        
        for view in (self.tabBarController?.view.subviews)! {
            
            if view.isKindOfClass(UITabBar.classForCoder()) {
                if (isHidden) {
                    view.frame = CGRectMake(view.frame.origin.x, UIScreen.mainScreen().bounds.size.height, view.frame.size.width , view.frame.size.height)
                    
                }else{
                    view.frame = CGRectMake(view.frame.origin.x, UIScreen.mainScreen().bounds.size.height - 49, view.frame.size.width, view.frame.size.height)
                    
                }
            }else{
                if view.isKindOfClass(NSClassFromString("UITransitionView")!) {
                    if (isHidden) {
                        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width ,  UIScreen.mainScreen().bounds.size.height)
                        
                    }else{
                        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, UIScreen.mainScreen().bounds.size.height - 49 )
                        
                    }
                }
            }
        }
        
        UIView.commitAnimations()
        
    }
    
}
