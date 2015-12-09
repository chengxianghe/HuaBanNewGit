//
//  ScrollPageView.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/2.
//  Copyright © 2015年 CXH. All rights reserved.
//

/*

改控件 用 performSelector afterDelay 实现 (也可以用 NSTimer 实现)

//用nstimer的用法 一种用法，要手动加入到NsRunLoop中
NSTimer *time= [NSTimer timerWithTimeInterval:3 target:self selector:@selector(NoticeTransation) userInfo:nil repeats:YES];
[[NSRunLoop currentRunLoop] addTimer:time forMode:NSDefaultRunLoopMode];//手动加入到NSRunLoop中
[time fire];//立即触发定时器

*/

import UIKit

/**
 *  配置Label
 */
typealias ScrollPageViewLabelConfig = (pageView: ScrollPageView, label: UILabel) -> Void
typealias ScrollPageViewCustomSetInfoConfig = (pageView: ScrollPageView, index: NSInteger) -> Void

typealias ScrollPageViewWillScrollToIndex = (pageView: ScrollPageView, from: NSInteger, to: NSInteger) -> Void
typealias ScrollPageViewDidSelectIndex = (pageView: ScrollPageView, index: NSInteger) -> Void


class ScrollPageView : UIView, UIScrollViewDelegate {
    
    /** 加载网络图片时的默认图片 */
    var placeholderImage: UIImage?
    var titles: [String]?           // 标题数组
    
    private var selectClosure :ScrollPageViewDidSelectIndex? // 选中配置
    private var willScrollToIndexClosure :ScrollPageViewWillScrollToIndex? // 即将展示配置
    private var labelConfigClosure: ScrollPageViewLabelConfig?   //label配置
    private var customSetInfoClosure :ScrollPageViewCustomSetInfoConfig? // 设置自定义信息展示

    private var autoPlay: Bool?
    private var timeInterval: NSTimeInterval! = 0.3
    private var pageControl: UIPageControl!
    private var scrollView: UIScrollView!
    private var titleLabel: UILabel?
    private var imagesCount: NSInteger = 0       // 实际的图片数量
    private var currentIndex = 0      // 计数器 用于计算
    
    // 自己的图片数组
    private var imageArray: NSArray! {
        didSet {
            if self.imageArray.count < 3 {
                // 这里 防止少于3张图的时候异常
                if self.imageArray.count == 1 {
                    self.imageArray = [imageArray[0],imageArray[0],imageArray[0]];
                } else if self.imageArray.count == 2 {
                    self.imageArray = [imageArray[0],imageArray[1],imageArray[0],imageArray[1]];
                }
            }
            
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /** images可传string image */
    convenience init(frame: CGRect, images: NSArray, titles: [String]?, autoPlay isAuto: Bool, delay timeInterval: NSTimeInterval, showPageControl: Bool, configLabel labelConfig: ScrollPageViewLabelConfig?) {
        self.init(frame: frame)
        
        self.autoPlay = isAuto;
        self.timeInterval = timeInterval;
        //        self.images = images;
        if (images.count == 0) {
            print("Error: ScrollPageView imagesCount can not be 0!")
            return
        }
        self.imageArray = images
        self.imagesCount = images.count;
        self.titles = titles;
        self.labelConfigClosure = labelConfig;

        self.addScrollView()
        self.addLabel()
        self.addPageControl()
        
        self.pageControl.hidden = !showPageControl
        
        self.refreshImages()
        
        if (self.autoPlay == true) {
            self.toPlay()
        }
    }
    
    convenience init(frame: CGRect, images: NSArray, autoPlay isAuto: Bool, delay timeInterval: NSTimeInterval, showPageControl: Bool, customView: UIView!, customInfoConfig infoConfig: ScrollPageViewCustomSetInfoConfig!) {
        self.init(frame: frame)
        
        self.autoPlay = isAuto;
        self.timeInterval = timeInterval;
        //        self.images = images;
        if (images.count == 0) {
            print("Error: ScrollPageView imagesCount can not be 0!")
            return
        }
        self.imageArray = images
        self.imagesCount = images.count;
        self.customSetInfoClosure = infoConfig;
        
        self.addScrollView()

        self.addSubview(customView)
        
        self.addPageControl()
        self.pageControl.hidden = !showPageControl

        self.refreshImages()
        
        if (self.autoPlay == true) {
            self.toPlay()
        }
    }

    
    //MARK: - Public Methods
    func setScrollPageViewDidSelectIndex(select: ScrollPageViewDidSelectIndex) {
        selectClosure = select
    }
    func setScrollPageViewWillScrollToIndex(willScroll: ScrollPageViewWillScrollToIndex) {
        willScrollToIndexClosure = willScroll
    }
    
    //MARK: - Private Methods
    private func toPlay() {
        self.performSelector("autoPlayToNextPage", withObject: nil, afterDelay: timeInterval)
    }
    
    func autoPlayToNextPage() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "autoPlayToNextPage", object: nil)
        
        let view = self.scrollView.subviews[1]
        
        // Cube动画 苹果 私有api
//        let animation = CATransition()
//        animation.delegate = self;
//        animation.duration = 0.8;
//        animation.type = "cube";
//        animation.subtype = "fromRight";
//        animation.startProgress = 0.0;
//        animation.endProgress = 1.0;
//        animation.removedOnCompletion = true;
//        view.layer.addAnimation(animation, forKey: "animation")
//
//        self.scrollView.setContentOffset(CGPointMake(self.frame.size.width * 2, 0), animated: false)

        //设置动画
        let option = UIViewAnimationOptions(rawValue: UIViewAnimationOptions.AllowUserInteraction.rawValue | UIViewAnimationOptions.TransitionCurlDown.rawValue | UIViewAnimationOptions.CurveEaseInOut.rawValue)
        
        UIView.transitionWithView(
            view,
            duration: 1,
            options: option,
            animations: { () -> Void in
                self.scrollView.contentOffset = CGPointMake(self.frame.size.width * 2, 0)
            }) { (finish) -> Void in
                self.performSelector("autoPlayToNextPage", withObject: nil, afterDelay: self.timeInterval)

        }
        
//        // 普通动画的
//        self.scrollView.setContentOffset(CGPointMake(self.frame.size.width * 2, 0), animated: true)
//        self.performSelector("autoPlayToNextPage", withObject: nil, afterDelay: self.timeInterval)


    }
    
//    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
//        if flag {
//            self.performSelector("autoPlayToNextPage", withObject: nil, afterDelay: self.timeInterval)
//        }
//        
//    }
    
