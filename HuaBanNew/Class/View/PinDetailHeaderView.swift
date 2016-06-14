//
//  PinDetailHeaderView.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/16.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

typealias PinHeaderViewActionClosure = (model: Pin, index: NSInteger) -> Void

class PinDetailHeaderView: UIView {

    var model: Pin?
//    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var repinCountButton: UIButton!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var commentCountButton: UIButton!

    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var boardNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var myIconImageView: UIImageView!
    @IBOutlet weak var boardPhotoView: PhotoGroupView!
//    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    private var tapClosure: PinHeaderViewActionClosure?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setClickPinHeaderViewClosure(tap: PinHeaderViewActionClosure?) {
        self.tapClosure = tap
    }
    
    @IBAction func onClick(sender: UIButton) {
        /**
        tag: 0 = source
        tag: 1 = user
        tag: 2 = board
        tag: 3 = textField
        tag: 4 = share
        */
        self.tapClosure?(model: self.model!, index: sender.tag)
    }
    
    func setInfo(model: Pin) {
        
        self.model = model;
        
        if model.board?.pins?.count >= 4 {
            var array = [String]()
            for i in 0..<4 {
                array.append(model.board!.pins![i].file!.realKey(.min))
            }
            boardPhotoView.setImages(array)

        } else if model.board?.pins?.count > 0 {
            var array = [String]()
            for i in 0..<model.board!.pins!.count {
                array.append(model.board!.pins![i].file!.realKey(.min))
            }
            boardPhotoView.setImages(array)
        }
        
        self.descLabel.text = model.raw_text
        self.iconImageView.downloadImage(Url: NSURL(string: Safe.safeString(model.user?.avatar as? String)))
        self.boardNameLabel.text = model.board?.title
        self.userNameLabel.text = model.user?.username
        self.sourceLabel.text = model.source
        
        self.timeLabel.text = NSDate.dateFromStringOrNumber(model.created_at).huaBanTimeDescription()
        
        if model.repin_count.integerValue > 0 {
            self.repinCountButton.hidden = false
            self.repinCountButton.setTitle(" \(model.repin_count)", forState: .Normal)
        } else {
            self.repinCountButton.hidden = true
        }
        
        if model.like_count.integerValue > 0 {
            self.likeCountButton.hidden = false
            self.likeCountButton.setTitle(" \(model.like_count)", forState: .Normal)
        } else {
            self.likeCountButton.hidden = true
        }
        
        if model.comment_count.integerValue > 0 {
            self.commentCountButton.hidden = false
            self.commentCountButton.setTitle(" \(model.comment_count)", forState: .Normal)
        } else {
            self.commentCountButton.hidden = true
        }

        self.myIconImageView.downloadImage(Url: NSURL(string: AppUser.defaultUser().avatar))
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
class PhotoGroupView: UIView {
    
    enum SelfPhotoType : Int {
        case SelfPhotoTypeOne = 1
        case SelfPhotoTypeTwo = 2
        case SelfPhotoTypeThree = 3
        case SelfPhotoTypeFour = 4
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configFirst()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configFirst()
        
    }
    
    func configFirst() {
        for i in 0..<4 {
            let imageV = UIImageView(frame: self.frame)
            imageV.contentMode = UIViewContentMode.ScaleAspectFill;
            imageV.clipsToBounds = true;
            imageV.layer.borderWidth = 1.0;
            imageV.layer.borderColor = UIColor.whiteColor().CGColor;
            imageV.tag = 1000+i
            self.addSubview(imageV)
        }
    }
    
    func setImages(images: [String]) {
        
        if (images.count == 0) {
            self.hidden = true;
            return;
        } else {
            self.hidden = false
            if (images.count > 4) {
                self.setPhotoType(SelfPhotoType(rawValue: 4)!) ;
            } else {
                self.setPhotoType(SelfPhotoType(rawValue:images.count)!)
            }
            
            let count = min(images.count, 4)
            
            for i in 0..<count {
                let imageV = self.viewWithTag(1000+i) as! UIImageView
                imageV.downloadImage(Url: NSURL(string: images[i]))
            }
        }
        
    }
    
    func setPhotoType(photoType: SelfPhotoType) {
        let halfWidth = self.frame.size.width * 0.5;
        let halfHeight = self.frame.size.height * 0.5;
        
        for i in 0..<4 {
            let imageV = self.viewWithTag(1000+i) as! UIImageView
            imageV.frame = CGRectZero
        }
        
        if (photoType == .SelfPhotoTypeOne) {
            self.viewWithTag(1000+0)!.frame = self.bounds
            
        } else if (photoType == .SelfPhotoTypeTwo) {
            self.viewWithTag(1000+0)!.frame = CGRectMake(0, 0, halfWidth, halfHeight * 2)
            self.viewWithTag(1000+1)!.frame = CGRectMake(halfWidth, 0, halfWidth, halfHeight * 2)
            
        } else if (photoType == .SelfPhotoTypeThree) {
            self.viewWithTag(1000+0)!.frame = CGRectMake(0, 0, halfWidth, halfHeight * 2)
            self.viewWithTag(1000+1)!.frame = CGRectMake(halfWidth, 0, halfWidth, halfHeight)
            self.viewWithTag(1000+2)!.frame = CGRectMake(halfWidth, halfHeight, halfWidth, halfHeight)
            
        } else {
            self.viewWithTag(1000+0)!.frame = CGRectMake(0, 0, halfWidth, halfHeight)
            self.viewWithTag(1000+1)!.frame = CGRectMake(halfWidth, 0, halfWidth, halfHeight)
            self.viewWithTag(1000+2)!.frame = CGRectMake(0, halfHeight, halfWidth, halfHeight)
            self.viewWithTag(1000+3)!.frame = CGRectMake(halfWidth, halfHeight, halfWidth, halfHeight)
        }
        
    }
}
