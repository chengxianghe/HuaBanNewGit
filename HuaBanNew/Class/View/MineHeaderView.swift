//
//  MineHeaderView.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/9.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

typealias SelectIndexChangeClosure = (headView: MineHeaderView, from: NSInteger, to: NSInteger) -> Void
typealias OnFansLabelClosure = (headView: MineHeaderView) -> Void

class MineHeaderView: UIView,UIScrollViewDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var iconBtn: UIButton!
    var nameLabel: UILabel!
    var locationLabel: UILabel!
    var fansLabel: UILabel!
    var aboutLabel: UILabel!
    var about: UILabel!

    @IBOutlet weak var boardsCountLabel: UILabel!
    @IBOutlet weak var pinsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var saysCountLabel: UILabel!
    
    @IBOutlet weak var firstBtn: UIButton!
    weak var selectedBtn: UIButton!
    var selectClosure: SelectIndexChangeClosure?
    var fanslabel: OnFansLabelClosure?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func onBtnClick(sender: UIButton) {
        
        self.selectClosure?(headView: self, from: selectedBtn.tag, to: sender.tag)
        
        selectedBtn.selected = false
        selectedBtn.backgroundColor = UIColor.clearColor()
        selectedBtn = sender
        selectedBtn.selected = true
        selectedBtn.backgroundColor = UIColor(white: 0.8, alpha: 0.7)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bgImageView.contentMode = .ScaleAspectFill
        self.clipsToBounds = true
        
        selectedBtn = firstBtn
        self.onBtnClick(firstBtn)
        
        self.scrollView.delegate = self
        self.scrollView.scrollEnabled = true
        self.scrollView.contentSize = CGSizeMake(kScreenWidth * 2, 0)
        
        iconBtn = UIButton()
        iconBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.scrollView.addSubview(iconBtn)
        
        nameLabel = UILabel()
        nameLabel.textAlignment = .Center
        nameLabel.textColor = UIColor.whiteColor()
        self.scrollView.addSubview(nameLabel)
        
        
        locationLabel = UILabel()
        locationLabel.textAlignment = .Center
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.font = UIFont.systemFontOfSize(12)
        self.scrollView.addSubview(locationLabel)
        
        fansLabel = UILabel()
        fansLabel.textAlignment = .Center
        fansLabel.textColor = UIColor.whiteColor()
        fansLabel.backgroundColor = UIColor(white: 0.8, alpha: 0.4)
      
        let tap = UITapGestureRecognizer(target: self, action: "onFanslabel")
        fansLabel.addGestureRecognizer(tap)
        fansLabel.userInteractionEnabled = true
        self.scrollView.addSubview(fansLabel)
        

        // about
        about = UILabel()
        about.text = "关于我"
        about.textAlignment = .Center
        about.textColor = UIColor.whiteColor()
        self.scrollView.addSubview(about)
        
        aboutLabel = UILabel()
        aboutLabel.text = "暂无个人介绍"
        aboutLabel.textAlignment = .Center
        aboutLabel.numberOfLines = 0
        aboutLabel.textColor = UIColor.whiteColor()
        self.scrollView.addSubview(aboutLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconBtn.frame = CGRectMake(bounds.width/2 - 18, 30, 36, 36)
        iconBtn.addCorner(iconBtn.frame.width/2)
        
        nameLabel.frame = CGRectMake(20, iconBtn.frame.origin.y + iconBtn.frame.height + 4, kScreenWidth - 40, 25)
        locationLabel.frame = CGRectMake(20, nameLabel.frame.origin.y + nameLabel.frame.height + 4, kScreenWidth - 40, 20)
        
        fansLabel.frame = CGRectMake(60, bounds.height - 45 - 60, kScreenWidth - 120, 30)
        fansLabel.addCorner(15, borderWidth: 1, borderColor: UIColor.whiteColor(), isOnePx: true)

        about.frame = CGRectMake(kScreenWidth + 20, iconBtn.frame.origin.y, kScreenWidth - 40, 30)

        aboutLabel.frame = CGRectMake(kScreenWidth + 20, about.frame.origin.y + about.frame.height + 4, kScreenWidth - 40, bounds.height - 45 - 80)
        
    }
    
    func setInfo(model: User) {
        
        self.bgImageView.downloadImage(Url: NSURL(string: model.avatar as! String), placeholder: nil, success: { (imageURL, image) -> () in
            self.bgImageView.image = image.blurredImageWithRadius(120, iterations: 2, tintColor: UIColor.blackColor())

            }, failure: nil)
        
        
        self.iconBtn.downloadImage(Url: NSURL(string: model.avatar as! String), forState: .Normal)

        
        nameLabel.text  = model.username
        fansLabel.text  = "\(model.follower_count.intValue)粉丝 \(model.following_count.intValue)关注"
        aboutLabel.text = model.profile?.about
        
        boardsCountLabel.text   = "\(model.board_count)"
        pinsCountLabel.text     = "\(model.pin_count)"
        likesCountLabel.text    = "\(model.like_count)"

        aboutLabel.text = model.profile?.about
        locationLabel.text = model.profile?.location
        // 发言的 暂时没找到
    }
    
    func onFanslabel() {
        print("onFanslabel")
        self.fanslabel?(headView: self)
    }
    
    func setOnFanslabelClosure(fanslabel: OnFansLabelClosure?) {
        self.fanslabel = fanslabel
    }
    
    func setSelectIndexClosure(select: SelectIndexChangeClosure?) {
        self.selectClosure = select
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.pageControl.currentPage = Int((scrollView.contentOffset.x + (scrollView.frame.width/2)) / scrollView.frame.width)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