    private func addPageControl() {
        
        let bgView = UIView(frame: CGRectMake(0, bounds.height-20, bounds.width, 20))
        //    bgView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.2];
        bgView.backgroundColor = UIColor.clearColor()
        pageControl = UIPageControl(frame: CGRectMake(0, 0, bounds.width, 20))
        pageControl.numberOfPages = self.imagesCount;
        pageControl.currentPage = 0;
        pageControl.userInteractionEnabled = false;
        
        bgView.addSubview(pageControl)
        self.addSubview(bgView)
    }
    
    private func addLabel() {
        
   
            titleLabel = UILabel(frame: CGRectMake(0, bounds.height-40, bounds.width, 40))
            titleLabel!.backgroundColor = UIColor(white: 0.3, alpha: 0.6)
            labelConfigClosure?(pageView: self, label: titleLabel!)
            self.addSubview(titleLabel!)
    }
    
    private func addScrollView() {
        
        scrollView = UIScrollView(frame: self.bounds)
        
        let width = self.frame.size.width;
        let height = self.frame.size.height;
        
        
        for (var i = 0; i < 3; i++) {
            let imageView = UIImageView(frame: CGRectMake(CGFloat(i) * width, 0, width, height))
            
            imageView.contentMode = UIViewContentMode.ScaleAspectFill;
            scrollView.addSubview(imageView)
        }
        
        
        
        scrollView.contentSize = CGSizeMake(3*width, height);
        scrollView.contentOffset = CGPointMake(width, 0);
        scrollView.pagingEnabled = true;
        //这里一定得设置，不然用来计算的scrollview的subviews这个数值不对
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.delegate = self;
        
        let tap = UITapGestureRecognizer(target: self, action: "singleTapped:")
        scrollView.addGestureRecognizer(tap)
        self.addSubview(scrollView)
    }
    
