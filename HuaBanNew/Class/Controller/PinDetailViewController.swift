//
//  PinDetailViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import MJRefresh

let ZODescriptionLabelMargin: CGFloat = 14.0;

class PinDetailViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout,ZOZolaZoomTransitionDelegate {
    var selectedView: UIView?
    var popSelectedView: UIView?
    
    var collectionView: UICollectionView!
    var lastOffsetY: CGFloat! = 0
    var isUserDrag = false
    var isUp: Bool! = false {
        didSet {
            self.hidesTabBar(isUp)
        }
    }

    var dataSource = [Pin]()
    var pin: Pin!
    var imageInfo: JTSImageInfo!
    let request = PinDetailRequest()
    let recommendRequest = PinRecommendRequest()
    var header: PinDetailHeaderView!
    var currentPage: Int = 0
    var imageView: UIImageView!
    var progressLayer: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置UI
        self.setupUI()
        
        // 网络请求
        self.setupNetWork()
        
        // Do any additional setup after loading the view.
    }
    
    func tapImage(sender: UIView) {
        // Create image info
        if imageInfo == nil {
            imageInfo = JTSImageInfo();
        }
        
        var imageV: UIImageView!

        if sender.isKindOfClass(UIView.classForCoder()) {
            imageV = sender as! UIImageView
        } else {
            imageV = self.imageView
        }
        
        imageInfo.image = imageV.image;
        imageInfo.referenceRect = imageV.frame;
        imageInfo.referenceView = imageV.superview;
        imageInfo.referenceContentMode = imageV.contentMode;
        imageInfo.referenceCornerRadius = imageV.layer.cornerRadius;
        
        // Setup view controller
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Scaled)
        
        // Present the view controller.
        imageViewer.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    
    func setupUI() {
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 2
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0

        //  设置collectionView的 四周的内边距
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);


        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView.frame.size.height += 49;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        self.view.addSubview(self.collectionView)
        
        self.collectionView.registerNib(UINib(nibName: "XHWaterCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHWaterCollectionCell")
        self.collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.setupHeader()
        
        self.configNav()
        
    }
    
    func setupHeader() {
        
        let width = CGFloat(pin.file!.width.floatValue)
        let height = CGFloat(pin.file!.height.floatValue)
        var curentHeight = kScreenWidth / width * height
        
        self.imageView = UIImageView()
        self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, curentHeight);
        self.imageView.userInteractionEnabled = true;
        let tap = UITapGestureRecognizer(target: self, action: "tapImage:")
        self.imageView.addGestureRecognizer(tap)
        
        // 进度条
        let lineHeight: CGFloat = 4
        let progressLayer = UIView()
        progressLayer.frame = CGRectMake(0, 0, self.imageView.frame.size.width, lineHeight);
        progressLayer.backgroundColor = UIColor.redColor();
        progressLayer.hidden = true;
        self.imageView.addSubview(progressLayer);
        self.progressLayer = progressLayer;

        self.imageView.downloadImageProgress(Url: NSURL(string: Safe.safeString(pin.file?.realKey(ImageType.max))), placeholder: (self.popSelectedView as! UIImageView).image, progress: {[weak self] (receivedSize, totalSize, progress) -> () in
            if (self?.progressLayer != nil && self!.progressLayer!.hidden) {
                self?.progressLayer?.hidden = false;
            }
            if (progress >= 0 && progress <= 1) {
                self?.progressLayer?.frame = CGRectMake(0, 0, self!.imageView.frame.width * progress, lineHeight);
            }
            }, success: {[weak self] (imageURL, image) -> () in
                self?.progressLayer?.hidden = true;
            }) {[weak self] (error) -> () in
                self?.progressLayer?.hidden = true;
        }
        
        var textH: CGFloat = 0
        if pin.raw_text?.length > 0 {
            textH = 10 + (pin.raw_text!.sizeWithFontAndWidth(UIFont.systemFontOfSize(14), maxWidth: kScreenWidth - 20).height)
        }
        
        header = self.loadNib("PinDetailHeaderView") as! PinDetailHeaderView
        header.backgroundColor = UIColor.whiteColor()
        header.frame = CGRectMake(0, curentHeight, kScreenWidth, 185 + textH)
        header.setClickPinHeaderViewClosure {[weak self] (model, index) -> Void in
            switch index {
            case 0: // source
                print("clickSource:" + "\(model.source)")
            case 1: // user
                let vc = self?.loadVCFromSB("MineViewController") as! MineViewController
                vc.user = model.user
                self?.navigationController?.pushViewController(vc, animated: true)
            case 2: // board
                let vc = BoardDetailViewController()
                vc.board = model.board
                self?.navigationController?.pushViewController(vc, animated: true)
            default: //comment
                print("clickComment:" + "\(model.pin_id)")
            }
        }
        header.setInfo(self.pin)
        curentHeight += 185 + textH
        
        (self.collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout).headerInset = UIEdgeInsetsMake(curentHeight, 0, 0, 0);
        self.collectionView.addSubview(imageView)
        self.collectionView.addSubview(header)
    }
    
    func setupNetWork() {
        
            self.request.pinId = pin.pin_id
        
            request.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
        
                    if self.request.resultPin != nil {
                        self.header.setInfo(self.request.resultPin!)
                    }
        
                    }) {[unowned self] (baseRequest, err) -> Void in
                        self.showError("加载失败")
        
                        print(err.localizedDescription)
        
                }
        
        self.loadData(1)
        
        self.collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(self!.currentPage + 1)
            self?.collectionView.mj_footer.endRefreshing()
        })
        (self.collectionView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
    }
    
    func configNav() {
        
        let likeBtn = UIButton(frame: CGRectMake(0,0,40,40))
        likeBtn.setImage(UIImage(named: "ic_navibar_like")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: UIControlState.Normal)
        likeBtn.setImage(UIImage(named: "ic_navibar_liked")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: UIControlState.Selected)
        
        likeBtn.addTarget(self, action: "onLike:", forControlEvents: UIControlEvents.TouchUpInside)
        let item1 = UIBarButtonItem(customView: likeBtn)
        
        let item2 = UIBarButtonItem(image: UIImage(named: "ic_navibar_download")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: "onSearch:")
        
        let item3 = UIBarButtonItem(image: UIImage(named: "btn_pin")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: "onSearch:")
        
        self.navigationItem.rightBarButtonItems = [item3, item2, item1]
    }
    
    func onSearch(sender: UIBarButtonItem) {
        print(sender.title)
    }
    
    func onLike(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    func loadData(page: Int){
        
        recommendRequest.page = page;
        recommendRequest.pinId = pin.pin_id
        recommendRequest.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            
            if self.recommendRequest.pinArray?.count > 0 {
                
                let lastItem = self.dataSource.count
                let indexPaths = (lastItem..<lastItem+self.recommendRequest.pinArray!.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                self.collectionView.performBatchUpdates({ () -> Void in
                    self.dataSource.appendContentsOf(self.recommendRequest.pinArray!)
                    self.collectionView.insertItemsAtIndexPaths(indexPaths)
                    
                    }, completion: { (finish) -> Void in
                        
                })
                
            } else {
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData
            }
            
            self.currentPage = page
            
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                
                print(err.localizedDescription)
        }
        
    }
    
    //MARK: - scroll
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isUserDrag = true
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isUserDrag = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.collectionView != scrollView || !isUserDrag {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        
        if lastOffsetY - offsetY > offsetChange && offsetY > offsetChangeBegin {
            if self.isUp == true {
                print("----------向下")
                self.isUp = false
            }
            lastOffsetY = offsetY
        } else if lastOffsetY - offsetY < -offsetChange && offsetY > offsetChangeBegin {
            if self.isUp == false {
                print("++++++++向上")
                self.isUp = true
            }
            lastOffsetY = offsetY
        }
    }
    

    
    //MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHWaterCollectionCell", forIndexPath: indexPath) as! XHWaterCollectionCell
        let model = self.dataSource[indexPath.row]
        cell.setInfo(model)
        cell.setCellActionClosure {[weak self] (sender) -> Void in
            let vc = BoardDetailViewController()
            vc.board = model.board
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? XHWaterCollectionCell
        self.selectedView = selectedCell?.photoImageView

        let frrr = self.view.convertRect(selectedCell!.frame, fromView:self.collectionView)
//        NSLog("%@---offY:%f", NSStringFromCGRect(frrr), self.collectionView.contentOffset.y);
        
        var point = self.collectionView.contentOffset;
        point.y -= self.collectionView.frame.size.height*0.5 - (frrr.origin.y+frrr.size.height*0.5);
        if (point.y < -64) {
            point.y = -64;
        }
        
        self.collectionView.setContentOffset(point, animated:true);
        
        let vc = PinDetailViewController()
        vc.pin = self.dataSource[indexPath.item]
        vc.popSelectedView = self.selectedView
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let model = self.dataSource[indexPath.row]
        return XHWaterCollectionCell.getSize(model)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ZOZolaZoomTransitionDelegate Methods
    // MARK: - UINavigationControllerDelegate Methods
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController, targetView: UIView?) -> UIViewControllerAnimatedTransitioning? {
        
        // Sanity
//        print("自己:\(fromVC.classForCoder)===目的\(toVC.classForCoder)")
        //
        if (fromVC != self && toVC != self)  {
            return nil;
        }
        
        let type = (operation == .Push) ? ZOTransitionType.Presenting : ZOTransitionType.Dismissing;
        
        if type == ZOTransitionType.Dismissing {
            self.collectionView.setContentOffset(CGPointMake(0, -64), animated: false)
        }
        
//        print("转场动画:\(type == ZOTransitionType.Presenting)")
        if targetView != nil {
            let zoomTransition = ZOZolaZoomTransition(
                targetView: targetView,
                type: type,
                duration: 0.5,
                delegate: self)
            
            zoomTransition.fadeColor = UIColor.whiteColor()
            
            return zoomTransition;
        }
        
        return nil;
    }
    
    // MARK: - ZOZolaZoomTransitionDelegate Methods
    func zolaZoomTransition(zoomTransition: ZOZolaZoomTransition!, startingFrameForView targetView: UIView!, relativeToView relativeView: UIView!, fromViewController: UIViewController!, toViewController: UIViewController!) -> CGRect {
        
        var rect = CGRectZero
        
        if zoomTransition.type == ZOTransitionType.Presenting {
            
            if fromViewController == self {
                let view = self.selectedView!
                rect = (view.convertRect(view.bounds, toView: relativeView))
            } else {
                let view = self.popSelectedView!
                rect = (view.convertRect(view.bounds, toView: relativeView))
            }
            
        } else {
            let view = (fromViewController as! PinDetailViewController).imageView
            rect = view.convertRect(view.bounds, toView: relativeView)
            
        }
        
        return rect;
    }
    
    func zolaZoomTransition(zoomTransition: ZOZolaZoomTransition!, finishingFrameForView targetView: UIView!, relativeToView relativeView: UIView!, fromViewController fromViewComtroller: UIViewController!, toViewController: UIViewController!) -> CGRect {
        
        var rect = CGRectZero
        
        if zoomTransition.type == ZOTransitionType.Presenting {
            
            let view = (toViewController as! PinDetailViewController).imageView
            
            rect = view.convertRect(view.bounds, toView: relativeView)
            
        } else {
            let view = self.popSelectedView!
            
            rect = view.convertRect(targetView.bounds, toView:relativeView)
        }
        
        return rect;
    }

    
    func supplementaryViewsForZolaZoomTransition(zoomTransition: ZOZolaZoomTransition!) -> [AnyObject]! {
        
        // Here we're returning all UICollectionViewCells that are clipped by the edge
        // of the screen. These will be used as "supplementary views" so that the clipped
        // cells will be drawn in their entirety rather than appearing cut off during the
        // transition animation.
        if zoomTransition.type == ZOTransitionType.Dismissing {
            return nil
        }
        
        var clippedCells = [UICollectionViewCell]()
        for visibleCell in self.collectionView.visibleCells() {
            let convertedRect = visibleCell.convertRect(visibleCell.bounds, toView:self.view);
            if (!CGRectContainsRect(self.view.frame, convertedRect)) {
                clippedCells.append(visibleCell)
            }
        }
        return clippedCells;
    }
    
    func zolaZoomTransition(zoomTransition: ZOZolaZoomTransition!, frameForSupplementaryView supplementaryView: UIView!, relativeToView relativeView: UIView!) -> CGRect {
        if zoomTransition.type == ZOTransitionType.Dismissing {
            return CGRectZero;
        }
        
        return supplementaryView.convertRect(supplementaryView.bounds, toView:relativeView)
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
