//
//  NormalFooterExt.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/28.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
import MJRefresh

extension MJRefreshAutoStateFooter  {

    func huaBanFooterConfig() {
        
        /** 设置state状态下的文字 */
        self.setTitle("", forState: MJRefreshState.Idle)
        
        /** 设置是否 自动根据有无数据来显示和隐藏 */
        self.automaticallyHidden = false;
        
        /** 隐藏刷新状态的文字 */
        self.refreshingTitleHidden = true
    }

}
