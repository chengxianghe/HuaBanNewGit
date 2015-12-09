//
//  AlertExt.swift
//  JokeMusic
//
//  Created by chengxianghe on 15/10/30.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @available(iOS 8.0, *)
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        if actions != nil {
            for act in actions! {
                alert.addAction(act)
            }
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @available(iOS 8.0, *)
    func showActionSheet(title: String?, message: String?, actions: [UIAlertAction]?) {
        
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        if actions != nil {
            for act in actions! {
                actionSheet.addAction(act)
            }
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

}