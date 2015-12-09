//
//  BaseTableCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/3.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

enum CategoryCellType {
    case title
    case image
}

class BaseTableCell: UITableViewCell {

    class func getHeightWith(model: BaseModel) -> CGFloat {
        return 44
    }
    
    func setInfo(model: BaseModel) {
    
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
