//
//  FansViewController.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/2.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout

class FansViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout {
    
    var urlname:String!
    var fansCount: NSNumber = 0
    var followsCount: NSNumber = 0
    var fansRequest = FollowerUserRequest()
    var followRequest = FollowingUserRequest()
    
    var collectionView: UICollectionView!
    
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
            if self.collectionView.mj_footer != nil {
                self.collectionView.mj_footer.resetNoMoreData()
            }

            switch selectIndex {
            case 0:
                if self.fansDataSource.count == 0 {
                    self.loadData(true)
                }
            case 1:
                if self.followDataSource.count == 0 {
                    self.loadData(true)
                }
            default:break
            }
            self.collectionView.reloadData()
        }
    }
    
    var fansDataSource = [User]()
    
    var followDataSource = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.navigationController?.delegate = self
        
        self.title = "粉丝与关注"
        
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
        
        collectionView = UICollectionView(frame: CGRectMake(0, 45, kScreenWidth, kScreenHeight - 45 + 49), collectionViewLayout: chtLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        collectionView.registerNib(UINib(nibName: "XHHuabanCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHHuabanCollectionCell")
        collectionView.registerNib(UINib(nibName: "XHWaterCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHWaterCollectionCell")
        collectionView.registerNib(UINib(nibName: "XHUserCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHUserCollectionCell")
        
        self.view.addSubview(collectionView)
        
        segment = SMSegmentView.init(frame: CGRectMake(0, 64, kScreenWidth, 45), separatorColour: UIColor.grayColor(), separatorWidth: 0.5, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(12.0), keySegmentOnSelectionColour: UIColor(red: 245.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0), keySegmentOffSelectionColour: UIColor.whiteColor(), keyContentVerticalMargin: Float(10.0)])
        
        
        // Add segments
        self.segment.addSegmentWithTitle("粉丝\(self.fansCount)", onSelectionImage: nil, offSelectionImage: nil)
        self.segment.addSegmentWithTitle("关注\(self.followsCount)", onSelectionImage: nil, offSelectionImage: nil)
        
        // Set segment with index 0 as selected by default
        //segmentView.selectSegmentAtIndex(0)
        
        segment.setSegmentDidSelectIndexClosure({[weak self] (segmentView, index) -> Void in
            self?.selectIndex = index
            })
        
        self.segment.selectSegmentAtIndex(0)
        
        self.view.addSubview(segment)
        
    }
    
    func setupNetWork() {
        
        self.loadData(true)
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(true)
            })
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(false)
            
            })
        (self.collectionView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.collectionView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
    }
    
    func loadData(isHeadRefresh: Bool = false){
        
        self.showLoading("正在加载...")
        
        switch selectIndex {
        case 0:
            self.sendRequestFans(isHeadRefresh)
        case 1:
            self.sendRequestFollows(isHeadRefresh)
        default:break
        }
    }
    
    
    func sendRequestFans(isHeadRefresh: Bool) {
        if isHeadRefresh {
            self.fansRequest.page = 1
        } else {
            self.fansRequest.page += 1
        }
        
        self.fansRequest.urlname = self.urlname!
        fansRequest.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            self.collectionView.mj_header.endRefreshing()

            if self.fansRequest.users?.count > 0 {
                if isHeadRefresh {
                    self.fansDataSource.removeAll()
                    self.fansDataSource.appendContentsOf(self.fansRequest.users!)
                    self.collectionView.reloadData()

                } else {
                    let lastItem = self.fansDataSource.count
                    self.fansDataSource.appendContentsOf(self.fansRequest.users!)
                    let indexPaths = (lastItem..<self.fansDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                }
                    
                self.collectionView.mj_footer.endRefreshing()
            } else {
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                self.fansRequest.page -= 1
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err)
                self.collectionView.mj_header.endRefreshing()
                self.collectionView.mj_footer.endRefreshing()
                self.fansRequest.page -= 1
                
        }
        
    }
    
    func sendRequestFollows(isHeadRefresh: Bool) {
        if isHeadRefresh {
            self.followRequest.page = 1
        } else {
            self.followRequest.page += 1
        }
        self.followRequest.urlname = urlname
        
        followRequest.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            self.collectionView.mj_header.endRefreshing()

            if self.followRequest.users?.count > 0 {
                if isHeadRefresh {
                    self.followDataSource.removeAll()
                    self.followDataSource.appendContentsOf(self.followRequest.users!)
                    self.collectionView.reloadData()

                } else {
                    let lastItem = self.followDataSource.count
                    self.followDataSource.appendContentsOf(self.followRequest.users!)
                    let indexPaths = (lastItem..<self.followDataSource.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    
                    self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                }
                
                self.collectionView.mj_footer.endRefreshing()
            } else {
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                self.followRequest.page -= 1

            }
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err.localizedDescription)
                self.collectionView.mj_header.endRefreshing()
                self.collectionView.mj_footer.endRefreshing()
                self.followRequest.page -= 1
                
        }
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return selectIndex == 0 ? fansDataSource.count : followDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XHUserCollectionCell", forIndexPath: indexPath) as! XHUserCollectionCell

        if selectIndex == 0 {
            cell.setInfo(fansDataSource[indexPath.row])
        } else {
            cell.setInfo(followDataSource[indexPath.row])
        }
        
        cell.setFollowBtnClosure({ (isToFollow) -> Void in
            print("isToFollow:"+"\(isToFollow)")
        })

        return cell


    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let vc = self.loadVCFromSB("MineViewController") as! MineViewController

        if self.segment.indexOfSelectedSegment == 0 {
            vc.user = self.fansDataSource[indexPath.item]
        } else {
            vc.user = self.followDataSource[indexPath.item]
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: UICollectionViewLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let model = (self.selectIndex == 0 ? fansDataSource : followDataSource)[indexPath.row]
        
        return CGSizeMake(itemWidth, XHUserCollectionCell.getHeight(model))
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
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
    
}
