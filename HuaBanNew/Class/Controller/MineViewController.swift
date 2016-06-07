//
//  MineViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/10/27.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout

class MineViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout {
    
    var userId: NSNumber!
    var user: User!
    var isSelf: Bool = false
    var collectionView: UICollectionView!
    var lastOffsetY: CGFloat! = 0
    var isUserDrag = false
    var isUp: Bool! = false {
        didSet {
            self.hidesTabBar(isUp)
        }
    }
    
    var mineHeader: MineHeaderView!
    var requestUser = UserDetailRequest()
    var requestBoards = UserBoardsRequest()
    var requestPins = UserPinsRequest()
    var requestLikes = UserLikesRequest()
    var requestSays = UserSaysRequest()
    var chtLayout: CHTCollectionViewWaterfallLayout!
    var imageInfo: JTSImageInfo!
    //    var selectedView: UIView?
    var currentPage = 0
    
    var selectIndex = 0 {
        didSet {
            if selectIndex == 3 && self.chtLayout.columnCount == 2 {
                self.chtLayout.columnCount =  1
            } else if selectIndex != 3 && self.chtLayout.columnCount == 1 {
                self.chtLayout.columnCount =  2
            }
            
            if     (selectIndex == 0 && self.boardDataSource.count > 0)
                || (selectIndex == 1 && self.pinDataSource.count > 0)
                || (selectIndex == 2 && self.likeDataSource.count > 0)
                || (selectIndex == 3 && self.sayDataSource.count > 0) {
                    
            } else {
                self.loadData(true)
            }
            
            self.collectionView.mj_footer.resetNoMoreData()
            self.collectionView.reloadData()
            
        }
    }
    
