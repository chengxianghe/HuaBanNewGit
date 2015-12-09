//
//  XHHuabanCollectionCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/1.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

typealias EditActionClosure = (model: Board) -> Void


class XHHuabanCollectionCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var boardNameLabel: UILabel!
    @IBOutlet weak var pinCountLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    var closuer: EditActionClosure?
    var model: Board!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    @IBAction func onEditBtnClick(sender: UIButton) {
        self.closuer?(model: self.model)
    }
    
    static func getSize(model: Board) -> CGSize {
    
        // 固定高度
        return CGSizeMake(itemWidth, itemWidth + 40)
    }
    
    func setInfo(model: Board) {
        
        self.model = model
        self.editBtn.hidden = true
        self.photoImageView.backgroundColor = UIColor.randomColor()
        self.photoImageView.image = nil;
        self.photoImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.pins?.first?.file?.realKey(ImageType.middle))), placeholder: nil)
        self.boardNameLabel.text = model.title
        self.pinCountLabel.text = "\(model.pin_count.intValue)"
        self.followCountLabel.text = "\(model.follow_count.intValue)"
        self.nameLabel.text = model.user?.username
    }
    
    func setInfo(model: Board, editBtnClick:EditActionClosure) {
        self.closuer = editBtnClick;
        self.setInfo(model)
        self.editBtn.hidden = model.user_id != AppUser.defaultUser.user_id

    }

    
}
