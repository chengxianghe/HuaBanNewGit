//
//  XHWaterCollectionCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/1.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit
let oneTextHeight = "单行".sizeWithFontAndWidth(UIFont.systemFontOfSize(11), maxWidth: CGFloat.max).height

class XHWaterCollectionCell: UICollectionViewCell {
        
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var boardNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var repinCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var repinImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
//    var bgView: UIView!
    @IBOutlet weak var tagViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userView: UIView!
    var tapUserClosure: kCellActionClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(XHWaterCollectionCell.tapUserView))
        self.userView.addGestureRecognizer(tap)
    }
    
    func tapUserView() {
        self.tapUserClosure?(sender: nil)
    }
    
    static func getSize(model: Pin) -> CGSize {
        
        if model.cellSize == nil {
            
            if model.file != nil {
                
                if model.fileHeight == 0 {
                    let width = CGFloat(model.file!.width.floatValue)
                    let height = CGFloat(model.file!.height.floatValue)
                    
                    let curentHeight = itemWaterWidth / width * height
                    model.fileHeight = curentHeight
                }
                
                var textHeight: CGFloat = 0
                
                if model.raw_text?.length > 0 {
                    textHeight = model.raw_text!.sizeWithFontAndWidth(UIFont.systemFontOfSize(11), maxWidth: itemWaterWidth - 16).height
                    if textHeight >= 2 * oneTextHeight {
                        textHeight = 2 * oneTextHeight
                    }
                    textHeight += 16
                }                
                
                model.cellSize = CGSizeMake(itemWaterWidth, model.fileHeight + textHeight + (model.needUser == false ? 24 : 64))
            } else {
            
                print("没有高度" + model.pin_id.stringValue)
                model.cellSize = CGSizeMake(itemWaterWidth, 150 + 5 * CGFloat(random() % 10) * 5)
            }
        }
        return model.cellSize!;
    }
    
    func setCellActionClosure(closure: kCellActionClosure) {
        self.tapUserClosure = closure
    }
    
    func setInfo(model: Pin) {

        userView.hidden = model.needUser == false
        tagViewBottomConstraint.constant = userView.hidden ? 0 : 40
        if model.fileHeight == 0 {
            let width = CGFloat(model.file!.width.floatValue)
            let height = CGFloat(model.file!.height.floatValue)
            let curentHeight = itemWaterWidth / width * height
            model.fileHeight = curentHeight
        }
        
        self.photoHeightConstraint.constant = model.fileHeight;

        self.photoImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.file?.realKey(ImageType.middle))), placeholder: nil, success: {[weak self] (imageURL, image) -> () in
            self?.photoImageView.backgroundColor = UIColor.clearColor()
            }, failure: nil)
        
        self.iconImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.user?.avatar as? String)))
        
        self.nameLabel.text = model.user?.username
        self.boardNameLabel.text = model.board?.title
        self.repinCountLabel.text = "\(model.repin_count)"
        self.likeCountLabel.text = "\(model.like_count)"
        self.commentCountLabel.text = "\(model.comment_count)"
        
        self.infoLabel.text = model.raw_text        
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
////        self.contentView.layer.shadowPath = UIBezierPath.init(roundedRect: self.contentView.bounds, cornerRadius: 4).CGPath
//    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.backgroundColor = UIColor.randomColor()

    }
    
}
