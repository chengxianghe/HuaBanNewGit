//
//  TogetherViewController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/10/27.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh
import CHTCollectionViewWaterfallLayout
class TogetherViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var blankCell: UITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    
    let cellId = "TogetherListCell"
    let headId = "TogetherHeader"
    var currentPage = 0
    
    var requestTopic = TopicRequest()
    var topicDataSource = [Topic]() {
        didSet {
            self.startAnimate()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        tableView.sectionHeaderHeight = 35
        tableView.registerNib(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        tableView.registerClass(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: headId)        
    }
    
    func startAnimate() {
        
        self.tableView.alpha = 0
        self.tableView.reloadData()
        
        let tableHeight:CGFloat = self.tableView.bounds.size.height
        let cells:NSArray = self.tableView.visibleCells
        
        for a in 0 ..< cells.count {
            let cell:UITableViewCell = cells.objectAtIndex(a) as! UITableViewCell
            if(cell.isKindOfClass(UITableViewCell)){
                cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
                
            }
        }

        self.tableView.alpha = 1.0

        var index = 0
        
        for b in cells{
            let cell: UITableViewCell = b as! UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }

    }
    
    func setupNetWork() {
        self.loadData(1)

        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(1)
            })
        
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] () -> Void in
            self?.loadData(self!.currentPage + 1)
            
            })
        
        self.tableView.mj_footer.automaticallyHidden = false;

        
    }
    
    func loadData(page: Int){
        
        self.requestTopic.page = page
        requestTopic.requestWithRequestOption(.RefreshPriority, sucess: {[unowned self] (baseRequest) -> Void in

            if self.requestTopic.topics != nil {
                if page == 1 {
                    self.topicDataSource.removeAll()
                }
                self.topicDataSource.appendContentsOf(self.requestTopic.topics!)
                
                self.currentPage = page
                
                if self.requestTopic.topics?.count < 20 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                self.tableView.mj_header.endRefreshing()
            }
            
            }) {[unowned self] (baseRequest, err) -> Void in
                self.showError("加载失败")
                print(err)
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
        }
        
    }

    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return topicDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return blankCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TogetherListCell
            
            let model = topicDataSource[indexPath.row]
            
            cell.setInfo(model)
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TogetherListCell.getHeight()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //UITableViewHeaderFooterView
        
        let headerId = "TogotherHeader"
        
        var header: UITableViewHeaderFooterView! = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerId)
        
        if header == nil {
            header = UITableViewHeaderFooterView(reuseIdentifier: headerId)
            header?.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            
            let lab = UILabel()
            lab.text = section == 0 ? "我关注的话题" : "推荐话题";
            lab.font = UIFont.systemFontOfSize(12)
            header?.addSubview(lab)
            
            lab.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(header.snp_left).offset(12)
                make.centerY.equalTo(header.snp_centerY)
            })
            
        }
        return header;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            return
        }
        
        let topicVC = TopicDetailViewController()
//        topicVC.topicId = self.topicDataSource[indexPath.row].topic_id
        topicVC.topic = self.topicDataSource[indexPath.row]
        self.navigationController?.pushViewController(topicVC, animated: true)
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
