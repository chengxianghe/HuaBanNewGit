//
//  XHHuabanCollectionCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/1.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit



class XHUserCollectionCell: UICollectionViewCell {

    typealias FollowActionClosure = (isToFollow: Bool) -> Void
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    var followClosure: FollowActionClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.followBtn.addTarget(self, action: "onFollowBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)

    }
    
    func setFollowBtnClosure(followClosure: FollowActionClosure?) {
        self.followClosure = followClosure
    }
    
    func onFollowBtnClick(sender: UIButton) {
        self.followClosure?(isToFollow: !sender.selected)
    }

    
    static func getHeight(model: User) -> CGFloat {
    
        // 固定高度
        return itemWidth - 10
    }
    
    func setInfo(model: User) {
        self.photoImageView.image = nil;
        self.photoImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.avatar as? String)), placeholder: nil)
        self.followCountLabel.text = "\(model.follower_count.intValue)粉丝"
        self.nameLabel.text = model.username
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
    }

}