    var boardDataSource = [Board]() {
        didSet {
            let lastItem = oldValue.count
            //只刷新增加的数据，不能用reloadData，会造成闪屏
            for (_,element) in self.boardDataSource.enumerate() {
                element.user = self.user
            }
            
            if self.boardDataSource.count > lastItem {
                let indexPaths = (lastItem..<self.boardDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                self.collectionView.performBatchUpdates({ () -> Void in
                    self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                    
                    }, completion: { (finish) -> Void in
                })

            } else {
                self.collectionView.reloadData()
            }
          
        }
    }
    
    var pinDataSource = [Pin]() {
        didSet {
            let lastItem = oldValue.count
            //只刷新增加的数据，不能用reloadData，会造成闪屏
            
            for (_,element) in self.pinDataSource.enumerate() {
                element.needUser = true
            }
            
            if self.pinDataSource.count > lastItem {
                let indexPaths = (lastItem..<self.pinDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                
                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
            } else { // headerRefresh
                self.collectionView.reloadData()
            }
            
        }
    }
    
    var likeDataSource = [Pin]() {
        didSet {
            let lastItem = oldValue.count
            //只刷新增加的数据，不能用reloadData，会造成闪屏
            
            for (_,element) in self.likeDataSource.enumerate() {
                element.needUser = true
            }
            
            
            if self.likeDataSource.count > lastItem {
                let indexPaths = (lastItem..<self.likeDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                
                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
            } else { // headerRefresh
                self.collectionView.reloadData()
            }
            
        }
    }
    
    var sayDataSource = [Post]() {
        didSet {
            let lastItem = oldValue.count
            //只刷新增加的数据，不能用reloadData，会造成闪屏
            if self.sayDataSource.count > lastItem {
                let indexPaths = (lastItem..<self.sayDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                
                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
            } else { // headerRefresh
                self.collectionView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.user == nil {
            self.user = User()

            if self.userId == nil {
                self.user.user_id = AppUser.defaultUser.user_id
                self.user.urlname = AppUser.defaultUser.urlname
                self.user.username = AppUser.defaultUser.username
                self.userId = self.user.user_id
            } else {
                self.user.user_id = self.userId
            }
            
        } else {
            self.userId = self.user.user_id

        }
        
        if self.userId == AppUser.defaultUser.user_id {
            self.isSelf = true
        }
        
        // 设置UI
        self.setupUI()
        
        // 网络请求
        self.setupNetWork()
        
    }
    
    func setupUI() {
        
        chtLayout = CHTCollectionViewWaterfallLayout()
        //        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirection.LeftToRight
        chtLayout.columnCount = 2
        
        // Change individual layout attributes for the spacing between cells
        chtLayout.minimumColumnSpacing = 10.0
        chtLayout.minimumInteritemSpacing = 10.0
        //  设置collectionView的 四周的内边距
        chtLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        chtLayout.headerInset = UIEdgeInsetsMake(230, 0, 0, 0);

        var frame = self.view.bounds
        frame.size.height += 49
        collectionView = UICollectionView(frame: frame, collectionViewLayout: chtLayout)
        self.view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        collectionView.registerNib(UINib(nibName: "XHHuabanCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHHuabanCollectionCell")
        collectionView.registerNib(UINib(nibName: "XHWaterCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHWaterCollectionCell")
        collectionView.registerNib(UINib(nibName: "HBSayCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "HBSayCollectionViewCell")
        
        mineHeader = self.loadNib("MineHeaderView") as! MineHeaderView
        mineHeader.frame = CGRectMake(0, 0, kScreenWidth, 230)
        mineHeader.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        
        mineHeader.setSelectIndexClosure({[weak self] (headView, from, to) -> Void in
            if from != to {
                self?.selectIndex = to
            }
            
            })
        mineHeader.setOnFanslabelClosure({[weak self] (headView) -> Void in
            let vc = FansViewController()
            vc.urlname = self!.user.urlname
            vc.fansCount = self!.user.follower_count
            vc.followsCount = self!.user.following_count
            self?.navigationController?.pushViewController(vc, animated: true)
            
            })
        collectionView.addSubview(mineHeader)
        
        self.configNav()
        
    }
    
    func setupNetWork() {
        
        self.requestUserInfo()
        
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] () -> Void in
            self?.collectionView.mj_header.endRefreshing()
            self?.loadData(true)
            })
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.collectionView.mj_footer.endRefreshing()
            self?.loadData(false)
            })
        (self.collectionView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.collectionView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
    }
    
    func requestUserInfo() {
        requestUser.userId = self.userId
        requestUser.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            
            if self.requestUser.resultUser != nil {
                self.user = self.requestUser.resultUser
                self.mineHeader.setInfo(self.requestUser.resultUser!)
                self.loadData(true)

                if self.isSelf {
                    AppUser.defaultUser.updateUser(self.requestUser.resultUser!)
                }
            }
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err)
        }
    }
    
    func configNav() {
        
        if self.isSelf {
            self.title = "我的主页"
        } else {
            self.title = "\(self.user.username)" + "的主页"
            return
        }
        
        
        // 搜索
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting_pressed")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MineViewController.onSetting))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "tabAdd_pressed")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MineViewController.onTabAdd))
        
        
    }
    
    func onSetting() {
        print("onSetting")
        self.showMessage(String(format: "总缓存请求大小%.2fM", XHSaveHelper.getCacheSizeOfAll()))
    }
    
    func onTabAdd() {
        print("onTabAdd")
    }
    
    func loadData(isHeaderRefresh: Bool){
        
        switch selectIndex {
        case 0:self.sendRequestBoards(isHeaderRefresh)
        case 1:self.sendRequestPins(isHeaderRefresh)
        case 2:self.sendRequestLikes(isHeaderRefresh)
        case 3:self.sendRequestSays(isHeaderRefresh)
        default:break
        }
    }
    
    
    func sendRequestBoards(isHeaderRefresh: Bool) {
        
        self.requestBoards.user = user
        
        if isHeaderRefresh {
            self.requestBoards.page = 1
            self.requestBoards.max = nil
        } else {
            self.requestBoards.max = self.boardDataSource.last?.board_id
            self.requestBoards.page += 1
        }
        
        requestBoards.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            
            if self.requestBoards.boards?.count > 0 {
                
                if isHeaderRefresh {
                    self.boardDataSource.removeAll()
                }
                self.boardDataSource.appendContentsOf(self.requestBoards.boards!)
                
            } else {
                self.requestBoards.page -= 1
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData;
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                self.requestBoards.page -= 1
                print(err)
        }
        
    }
    
    func sendRequestPins(isHeaderRefresh: Bool) {
        
        self.requestPins.user = user
        if isHeaderRefresh {
            self.requestPins.page = 1
            self.requestPins.max = nil
        } else {
            self.requestPins.max = self.pinDataSource.last?.pin_id
            self.requestPins.page += 1
        }
        
        requestPins.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()

            if self.requestPins.pins?.count > 0 {
                if isHeaderRefresh {
                    self.pinDataSource.removeAll()
                }
                self.pinDataSource.appendContentsOf(self.requestPins.pins!)
                
                
            } else {
                self.requestPins.page -= 1
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData;
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                self.requestPins.page -= 1
                print(err)
        }
        
    }
    
    func sendRequestLikes(isHeaderRefresh: Bool) {
        
        self.requestLikes.user = user
        if isHeaderRefresh {
            self.requestLikes.page = 1
            self.requestLikes.max = nil
        } else {
            self.requestLikes.max = self.likeDataSource.last?.seq
            self.requestLikes.page += 1
        }
        
        requestLikes.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            if self.requestLikes.likes?.count > 0 {
                if isHeaderRefresh {
                    self.likeDataSource.removeAll()
                }
                self.likeDataSource.appendContentsOf(self.requestLikes.likes!)
                
            } else {
                self.requestLikes.page -= 1
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData;
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                self.requestLikes.page -= 1
                print(err)
        }
        
    }
    
    func sendRequestSays(isHeaderRefresh: Bool) {
        
        self.requestSays.user = user
        if isHeaderRefresh {
            self.requestSays.page = 1
            self.requestSays.max = nil
        } else {
            self.requestSays.max = self.sayDataSource.last?.post_id
            self.requestSays.page += 1
        }
        
        
        requestSays.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            if self.requestSays.says?.count > 0 {
                if isHeaderRefresh {
                    self.sayDataSource.removeAll()
                }
                self.sayDataSource.appendContentsOf(self.requestSays.says!)
                
            } else {
                self.requestSays.page -= 1
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData;
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                self.requestSays.page -= 1
                print(err)
        }
        
    }
    
    //MARK: - scroll
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isUserDrag = true
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isUserDrag = false

    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isUserDrag = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y

        if self.collectionView != scrollView || !isUserDrag || offsetY < offsetChangeBegin || scrollView.contentSize.height - offsetY - kScreenHeight < 0 {
            return
        }
        
        
        if lastOffsetY - offsetY > offsetChange { // 上移
            if self.isUp == true {
                self.isUp = false
            }
        }
        if offsetY - lastOffsetY > offsetChange {
            if self.isUp == false {
                self.isUp = true
            }
        }
        lastOffsetY = offsetY

    }
    
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectIndex {
        case 0:
            return boardDataSource.count
        case 1:
            return pinDataSource.count
        case 2:
            return likeDataSource.count
        case 3:
            return sayDataSource.count
        default:
            return boardDataSource.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch selectIndex {
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHHuabanCollectionCell", forIndexPath: indexPath) as! XHHuabanCollectionCell
            
            cell.setInfo(boardDataSource[indexPath.row], editBtnClick: { (model) -> Void in
                self.showAlert("编辑", message: nil, actions: [UIAlertAction(title: "知道了", style: UIAlertActionStyle.Cancel, handler: nil)])
            })
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHWaterCollectionCell", forIndexPath: indexPath) as! XHWaterCollectionCell
            cell.setInfo(pinDataSource[indexPath.row])
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHWaterCollectionCell", forIndexPath: indexPath) as! XHWaterCollectionCell
            cell.setInfo(likeDataSource[indexPath.row])
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HBSayCollectionViewCell", forIndexPath: indexPath) as! HBSayCollectionViewCell
            cell.setInfo(sayDataSource[indexPath.row])
            
            cell.setTapPhotoViewClosure({[weak self] (cell, targetView) -> Void in
                self?.tapImage(targetView)
                })
            
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHHuabanCollectionCell", forIndexPath: indexPath) as! XHHuabanCollectionCell
            cell.setInfo(boardDataSource[indexPath.row])
            return cell
        }
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        switch selectIndex {
        case 0:
            let model = boardDataSource[indexPath.row]
            let vc = BoardDetailViewController()
            //            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("BoardDetailViewController") as! BoardDetailViewController
            vc.board = model
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? XHWaterCollectionCell
            
            let frrr = self.view.convertRect(selectedCell!.frame, fromView:self.collectionView)
            
            var point = self.collectionView.contentOffset;
            point.y -= self.collectionView.frame.size.height*0.5 - (frrr.origin.y+frrr.size.height*0.5);
            if (point.y < -64) {
                point.y = -64;
            }
            
            self.collectionView.setContentOffset(point, animated:true);
            let model = pinDataSource[indexPath.row]
            let vc = PinDetailViewController()
            vc.pin = model
            vc.popSelectedView = (self.collectionView.cellForItemAtIndexPath(indexPath) as! XHWaterCollectionCell).photoImageView
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? XHWaterCollectionCell
            
            let frrr = self.view.convertRect(selectedCell!.frame, fromView:self.collectionView)
            
            var point = self.collectionView.contentOffset;
            point.y -= self.collectionView.frame.size.height*0.5 - (frrr.origin.y+frrr.size.height*0.5);
            if (point.y < -64) {
                point.y = -64;
            }
            
            self.collectionView.setContentOffset(point, animated:true);
            let model = likeDataSource[indexPath.row]
            let vc = PinDetailViewController()
            vc.popSelectedView = (self.collectionView.cellForItemAtIndexPath(indexPath) as! XHWaterCollectionCell).photoImageView
            
            vc.pin = model
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            break
        default:
            break;
        }
    }
    
    //MARK: UICollectionViewLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch selectIndex {
        case 0:
            let model = boardDataSource[indexPath.row]
            return XHHuabanCollectionCell.getSize(model)
        case 1:
            let model = pinDataSource[indexPath.row]
            return XHWaterCollectionCell.getSize(model)
            
        case 2:
            let model = likeDataSource[indexPath.row]
            return XHWaterCollectionCell.getSize(model)
            
        case 3:
            let model = sayDataSource[indexPath.row]
            return CGSizeMake(itemTopicWidth, HBSayCollectionViewCell.getHeight(model))
            
        default:
            let model = boardDataSource[indexPath.row]
            return XHHuabanCollectionCell.getSize(model)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Action
    func tapImage(sender: UIView) {
        // Create image info
        //            imageInfo.imageURL = [NSURL URLWithString:"http://media.giphy.com/media/O3QpFiN97YjJu/giphy.gif"];
        
        if imageInfo == nil {
            imageInfo = JTSImageInfo();
        }
        let imageV = sender as! UIImageView
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
