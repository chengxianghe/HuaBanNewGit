//
//  BoardDetailViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout

class BoardDetailViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout {
    
    var collectionView: UICollectionView!
    let request = BoardDetailRequest()
    let recommendRequest = BoardRecommendRequest()
    var board: Board!
    var boardHeader: BoardHeaderView!
    var currentPage: Int = 0
    var lastOffsetY: CGFloat! = 0
    var isUserDrag = false
    var isUp: Bool! = false {
        didSet {
            self.hidesTabBar(isUp)
        }
    }
    
    var dataSource = [Pin]() {
        didSet {
            
            let lastItem = oldValue.count
            
            //只刷新增加的数据，不能用reloadData，会造成闪屏
            if self.dataSource.count > lastItem {
                let indexPaths = (lastItem..<self.dataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
            } else { // headerRefresh
                self.collectionView.reloadData()
            }
            
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.request.cancelRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = board.title
        
        // 设置UI
        self.setupUI()
        
        self.setupNetWork()
        
        // Do any additional setup after loading the view.
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
        self.collectionView.registerNib(UINib(nibName: "XHWaterCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHWaterCollectionCell")
        self.collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        
        let headH = BoardHeaderView.getHeight(self.board)
        boardHeader = self.loadNib("BoardHeaderView") as! BoardHeaderView
        boardHeader.frame = CGRectMake(10, 10, self.view.bounds.width - 20, headH)
        boardHeader.setCellAction {[weak self] (sender) -> Void in
            let vc = self?.loadVCFromSB("MineViewController") as! MineViewController
            if self?.board.user != nil {
                vc.user = self?.board.user
            } else {
                vc.userId = self?.board.user_id
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        boardHeader.setOnShareAction {[weak self] (sender) -> Void in
            // 点击了分享
            print(" 点击了分享")
            self?.setShareToThird()
        }
        
        
        layout.headerInset = UIEdgeInsetsMake(headH+10, 0, 0, 0)
        collectionView.addSubview(boardHeader)
        
        self.configNav()
        
    }
    
    func setShareToThird() {
        
        let title = "花瓣的分享";
        let url = "http://10.125.2.43/webApp/group/group_home.php?imId=b_663&groupId=135491230233526300";
//        let imageUrl = "http://115.182.236.41/v1/img/T1daATBmVT1RXrhCrK.jpg"
        let describ = "我就是想试一下行不行?";
        let selectedCell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? XHWaterCollectionCell
        let image = selectedCell?.photoImageView.image
        
        if image == nil {
            return
        }
        
        let shareUrl = NSURL(string: url)
        let arr = [WeiXinSessionActivity(),WeiXinTimelineActivity(),WeiXinFavoriteActivity()];
        let activitys: [WeiXinBaseActivity] = arr.map { (item) -> WeiXinBaseActivity in
            item.shareDescription = describ
            item.title = title
            return item
        }
        let thumbImageData = ShareManager.scaleImageDataForSize(image!, limitDataSize: 30000);
        
        let activityViewController = UIActivityViewController(activityItems: [shareUrl!, thumbImageData!, title], applicationActivities: activitys)
        
        activityViewController.excludedActivityTypes = [UIActivityTypeMail]
        self.presentViewController(activityViewController, animated: true) {
            print("activity")
        }
        
//        ShareManager.manager().showShareViewWithBlock({ (type) -> () in
//            if type == nil {
//                return;
//            }
//            let title = "花瓣的分享";
//            let url = "http://10.125.2.43/webApp/group/group_home.php?imId=b_663&groupId=135491230233526300";
//            let imageUrl = "http://115.182.236.41/v1/img/T1daATBmVT1RXrhCrK.jpg"
//            let describ = "我就是想试一下行不行?";
//            let selectedCell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? XHWaterCollectionCell
//            let image = selectedCell?.photoImageView.image
//            
//            
//            switch (type!) {
//            case .WeiBoShare:
//                print("分享到新浪微博");
//                
//                SinaShareHelp.currentHelp().shareText(title, shareImage: image, url: url)
//                
//            case .WeiXinFriendsShare:
//                print("分享到朋友圈");
//                //    weixin
//                WeiXinShareHelp.currentHelp().sendLinkURL(url, title: title, description: describ, thumbImage: image, InScene: WXSceneTimeline)
//            case .WeiXinShare:
//                print("分享到微信好友");
//                WeiXinShareHelp.currentHelp().sendImageData(image, InScene: WXSceneSession)
//            case .WeiXinFavoriteShare:
//                print("分享到微信收藏");
//                WeiXinShareHelp.currentHelp().sendImageData(image, InScene: WXSceneFavorite)
//            case .QZoneShare:
//                print("分享到QQ空间");
//                QQShareHelp.currentHelp().sendLinkUrl(title, description: describ, imageUrl: imageUrl, url: url)
//            case .QQShare:
//                print("分享到QQ");
//                QQShareHelp.currentHelp().sendImage(image, title: title, desc: describ)
//            }
//        
//        })
        
    }
    
    func configNav() {
        
        // 搜索
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关注", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BoardDetailViewController.onFollow(_:)))
    }
    
    func onFollow(sender: UIBarButtonItem) {
        print(sender.title)
    }
    
    //MARK: - 刷新
    func setupNetWork() {
        
        self.loadData(1)
        
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(1)
            })
        
        self.collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(self!.currentPage + 1)
            })
        
        (self.collectionView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.collectionView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
    }
    
    //MARK: - 数据请求
    func loadData(page: Int){
        
        if page == 1 {
            request.boardId = board.board_id
            request.requestWithRequestOption(.None, sucess: {[unowned self] (baseRequest) -> Void in
                if self.request.resultBoard != nil {
                    self.board = self.request.resultBoard
                    self.boardHeader.setInfo(self.board)
                    let headH = BoardHeaderView.getHeight(self.board)
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.boardHeader.frame = CGRectMake(10, 10, kScreenWidth - 20, headH)
                        (self.collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout).headerInset = UIEdgeInsetsMake(headH+10, 0, 0, 0)
                        
                    })
                    
                }
                
                }) {(baseRequest, err) -> Void in
                    print(err.localizedDescription)
            }
            
        }
        
        recommendRequest.page = page
        recommendRequest.boardId = board.board_id
        recommendRequest.max = self.dataSource.last?.pin_id.stringValue
        recommendRequest.requestWithRequestOption(.None, sucess: {[unowned self] (baseRequest) -> Void in
            
            if self.recommendRequest.pinArray?.count > 0 {
                if page == 1 {
                    self.dataSource.removeAll()
                }
                self.dataSource.appendContentsOf(self.recommendRequest.pinArray!)
                self.currentPage = page
                self.collectionView.mj_footer.endRefreshing()
            } else {
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }
            
            self.collectionView.mj_header.endRefreshing()
            
            }) {[weak self] (baseRequest, err) -> Void in
                self?.showError("加载失败")
                
                print(err.localizedDescription)
                self?.collectionView.mj_header.endRefreshing()
                self?.collectionView.mj_footer.endRefreshing()
                
        }
    }
    //MARK: - UICollectionViewDataSource
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
        
        let frrr = self.view.convertRect(selectedCell!.frame, fromView:self.collectionView)
        
        var point = self.collectionView.contentOffset;
        point.y -= self.collectionView.frame.size.height*0.5 - (frrr.origin.y+frrr.size.height*0.5);
        if (point.y < -64) {
            point.y = -64;
        }
        
        self.collectionView.setContentOffset(point, animated:true);
        
        let vc = PinDetailViewController()
        vc.pin = self.dataSource[indexPath.item]
        vc.popSelectedView = selectedCell?.photoImageView
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let model = self.dataSource[indexPath.row]
        return XHWaterCollectionCell.getSize(model)
    }
    
    //MARK: - scroll
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isUserDrag = true
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isUserDrag = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        
        if self.collectionView != scrollView || !isUserDrag || offsetY < offsetChangeBegin || scrollView.contentSize.height - offsetY - kScreenHeight < 0 {
            return
        }
        
        
        if lastOffsetY - offsetY > offsetChange {
            if self.isUp == true {
                self.isUp = false
            }
        } else {
            if self.isUp == false {
                self.isUp = true
            }
        }
        lastOffsetY = offsetY
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
