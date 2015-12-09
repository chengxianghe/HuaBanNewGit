//
//  BaseNavgationController.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/22.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class BaseNavgationController: UINavigationController,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer?.delegate = self.topViewController as? UIGestureRecognizerDelegate
        self.delegate = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Push {
            if fromVC.classForCoder == PinDetailViewController.classForCoder() {
                let vc = fromVC as! PinDetailViewController
                
                return vc.navigationController(navigationController, animationControllerForOperation: operation, fromViewController: fromVC, toViewController: toVC, targetView: vc.selectedView)
            } else if toVC.classForCoder == PinDetailViewController.classForCoder() {
                let vc = toVC as! PinDetailViewController

                return vc.navigationController(navigationController, animationControllerForOperation: operation, fromViewController: fromVC, toViewController: toVC, targetView: vc.popSelectedView)

            } else {
                return nil
            }
         

        } else if operation == .Pop && fromVC.classForCoder == PinDetailViewController.classForCoder() {

            let vc = fromVC as! PinDetailViewController
            return vc.navigationController(navigationController, animationControllerForOperation: operation, fromViewController: fromVC, toViewController: toVC, targetView: vc.popSelectedView)

        } else {
            return nil
        }
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
