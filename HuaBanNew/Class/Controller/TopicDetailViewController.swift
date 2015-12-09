//
//  TopicDetailViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/14.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout

class TopicDetailViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var topic: Topic!
    var requestTopicDetail = TopicDetailRequest()
    var collectionView: UICollectionView!
    var imageInfo: JTSImageInfo!
    var currentPage = 0;
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
        
        self.title = self.topic.title

        // 设置UI
        self.setupUI()
        
        // 网络请求
        self.setupNetWork()
        
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        
        let layout = UICollectionViewFlowLayout()
        // 3. 设置cell的 间距
        layout.minimumInteritemSpacing = 10;
        // 4. 设置collectionView的 行间距
        layout.minimumLineSpacing = 10;
        // 5. 设置collectionView的 四周的内边距
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        // 6. 设置collectionView的滚动方向 （默认是垂直,这里设置为水平）
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
        
        
        collectionView = UICollectionView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        collectionView.registerNib(UINib(nibName: "XHHuabanCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHHuabanCollectionCell")
        collectionView.registerNib(UINib(nibName: "XHWaterCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHWaterCollectionCell")
        collectionView.registerNib(UINib(nibName: "HBSayCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "HBSayCollectionViewCell")
        
        self.view.addSubview(collectionView)
        
    }
    
    func setupNetWork() {
        
        //        let url1 = AppURL.discover.zuixin.rawValue
        //        let url2 = AppURL.search("美女", categoryName: nil, type: AppURL.SearchType.pin)
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(1)
            })
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(self!.currentPage + 1)
            
        })
        collectionView.mj_header.beginRefreshing()
        
        (self.collectionView.mj_footer as! MJRefreshAutoNormalFooter).huaBanFooterConfig()
        (self.collectionView.mj_header as! MJRefreshNormalHeader).huaBanHeaderConfig()
        
    }
    func loadData(page: Int){
        
        self.showLoading("正在加载...")
        
        self.requestTopicDetail.page = currentPage
        self.requestTopicDetail.topicId = self.topic.topic_id
        
        requestTopicDetail.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            self.hideHud()
            if self.requestTopicDetail.posts != nil {
                if page == 1 {
                    self.sayDataSource.removeAll()
                }
                self.sayDataSource.appendContentsOf(self.requestTopicDetail.posts!)
                
                self.currentPage++
                
                if self.requestTopicDetail.posts?.count < 20 {
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.collectionView.mj_footer.endRefreshing()
                }
                self.collectionView.mj_header.endRefreshing()
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err)
                self.collectionView.mj_header.endRefreshing()
                self.collectionView.mj_footer.endRefreshing()
        }
        
    }
    
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

    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sayDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HBSayCollectionViewCell", forIndexPath: indexPath) as! HBSayCollectionViewCell
        cell.setInfo(sayDataSource[indexPath.row])
        
        cell.setTapPhotoViewClosure {[weak self] (cell, targetView) -> Void in
            self?.tapImage(targetView)
        }
        
        return cell
  
    }
    
    
    //MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: UICollectionViewLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let model = sayDataSource[indexPath.row]
        return CGSizeMake(itemTopicWidth, HBSayCollectionViewCell.getHeight(model))
        
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
