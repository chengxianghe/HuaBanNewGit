//
//  HBSayCollectionViewCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/9.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

typealias CellActionClosure = (cell: UICollectionViewCell, targetView: UIView) -> Void


class HBSayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var goodBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var repotBtn: UIButton!
    
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    private var tapPhotoClosure: CellActionClosure?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(HBSayCollectionViewCell.tapImage(_:)))
        self.photoImageView.removeGestureRecognizer(tap)
        self.photoImageView.addGestureRecognizer(tap)
        self.photoImageView.userInteractionEnabled = true
    }
    
    func setTapPhotoViewClosure(tap: CellActionClosure) {
        self.tapPhotoClosure = tap
    }
    
    func tapImage(sender: UITapGestureRecognizer) {
        self.tapPhotoClosure?(cell: self, targetView: sender.view!)
    }

    
    static func getHeight(model: Post) -> CGFloat {
        
        var curentHeight:CGFloat = 0
        if model.file != nil {
            
            let width = CGFloat(model.file!.width.floatValue)
            let height = CGFloat(model.file!.height.floatValue)
            
            curentHeight = itemTopicWidth / width * height
        }
        
        var labHeight: CGFloat = 0
        
        if model.raw_text?.length > 0 {
            labHeight = 10 + 10 + model.raw_text!.sizeWithFontAndWidth(UIFont.systemFontOfSize(14), maxWidth: itemTopicWidth).height
        }
            
        
        return curentHeight + 90 + labHeight
    }
    
    func setInfo(model: Post) {
//        self.photoImageView.backgroundColor = UIColor.randomColor()
        self.photoImageView.image = nil;
        
        self.photoImageView.downloadImage(Url:  NSURL(string: Safe.safeString(model.file?.realImageKey)), placeholder: nil)
        self.iconImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.user?.avatar as? String)))
        self.nameLabel.text = model.user?.urlname
        if model.file != nil {
            let width = CGFloat(model.file!.width.floatValue)
            let height = CGFloat(model.file!.height.floatValue)
            
            let curentHeight = itemTopicWidth / width * height
            photoHeightConstraint.constant = curentHeight;
        } else {
            photoHeightConstraint.constant = 0;
        }
        self.infoLabel.text = model.raw_text
        self.timeLabel.text = NSDate.dateFromStringOrNumber(model.created_at).customTimeDescription();
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
    }

}
