//
//  CustomPageInfoView.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/7.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class CustomPageInfoView: UIView {
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
