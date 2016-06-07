//
//  DiscoverViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/10/27.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout
import SnapKit

protocol CategoryCellProtocol {
    
    var detailBtn: UIButton!{ get }
    var titleLabel: UILabel! { get }
    
    static func registerTable(table: UITableView)
    static func getReusableCell(table: UITableView, indexPath: NSIndexPath) -> CategoryCellProtocol?
    
    static func getHeightWith(model: BaseModel) -> CGFloat
    func setInfo(model: BaseModel)
}

class CategoryHeaderView : UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
    }
    
    static func registerTable(table: UITableView) {
        table.registerClass(CategoryHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "CategoryHeaderView")
    }
    
    static func getReusableHeaderFooterView(table: UITableView, section: NSInteger) -> CategoryHeaderView? {
        
        return table.dequeueReusableHeaderFooterViewWithIdentifier("CategoryHeaderView") as? CategoryHeaderView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.font = UIFont.systemFontOfSize(12)
        let frame = self.textLabel?.frame
        
        self.textLabel?.frame.origin.x = (frame?.origin.x)! - 8
        
    }
    
    
    override func prepareForReuse() {
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}

class DiscoverViewController: BaseViewController,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CHTCollectionViewDelegateWaterfallLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
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
                self.collectionView.insertItemsAtIndexPaths(indexPaths)
            } else { // headerRefresh
                self.collectionView.reloadData()
            }
            
        }
    }
    
    var categoryTableView: XHCategoryTableView!
    var isShowCategory = false
    var searchBarView: UIView!
    let searchResults = NSMutableArray();//搜索结果
    var searchBar : UISearchBar!
    var mySearchDisplayController: UISearchDisplayController?
    
    let request = DiscoverRequest()
    var currentPage: Int = 0
    var categoryModel =  AppURL.shareInstance.latestModel
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置UI
        self.setupUI()
        
        // 网络请求
        self.setupNetWork()
        
    }
    
    func setupUI() {
        
        let dict1 = ["board":"1415967", "key":"5f8d079644c21dc2e130ef6f96384def7e425e8959f9e-xQezxU_fw658", "title":"美好的风景", "week":"星期五"]
        
        let dict2 = ["board":"3989623", "key":"dd5de3368711fd9e2431fdd92aff95e66b2263516f770-MLcnml_fw658", "title":"蝴蝶本纪", "week":"星期四"]
        let dict3 = ["board":"26264777", "key":"0ddd06d4e344e38e355d8e953b5196fac3c23fe73f43-DjQj01_fw658", "title":"黑白的界限", "week":"星期三"]
        
        let pageArray = [dict1,dict2,dict3]
        
        // 默认的 黑白的界限: http://api.huaban.com/boards/26264777/
        //http://img.hb.aicdn.com/0ddd06d4e344e38e355d8e953b5196fac3c23fe73f43-DjQj01_fw658
        // 蝴蝶本纪 : http://api.huaban.com/boards/3989623/
        //http://img.hb.aicdn.com/dd5de3368711fd9e2431fdd92aff95e66b2263516f770-MLcnml_fw658
        // 美景: http ://api.huaban.com/boards/1415967/
        //http://img.hb.aicdn.com/5f8d079644c21dc2e130ef6f96384def7e425e8959f9e-xQezxU_fw658
        
        let images = [
            "http://img.hb.aicdn.com/5f8d079644c21dc2e130ef6f96384def7e425e8959f9e-xQezxU_fw320",
            "http://img.hb.aicdn.com/dd5de3368711fd9e2431fdd92aff95e66b2263516f770-MLcnml_fw320",
            "http://img.hb.aicdn.com/0ddd06d4e344e38e355d8e953b5196fac3c23fe73f43-DjQj01_fw320"];
        
        let titles = ["美好的风景", "蝴蝶本纪", "黑白的界限"]
        
        let infoView = self.loadNib("CustomPageInfoView") as! CustomPageInfoView
        infoView.frame = CGRectMake(0, 155, kScreenWidth, 45)
        infoView.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        infoView.pageControl.numberOfPages = images.count
        
        let scrollPage = ScrollPageView(frame: CGRectMake(0,0,kScreenWidth,200), images: images, autoPlay: true, delay: 3, showPageControl: false, customView: infoView) { (pageView, index) -> Void in
            infoView.titleLabel.text = titles[index]
            infoView.dayLabel.text = "\(6-index)"
            infoView.monthLabel.text = "NOV"
            infoView.pageControl.currentPage = index
            infoView.weekLabel.text = pageArray[index]["week"]
        }
        
        scrollPage.setScrollPageViewDidSelectIndex {[weak self] (pageView, index) -> Void in
            let vc = BoardDetailViewController()

//            let vc = self?.loadVCFromSB("BoardDetailViewController") as! BoardDetailViewController
            let board = Board()
            board.title = pageArray[index]["title"]
            board.board_id = NSNumber(integer: (pageArray[index]["board"]! as NSString).integerValue)
            vc.board = board
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 2
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        //  设置collectionView的 四周的内边距
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.headerInset = UIEdgeInsetsMake(200, 0, 0, 0)
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.addSubview(scrollPage)
        
        self.collectionView.layoutIfNeeded()
        self.collectionView.registerNib(UINib(nibName: "XHWaterCollectionCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "XHWaterCollectionCell")
        self.collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                
        self.configNav()
        
    }
    
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
    
    func configNav() {
        
        let titleView = UIView(frame: CGRectMake(0, 0, 200, 50))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.onDiscoverBtnClick))
        titleView.addGestureRecognizer(tap)
        
        //frame: CGRectMake(0, 10, 80, 30)
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.textAlignment = NSTextAlignment.Right
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        
        //frame: CGRectMake(80, 15, 20, 20)
        let navImageView = UIImageView()
        navImageView.image = UIImage(named: "ic_explore_down")
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(navImageView)
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(titleView)
            make.centerX.equalTo(titleView).offset(-5)
        }

        navImageView.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(titleView)
            make.left.equalTo(titleLabel.snp_right)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        self.navigationItem.titleView = titleView
        
        // 搜索
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_search")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DiscoverViewController.onSearch))
    }
    
    
    func loadData(page: Int){
        
        self.request.page = page
        if page == 1 {
            self.request.max = nil
            titleLabel.text = self.categoryModel.name
        } else {
            self.request.max = self.dataSource.last?.pin_id
        }
        self.request.category = self.categoryModel
        request.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in
            
            if self.request.pins != nil {
                if page == 1 {
                    self.dataSource.removeAll()
                }
                
                self.currentPage = page
                
                self.dataSource.appendContentsOf(self.request.pins!)
            }
            
            self.collectionView.mj_header.endRefreshing()
            self.collectionView.mj_footer.endRefreshing()
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                
                print(err.localizedDescription)
                self.collectionView.mj_header.endRefreshing()
                self.collectionView.mj_footer.endRefreshing()
        }
    }
    
    func onSearch() {
        
        if (searchBar == nil) {
            
            //创建搜索框
            searchBar = UISearchBar()
            searchBar.sizeToFit()
            searchBar.delegate = self;
            searchBar.showsCancelButton = true;
            searchBar.tintColor = UIColor.redColor();
            searchBar.placeholder = "搜索你喜欢的"
            searchBar.searchBarStyle = UISearchBarStyle.Minimal;
            searchBar.translucent = false;
//            searchBar.barTintColor = UIColor.redColor()
//            searchBar.backgroundColor = UIColor.whiteColor()
            searchBar.insertBGColor(UIColor.whiteColor())

            self.navigationController?.view.addSubview(searchBar)
            searchBar.frame.origin.y = 20
            searchBar.frame.origin.x = kScreenWidth;

        }
        
        if (mySearchDisplayController == nil) {
            mySearchDisplayController = UISearchDisplayController(searchBar: searchBar, contentsController: self)
            mySearchDisplayController!.delegate = self;
            mySearchDisplayController!.searchResultsDataSource = self;
            mySearchDisplayController!.searchResultsDelegate = self;
            mySearchDisplayController!.setValue("没有啊~", forKey: "noResultsMessage")
            mySearchDisplayController!.displaysSearchBarInNavigationBar = false;
            mySearchDisplayController!.searchResultsTableView.tableFooterView = UIView()
            
        }
        
        self.navigationController?.view.bringSubviewToFront(self.searchBar)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchBar.frame.origin.x = 0;

            }) { (finish) -> Void in
                self.searchBar.becomeFirstResponder()
        }
    }
    
    //MARK: - 展示分类界面
    func onDiscoverBtnClick() {
        
        isShowCategory = !isShowCategory
        
        let arrow = self.navigationItem.titleView?.subviews.last
        
        self.rotateArrow(arrow)
        
        self.showCategoryTable(isShowCategory)
        
    }
    
    func rotateArrow(view: UIView?) {
        if view != nil {
            UIView.animateWithDuration(0.3, animations: { () -> () in
                view!.transform = CGAffineTransformRotate(view!.transform, 180 * CGFloat(M_PI/180))
            })
        }
    }
    
    func showCategoryTable(isShow: Bool) {
        if self.categoryTableView == nil {
            
            self.categoryTableView = XHCategoryTableView(frame: CGRectMake(0, 64, self.view.bounds.width, 0), style: UITableViewStyle.Grouped)
            
            self.view.addSubview(categoryTableView)
            
            self.categoryTableView.setDidSelectedRowAtIndexPath({[weak self] (tableView, indexPath, model) -> Void in
                self?.onDiscoverBtnClick()
                if self?.categoryModel != model {
                    self?.categoryModel = model
                    self?.loadData(1)
                }
            })
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            if isShow {
                self.categoryTableView.frame.size.height = self.view.bounds.height - 64
            } else {
                self.categoryTableView.frame.size.height = 0
                
            }
            
            self.hidesTabBar(isShow)
            
            }) { (finish) -> Void in
                self.categoryTableView.showTable(isShow)
        }
    }
    
    //MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (tableView == mySearchDisplayController?.searchResultsTableView) {//SearchDisplayController创建的TableView触发了事件
            //开始真正的搜索
            for i in 0..<10  {//遍历行
                self.searchResults.addObject("哈哈哈\(i)")
            }
            return 1;
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == mySearchDisplayController?.searchResultsTableView) {//SearchDisplayController创建的TableView触发了事件
            return searchResults.count;
        }
        
        //我自己创建的TableView触发了事件。
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "cellId";
        
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        if (tableView == mySearchDisplayController?.searchResultsTableView) {
            cell.textLabel!.text = searchResults[indexPath.row] as? String;
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (tableView == mySearchDisplayController?.searchResultsTableView) {
            let searchVC = SearchResultController()
            
            searchVC.searchStr = Safe.safeString(self.searchResults[indexPath.row] as? String)
            self.navigationController?.pushViewController(searchVC, animated: true)
        }
    }
    
    
    //MARK: - Search
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
//        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
//        searchBar.setShowsCancelButton(true, animated: true)
        
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            self.searchBar.frame.origin.x = 0;
//            }) { (finish) -> Void in
//                self.waterCollectView.collectionView.mj_header.hidden = true;
//                self.navigationController?.setNavigationBarHidden(true, animated: false)
//
//        }
//        self.showSuccess("试试看")
        
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
//        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if (searchBar.isFirstResponder()) {
            
            searchBar.resignFirstResponder()

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.searchBar.frame.origin.x = kScreenWidth;
                }) { (finish) -> Void in

            }

        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // 点击search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchVC = SearchResultController()
        searchVC.searchStr = Safe.safeString(self.searchBar.text)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    // 修改展示搜索结果的table Inset
    func searchDisplayController(controller: UISearchDisplayController, willShowSearchResultsTableView tableView: UITableView) {
        mySearchDisplayController?.searchResultsTableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
