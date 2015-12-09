//
//  FocusViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/10/27.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout
class FocusViewController: BaseViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
//    var scrollView:UIScrollView!
    var navScrollView:UIScrollView!
    var navPageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let lab1 = UILabel(frame: CGRectMake(0, 7, 150, 30))
        lab1.text = "关注的采集"
        lab1.textColor = UIColor.blackColor()

        lab1.textAlignment = .Center
        let lab2 = UILabel(frame: CGRectMake(150, 7, 150, 30))
        lab2.text = "关注的画板"
        lab2.textColor = UIColor.blackColor()
        lab2.textAlignment = .Center
        
        navScrollView = UIScrollView(frame: CGRectMake(0,0,150,44))
        navScrollView.addSubview(lab1)
        navScrollView.addSubview(lab2)
        navScrollView.showsHorizontalScrollIndicator = false
        navScrollView.showsVerticalScrollIndicator = false
        navScrollView.contentSize = CGSizeMake(300, 0);
        navScrollView.pagingEnabled = true
        navScrollView.userInteractionEnabled = false
        
        
        let titleView = UIView(frame: CGRectMake(0,0,150,44))
        titleView.addSubview(navScrollView)
        
        navPageControl = UIPageControl(frame: CGRectMake(0,35,150,4))
        navPageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        navPageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        navPageControl.numberOfPages = 2
        titleView.addSubview(navPageControl)
        
        self.navigationItem.titleView = titleView

        
        let myFocusVC = MyFocusViewController()        
        let myPinVC = MyPinViewController()
        
        // SL 并没有 强引用 控制器 所以需要强引用一下
        self.addChildViewController(myFocusVC)
        self.addChildViewController(myPinVC)
        
        
        
        scrollView.contentSize = CGSizeMake(kScreenWidth * 2, 0);
        scrollView.pagingEnabled = true
        myPinVC.view.frame = scrollView.bounds
        scrollView.addSubview(myPinVC.view)
        myFocusVC.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight-64)
        scrollView.addSubview(myFocusVC.view)

        
        scrollView.delegate = self
    }
    
     func scrollViewDidScroll(scrollView: UIScrollView) {

        if scrollView == self.scrollView {
            navScrollView.contentOffset.x = scrollView.contentOffset.x/scrollView.frame.width * navScrollView.frame.width
            let index = Int((scrollView.contentOffset.x + scrollView.frame.width * 0.5)/scrollView.frame.width)
            
            navPageControl.currentPage = index
            
            navScrollView.subviews[0].alpha = (navScrollView.frame.width - navScrollView.contentOffset.x)/navScrollView.frame.width
            navScrollView.subviews[1].alpha = (navScrollView.contentOffset.x)/navScrollView.frame.width

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

