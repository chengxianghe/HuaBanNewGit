//
//  TogetherListCell.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/14.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

class TogetherListCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var tipsBtn: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func getHeight() -> CGFloat {
        
        return 70
    }
    
    func setInfo(model: Topic) {
        
        self.iconImageView.downloadImage(Url:  NSURL(string: Safe.safeString(model.icon?.realImageKey)), placeholder: nil)
        self.nameLabel.text = model.title
      
        self.infoLabel.text = model.es_description
        self.tipsBtn.setTitle(model.post_count.stringValue, forState: UIControlState.Normal)
        
    }

    
}
