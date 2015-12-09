//
//  MyPinViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/1.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout

class MyPinViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout {
    
    var collectionView: UICollectionView!
    var request = PopularPinRequest()
    var currentPage = 0
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置UI
        self.setupUI()
        
        // 网络请求
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
    }
    
    
    func setupNetWork() {

        self.loadData(1)

        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(1)
            })
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(self!.currentPage + 1)
            
            })
        (self.collectionView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.collectionView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
    }
    
    func loadData(page: Int){
        
        self.request.page = page
        
        request.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.collectionView.mj_header.endRefreshing()
            self.collectionView.mj_footer.endRefreshing()
            
            if self.request.pins?.count > 0 {
                if page == 1 {
                    self.dataSource.removeAll()
                }
                self.currentPage = page
                
                
                self.dataSource.appendContentsOf(self.request.pins!)
                self.collectionView.reloadData()
            } else {
                self.collectionView.mj_footer.state = MJRefreshState.NoMoreData
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                
                print(err)
                self.collectionView.mj_header.endRefreshing()
                self.collectionView.mj_footer.endRefreshing()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
