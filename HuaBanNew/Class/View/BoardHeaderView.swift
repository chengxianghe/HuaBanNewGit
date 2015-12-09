//
//  BoardHeaderView.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/6.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit



class BoardHeaderView: UIView {

    @IBOutlet weak var boardDetailBtn: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var pinCountLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    var action: kCellActionClosure?
    var shareAction: kCellActionClosure?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    @IBAction func onIconClick(sender: AnyObject) {
        action?(sender: nil)
    }
    
    @IBAction func onShareAction(sender: AnyObject) {
        shareAction?(sender: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    static func getHeight(model: Board) -> CGFloat {
        //
        var height: CGFloat = 86
        
        if model.es_description?.length > 0 {
            height +=  model.es_description!.sizeWithFontAndWidth(UIFont.systemFontOfSize(14), maxWidth: kScreenWidth - 20).height
        }
        return height
    }
    
    func setCellAction(action: kCellActionClosure?) {
        self.action = action
    }
    
    func setOnShareAction(action: kCellActionClosure?) {
        shareAction = action
    }
    
    func setInfo(model: Board) {
   
        self.infoLabel.text = model.es_description;
        self.pinCountLabel.text = "\(model.pin_count.intValue)"
        self.followCountLabel.text = "\(model.follow_count.intValue)"
        self.iconImageView.downloadImage(Url: NSURL(string: model.user!.avatar as! String))
        self.nameLabel.text = model.user!.username
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