    private func setImageView(imageView: UIImageView, WithIndex i: NSInteger) {
        // 没有设置默认图 用自带的设置
        if (self.placeholderImage == nil) {
            self.placeholderImage = UIImage(named: "image_default")
        }
        
        if self.imageArray[i].isKindOfClass(NSString.classForCoder()) {
            if self.imageArray[i].hasPrefix("http") {
                
                if self.imageArray[i].hasPrefix("https") {
                    imageView.sd_setImageWithURL(NSURL(string: self.imageArray[i] as! String), placeholderImage: self.placeholderImage)
                } else {
                    imageView.sd_setImageWithURL(NSURL(string: self.imageArray[i] as! String), placeholderImage: self.placeholderImage)
                }
                
            } else {
                imageView.image = UIImage(named: self.imageArray[i] as! String)
            }
        } else if (self.imageArray[i].isKindOfClass(UIImage.classForCoder())){
            imageView.image = self.imageArray[i] as? UIImage
        } else {
            imageView.image = nil
        }
    }
    
    
    /**
     // MARK: - 规律在此
     
     // 从这里动画就可以看出来 其实展示的一直都是中间那张 不论向前还是向后 都会在 朝向滚动结束后 滚回当中, 这个时候 刷新三张 imageView 的内容
     // 要做的关键 就是 控制 三张 imageView 的内容
     //比如 一共5张图 图片 往左 滚动
     
     // 左 中 右 loopCount
     //    *      *
     // 2  0  1   0
     // 0  1  2   1
     // 1  2  3   2
     // 2  3  4   3
     // 3  4  0   4
     // 4  0  1   0 currentIndex == count = 0 此处图片开始重复循环
     // 0  1  2   1
     // 1  2  3   2
     
     // 计算 公式:
     // 左 = (currentIndex - 1 + count(5)) % count(5)
     // 中 =  currentIndex
     // 右 = (currentIndex + 1) % count(5)
     */
    private func refreshImages() {
        
        // 这里就是 控制 滚回当中的 代码, 这里不能用动画(会暴露)
        self.scrollView.setContentOffset(CGPointMake(self.frame.size.width, 0), animated: false)
        
        // 这里就是 刷新三张 imageView 的内容的 代码
        // 加上count 防止为负数
        let left = (self.currentIndex - 1 + self.imageArray.count) % self.imageArray.count;
        let middle = self.currentIndex % self.imageArray.count
        let right = (self.currentIndex + 1) % self.imageArray.count;
        
//        print(self.currentIndex, self.imageArray.count)
//        print(left,middle,right)
        
        self.configAdView(self.scrollView.subviews[0] as! UIImageView, WithIndex:left);
        self.configAdView(self.scrollView.subviews[1] as! UIImageView, WithIndex:middle);
        self.configAdView(self.scrollView.subviews[2] as! UIImageView, WithIndex:right);
        
        // 设置 pageControl.currentPage
        if self.imagesCount < 3 {
            if self.imagesCount == 1 {
                self.pageControl.currentPage = 0;
            } else {
                self.pageControl.currentPage = middle % 2;
            }
        } else {
            self.pageControl.currentPage = middle;
        }
        
        //MARK: - 填充title
        if self.customSetInfoClosure != nil {
            self.customSetInfoClosure!(pageView: self, index: self.pageControl.currentPage)
        } else {

            let i = self.pageControl.currentPage
            
            if i < self.titles?.count {
                titleLabel?.hidden = false;
                titleLabel?.text = self.titles?[i]
            } else {
                titleLabel?.hidden = true
            }
        }
    }
    
    
    private func configAdView(imageView: UIImageView, WithIndex index: NSInteger) {
        self.setImageView(imageView, WithIndex: index)
    }
    
    //MARK: - delegate
    func singleTapped(recognizer: UITapGestureRecognizer) {
        
        if self.selectClosure != nil {
            // 因为考虑到 少于三张的情况  所以 currentIndex 并不准确
            self.selectClosure!(pageView: self, index: self.pageControl.currentPage)
        }
    }
    
    // 经常调用
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.x;
        let width = self.frame.size.width;
        
        // -> 即将展示第3个imageView
        if (x >= 2 * width) {
            self.currentIndex++;
            if (self.currentIndex == self.imagesCount) {
                self.currentIndex = 0;
            }
            
            var to = self.pageControl.currentPage + 1
            if to == self.imagesCount {
                to = 0
            }
            
            self.willScrollToIndexClosure?(pageView: self, from: self.pageControl.currentPage, to: to)
            
            self.refreshImages()
        }
        // <- 即将展示第1个imageView
        if (x <= 0) {
            // 第一次向左会出现问题 做一下保护
            if (self.currentIndex == 0) {
                self.currentIndex = self.imagesCount;
            }
            
            self.currentIndex--;
            
            if (self.currentIndex == 0) {
                self.currentIndex = self.imagesCount;
            }
            
            var to = self.pageControl.currentPage - 1
            
            if self.pageControl.currentPage == 0 {
                to = self.imagesCount - 1
            }
            
            self.willScrollToIndexClosure?(pageView: self, from: self.pageControl.currentPage, to: to)
            
            self.refreshImages()
        }
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        // 用户开始拖动 取消自动轮播
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "autoPlayToNextPage", object: nil)
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // 用户开始结束拖动 开始自动轮播 计时时间重置
        self.toPlay()
    }
    
    // 快的时候不会调用 减速结束方法 为了提升性能 应尽可能在此处处理逻辑
    //    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    //        scrollView.setContentOffset(CGPointMake(self.frame.size.width, 0), animated: true)
    //    }
    
}
