//
//  NomalImageTableCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/2.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class NomalImageTableCell: UITableViewCell {

    @IBOutlet weak var detailBtn:UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    static func registerTable(table: UITableView) {
        table.registerNib(UINib(nibName: "NomalImageTableCell", bundle: nil), forCellReuseIdentifier: "NomalImageTableCell")
    }

    static func getReusableCell(table: UITableView, indexPath: NSIndexPath) -> NomalImageTableCell {
        return table.dequeueReusableCellWithIdentifier("NomalImageTableCell", forIndexPath: indexPath) as! NomalImageTableCell
    }
    
    
    static func getHeight() -> CGFloat {
            return 44
    }
    
    
    func setInfo() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
