//
//  AppDelegate.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/11/29.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import SDWebImage


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.configTabBar()
        self.configNavBar()
        
        let tabVC = self.window?.rootViewController as! UITabBarController
        tabVC.selectedIndex = 1
        
        self.configSDWebImage()
                
        self.configThirdBugRecored()
        
        return true
    }
    
    func configTabBar() {
        let tab = UITabBar.appearance()
        tab.tintColor = UIColor.redColor()
        
        if tab.items != nil {
            for item in tab.items! {
                // 保持tabBarItem 原来的图片色
                item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
                item.selectedImage = item.selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        //        tab.translucent = false
        
    }
    
    func configNavBar() {
        let navBar = UINavigationBar.appearance()
        navBar.tintColor = UIColor.redColor()
        //        navBar.translucent = false
    }
    
    func configSDWebImage() {
        // sd 防止 gif 图 暴涨内存
        SDImageCache.sharedImageCache().shouldDecompressImages = false
        SDWebImageDownloader.sharedDownloader().shouldDecompressImages = false
        
        // sd 设置缓存
        SDImageCache.sharedImageCache().maxCacheAge = 3600*24*7 // 一周
        //        SDImageCache.sharedImageCache().maxCacheSize = 1024*1024*200 // 200M
        SDImageCache.sharedImageCache().maxMemoryCountLimit = 100 //最多100张
        //        SDImageCache.sharedImageCache().maxMemoryCost = 10000 // 最多存储的像素数量
        
    }
    
    //MARK: - 第三方bug反馈和crash上报
    func configThirdBugRecored() {
        //BugTags
        Bugtags.startWithAppKey(kBugAppKey, invocationEvent: BTGInvocationEventBubble)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

