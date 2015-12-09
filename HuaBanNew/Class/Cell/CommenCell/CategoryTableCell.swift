//
//  CategoryTableCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/2.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit



class CategoryTableCell: BaseTableCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailBtn: UIButton!

    static func registerTable(table: UITableView) {
        table.registerNib(UINib(nibName: "CategoryTableCell", bundle: nil), forCellReuseIdentifier: "CategoryTableCell")
    }
    
    static func getReusableCell(table: UITableView, indexPath: NSIndexPath) -> CategoryTableCell {
        return table.dequeueReusableCellWithIdentifier("CategoryTableCell", forIndexPath: indexPath) as! CategoryTableCell

    }
    
    override static func getHeightWith(model: BaseModel) -> CGFloat {
        return 44
    }
    
    override func setInfo(model: BaseModel) {
        
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.text = "呵呵"
        
        self.detailBtn.setTitle("你妹", forState: UIControlState.Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
