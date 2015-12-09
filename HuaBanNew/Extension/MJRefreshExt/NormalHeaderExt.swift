//
//  NormalHeaderExt.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/28.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh

extension MJRefreshNormalHeader {

    func huaBanHeaderConfig() {
        
        // 普通闲置状态的文字
//        self.setTitle("", forState: MJRefreshStateIdle)
        // 隐藏时间
        self.lastUpdatedTimeLabel?.hidden = true
    }


}
