//
//  XHCategoryTableView.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/7.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

//获取JSON数据
let path = NSBundle.mainBundle().pathForResource("categories", ofType: nil)

typealias DidSelectRowAtIndexPathClosure = (tableView: UITableView, indexPath: NSIndexPath, model: CategoryModel) -> Void

class XHCategoryTableView: UITableView,UITableViewDataSource,UITableViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    lazy var categoryDict: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: path!)!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
    
    var categorys: [NSDictionary]!
    
    var hasRecordCategorys = [NSDictionary]()
    var didSelectRow: DidSelectRowAtIndexPathClosure?
    
    func setDidSelectedRowAtIndexPath(select: DidSelectRowAtIndexPathClosure?) {
        self.didSelectRow = select
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        // 加载数据
        self.saveOrGetUserData(isSave: false)
        
        if self.categorys == nil {
            self.categorys = categoryDict["categories"] as! [NSDictionary]
        }

        self.delegate = self
        self.dataSource = self
        NomalImageTableCell.registerTable(self)
        CategoryTableCell.registerTable(self)
        CategoryHeaderView.registerTable(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func saveOrGetUserData(isSave isSave: Bool) {
        if isSave {
            XHSaveHelper.save(self.categorys, forKey: "HBCategories")
            XHSaveHelper.save(self.hasRecordCategorys, forKey: "hasRecordCategorys")
        } else {
            
            if let cate = XHSaveHelper.getAnyObjectForKey("HBCategories") as? [NSDictionary] {
                categorys = cate
            }
            
            if let hasRecord = XHSaveHelper.getAnyObjectForKey("hasRecordCategorys") as? [NSDictionary] {
                hasRecordCategorys = hasRecord
            }
            
        }
    }

    func showTable(isShow: Bool) {
        if isShow == false {
            self.saveOrGetUserData(isSave: true)
        }

    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.hasRecordCategorys.count == 0 ? 2 : 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.hasRecordCategorys.count == 0 {
            return section == 0 ? 1 : self.categorys.count
        } else {
            
            if section == 0 {
                return 2
            } else if section == 1 {
                return self.hasRecordCategorys.count
            } else {
                return self.categorys.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if hasRecordCategorys.count == 0 {
            
            let cell = CategoryTableCell.getReusableCell(tableView, indexPath: indexPath)
            
            cell.detailBtn.hidden = true
            if indexPath.section == 0 {
                cell.titleLabel.text = "最新"
            } else {
                // 所有分类
                cell.titleLabel.text = self.categorys[indexPath.row]["name"] as? String
            }
            
            return cell
        } else {
            
            if indexPath.section == 1 {
                let cell = NomalImageTableCell.getReusableCell(tableView, indexPath: indexPath)
                
                cell.titleLabel.text = self.hasRecordCategorys[indexPath.row]["name"] as? String
                cell.detailBtn.tag = indexPath.row
                cell.detailBtn.removeTarget(self, action: "deleteRecordCell:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.detailBtn.addTarget(self, action: "deleteRecordCell:", forControlEvents: UIControlEvents.TouchUpInside)
                
                return cell
            } else {
                let cell = CategoryTableCell.getReusableCell(tableView, indexPath: indexPath)
                cell.detailBtn.hidden = true
                
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        cell.titleLabel.text = "最新"
                        
                    } else {
                        cell.titleLabel.text = "发现"
                        cell.detailBtn.hidden = false
                        cell.detailBtn.setTitle("挑选自浏览过的分类", forState: UIControlState.Normal)
                    }
                    
                } else {
                    cell.titleLabel.text = self.categorys[indexPath.row]["name"] as? String
                }
                
                return cell
            }
        }
    }
    
    func deleteRecordCell(sender: UIButton) {
        
        let tag = sender.tag
        
        let dict = self.hasRecordCategorys[tag]
        self.hasRecordCategorys.removeAtIndex(tag)
        self.categorys.append(dict)

        if self.hasRecordCategorys.count > 0 {
            self.beginUpdates()
            
            self.deleteRowsAtIndexPaths([NSIndexPath(forRow: tag, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Left)
            self.insertRowsAtIndexPaths([NSIndexPath(forRow: self.categorys.count - 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Left)

            self.endUpdates()
            
            delay(0.3, task: { () -> () in
                if tag < self.hasRecordCategorys.count {
                    self.beginUpdates()
                    self.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.categorys.count - 1, inSection: 2)], withRowAnimation: UITableViewRowAnimation.Automatic)

                    // tag 最后一个 不用刷新  只要刷新tag 以及 之后的 即可
                    let indexPaths = (tag..<self.hasRecordCategorys.count).map { NSIndexPath(forItem: $0, inSection: 1) }
                    self.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                    self.endUpdates()
                    
                }
            })
            
        } else {
            
            self.reloadData()
            
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 && self.hasRecordCategorys.count == 0 {
            
            let model = CategoryModel().mj_setKeyValues(self.categorys[indexPath.row])

            self.hasRecordCategorys.append(self.categorys[indexPath.row])
            self.categorys.removeAtIndex(indexPath.row)
            
            self.didSelectRow?(tableView: self, indexPath: indexPath, model: model)

            self.reloadData()
            
        } else if indexPath.section == 2 {

            let model = CategoryModel().mj_setKeyValues(self.categorys[indexPath.row])

            self.hasRecordCategorys.insert(self.categorys[indexPath.row], atIndex: 0)
            self.categorys.removeAtIndex(indexPath.row)

            self.didSelectRow?(tableView: self, indexPath: indexPath, model: model)
            tableView.reloadData()

        } else {
            print(indexPath)
            var model: CategoryModel!

            if indexPath.section == 0 {
                model = indexPath.row == 0 ? AppURL.shareInstance.discoverModel : AppURL.shareInstance.latestModel

//                model.nav_link = indexPath.row == 0 ? "all" : ""
            } else if indexPath.section == 1 {
                model = CategoryModel().mj_setKeyValues(self.hasRecordCategorys[indexPath.row])
            }
            self.didSelectRow?(tableView: self, indexPath: indexPath, model: model)

        }
    }
    
    // Header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.hasRecordCategorys.count == 0 {
            
            if section == 1 {
                let header = CategoryHeaderView.getReusableHeaderFooterView(tableView, section: section)
                header?.textLabel?.text = section == 1 ? "浏览过的分类" : "其他分类"
                return header
            }
        } else {
            if section != 0 {
                let header = CategoryHeaderView.getReusableHeaderFooterView(tableView, section: section)
                
                header?.textLabel?.text = section == 1 ? "浏览过的分类" : "其他分类"
                return header
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 44
        }
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }


}
