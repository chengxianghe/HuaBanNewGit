//
//  SearchResultController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/14.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout
class SearchResultController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout {
    
    var searchStr: String = ""
    
    var collectionView: UICollectionView!
    
    var requestBoards = SearchBoardsRequest()
    var requestPins = SearchPinsRequest()
    var requestUsers = SearchUsersRequest()
    var chtLayout: CHTCollectionViewWaterfallLayout!
    var segment: SMSegmentView!
    var currentPage = 0
    var lastOffsetY: CGFloat! = 0
    var isUserDrag = false
    var isUp: Bool! = false {
        didSet {
            self.hidesTabBar(isUp)
        }
    }
    var selectIndex = 0 {
        didSet {
            self.collectionView.reloadData()
            
            switch selectIndex {
            case 0:
                if self.requestPins.page == 0 {
                    self.loadData(true)
                }
            case 1:
                if self.requestBoards.page == 0 {
                    self.loadData(true)
                }
            case 2:
                if self.requestUsers.page == 0 {
                    self.loadData(true)
                }
            default:break
            }
        }
    }
    
    var pinDataSource = [Pin]() {
        didSet {
            if self.selectIndex == 0 {
                
                let lastItem = oldValue.count
                //只刷新增加的数据，不能用reloadData，会造成闪屏
                if self.pinDataSource.count > lastItem {
                    let indexPaths = (lastItem..<self.pinDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    
                    self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                } else { // headerRefresh
                    self.collectionView.reloadData()
                }
                
            }
        }
    }
    
    var boardDataSource = [Board]() {
        didSet {
            if self.selectIndex == 1 {
                
                let lastItem = oldValue.count
                //只刷新增加的数据，不能用reloadData，会造成闪屏
                if self.boardDataSource.count > lastItem {
                    let indexPaths = (lastItem..<self.boardDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    
                    self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                } else { // headerRefresh
                    self.collectionView.reloadData()
                }
                
            }
        }
    }
    
    var userDataSource = [User]() {
        didSet {
            
            if self.selectIndex == 2 {
                let lastItem = oldValue.count
                //只刷新增加的数据，不能用reloadData，会造成闪屏
                if self.userDataSource.count > lastItem {
                    let indexPaths = (lastItem..<self.userDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    
                    self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                } else { // headerRefresh
                    self.collectionView.reloadData()
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.navigationController?.delegate = self
        
        self.title = self.searchStr
        
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
        //        chtLayout.headerInset = UIEdgeInsetsMake(230, 0, 0, 0);
        
        collectionView = UICollectionView(frame: CGRectMake(0, 35, kScreenWidth, kScreenHeight - 35 + 49), collectionViewLayout: chtLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        collectionView.registerNib(UINib(nibName: "XHHuabanCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHHuabanCollectionCell")
        collectionView.registerNib(UINib(nibName: "XHWaterCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHWaterCollectionCell")
        collectionView.registerNib(UINib(nibName: "XHUserCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHUserCollectionCell")
        
        self.view.addSubview(collectionView)
        
        segment = SMSegmentView.init(frame: CGRectMake(0, 64, kScreenWidth, 35), separatorColour: UIColor.grayColor(), separatorWidth: 0.5, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(12.0), keySegmentOnSelectionColour: UIColor(red: 245.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0), keySegmentOffSelectionColour: UIColor.whiteColor(), keyContentVerticalMargin: Float(10.0)])
        
        
        // Add segments
        self.segment.addSegmentWithTitle("采集", onSelectionImage: nil, offSelectionImage: nil)
        self.segment.addSegmentWithTitle("画板", onSelectionImage: nil, offSelectionImage: nil)
        self.segment.addSegmentWithTitle("用户", onSelectionImage: nil, offSelectionImage: nil)
        
        // Set segment with index 0 as selected by default
        //segmentView.selectSegmentAtIndex(0)
        
        segment.setSegmentDidSelectIndexClosure({[weak self] (segmentView, index) -> Void in
            self?.selectIndex = index
            })
        
        self.segment.selectSegmentAtIndex(0)
        
        self.view.addSubview(segment)
        
    }
    
    func setupNetWork() {
        
        
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
    
    func loadData(isHeaderRefresh: Bool){
        
        self.showLoading("正在加载...")
        
        switch selectIndex {
        case 0:
            self.sendRequestPins(isHeaderRefresh)
        case 1:
            self.sendRequestBoards(isHeaderRefresh)
        case 2:
            self.sendRequestUsers(isHeaderRefresh)
        default:break
        }
    }
    
    
    func sendRequestBoards(isHeaderRefresh: Bool) {
        if isHeaderRefresh {
            self.requestBoards.page = 1
        } else {
            self.requestBoards.page = self.requestBoards.page + 1
        }
        
        self.requestBoards.searchStr = searchStr
        requestBoards.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            if self.requestBoards.boards != nil {
                if isHeaderRefresh {
                    self.boardDataSource.removeAll()
                }
                self.boardDataSource.appendContentsOf(self.requestBoards.boards!)
                
            } else {
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData
                self.requestBoards.page--
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err)
                self.requestBoards.page--
                
        }
        
    }
    
    func sendRequestPins(isHeaderRefresh: Bool) {
        if isHeaderRefresh {
            self.requestPins.page = 1
        } else {
            self.requestPins.page++
        }
        self.requestPins.searchStr = searchStr
        
        requestPins.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            if self.requestPins.pins?.count > 0 {
                if isHeaderRefresh {
                    self.pinDataSource.removeAll()
                    self.segment.updateSegmentWithTitle(0, title: "\(self.requestPins.pin_count)采集")
                    self.segment.updateSegmentWithTitle(1, title: "\(self.requestPins.board_count)画板")
                    self.segment.updateSegmentWithTitle(2, title: "\(self.requestPins.people_count)用户")
                    
                }
                self.pinDataSource.appendContentsOf(self.requestPins.pins!)
            } else {
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData
                self.requestPins.page--
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err.localizedDescription)
                self.requestPins.page--
                
        }
    }
    
    func sendRequestUsers(isHeaderRefresh: Bool) {
        
        
        if isHeaderRefresh {
            self.requestUsers.page = 1
        } else {
            self.requestUsers.page = self.requestUsers.page + 1
        }
        
        self.requestUsers.searchStr = searchStr
        
        requestUsers.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            if self.requestUsers.users?.count > 0 {
                if isHeaderRefresh {
                    self.userDataSource.removeAll()
                }
                self.userDataSource.appendContentsOf(self.requestUsers.users!)
            } else {
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData
                self.requestUsers.page--
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err)
                
                self.requestUsers.page--
        }
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectIndex {
        case 0:
            return pinDataSource.count
        case 1:
            return boardDataSource.count
        case 2:
            return userDataSource.count
            
        default:
            return boardDataSource.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch selectIndex {
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHWaterCollectionCell", forIndexPath: indexPath) as! XHWaterCollectionCell
            cell.setInfo(pinDataSource[indexPath.row])
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHHuabanCollectionCell", forIndexPath: indexPath) as! XHHuabanCollectionCell
            cell.setInfo(boardDataSource[indexPath.row])
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHUserCollectionCell", forIndexPath: indexPath) as! XHUserCollectionCell
            cell.setInfo(userDataSource[indexPath.row])
            cell.setFollowBtnClosure({ (isToFollow) -> Void in
                print("isToFollow:"+"\(isToFollow)")
            })
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHWaterCollectionCell", forIndexPath: indexPath) as! XHWaterCollectionCell
            cell.setInfo(pinDataSource[indexPath.row])
            return cell
        }
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.segment.indexOfSelectedSegment == 0 {
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? XHWaterCollectionCell
            let frrr = self.view.convertRect(selectedCell!.frame, fromView:self.collectionView)
            
            var point = self.collectionView.contentOffset;
            point.y -= self.collectionView.frame.size.height*0.5 - (frrr.origin.y+frrr.size.height*0.5);
            if (point.y < -64) {
                point.y = -64;
            }
            
            self.collectionView.setContentOffset(point, animated:true);
            
            let vc = PinDetailViewController()
            vc.pin = self.pinDataSource[indexPath.item]
            vc.popSelectedView = selectedCell?.photoImageView
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.segment.indexOfSelectedSegment == 1 { // 画板
            let vc = BoardDetailViewController()
            vc.board = self.boardDataSource[indexPath.item]
            self.navigationController?.pushViewController(vc, animated: true)
        } else { // 用户
            
            let vc = self.loadVCFromSB("MineViewController") as! MineViewController
            vc.user = self.userDataSource[indexPath.item]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: UICollectionViewLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch selectIndex {
        case 0:
            let model = pinDataSource[indexPath.row]
            return XHWaterCollectionCell.getSize(model)
            
        case 1:
            let model = boardDataSource[indexPath.row]
            return XHHuabanCollectionCell.getSize(model)
            
        case 2:
            let model = userDataSource[indexPath.row]
            return CGSizeMake(itemWidth, XHUserCollectionCell.getHeight(model))
            
        default:
            let model = pinDataSource[indexPath.row]
            return XHWaterCollectionCell.getSize(model)
        }
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        if self.selectIndex == 0 {
            return 10
        }
        return 20
    }
    
    /*- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.isUp = false
            }
            lastOffsetY = offsetY
        } else if lastOffsetY - offsetY < -offsetChange && offsetY > offsetChangeBegin {
            if self.isUp == false {
                self.isUp = true
            }
            lastOffsetY = offsetY
        }
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
