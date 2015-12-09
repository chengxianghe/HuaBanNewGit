//
//  BaseViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/10/27.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout
import SDWebImage

class BaseViewController: UIViewController,UINavigationControllerShouldPop,UIGestureRecognizerDelegate {

    deinit {
        print("*** deinit *** base:\(self.classForCoder)")
    }
    
    func navigationControllerShouldPop(navigationController: UINavigationController!) -> Bool {
        print("\(self.classForCoder) + 点击 pop")
        return true;
    }
    
    func navigationControllerShouldStartInteractivePopGestureRecognizer(navigationController: UINavigationController!) -> Bool {
        print("\(self.classForCoder) + 手势 pop")
        return true;
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController != nil {
            return self.navigationController!.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        let mgr = SDWebImageManager.sharedManager()
        
        // 1.取消下载
        mgr.cancelAll()
        
        // 2.清除内存中的所有图片
        mgr.imageCache.clearMemory()
        
//        self.clearCache()
    }
}
