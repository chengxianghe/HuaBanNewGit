//
//  AppURL.swift
//  MyHuaBan
//
//  Created by chengxianghe on 15/11/3.
//  Copyright © 2015年 CXH. All rights reserved.
//

import Foundation

let baseUrl = "http://api.huaban.com"

// 图片测试路径
// http://img.hb.aicdn.com/42a511c692c2b73de1e8143a9437bd935ee7062b22c4e7-CntJwg_fw320
// http://hb-topic-img.b0.upaiyun.com/aa0cdcdbb5233b2e7bde70ff9ba0e0fa2121453538eb7-KEaPUK
// http://img.hb.aicdn.com/3e4168fb896f43e96c1a169dfa8793f1a1647467829a2-0aiHEx
// http://img.hb.aicdn.com/78085d94a0de5bdf32046a71d94d6faff6ccf9a0626-5bYLN8

/// hbfile: http://hbfile.b0.upaiyun.com/img/home/banner/2d1bbfea4e4a9c1589879b8c8dc85fc96c5ea653310b2
/// http://img.hb.aicdn.com/402846a217994624debbe699c41ee002aba208091b863-7BQtwF_fw658
//列表小图 http://img.hb.aicdn.com/daa44953fc2ff0ef4b7c39b152aa8d19ecc85759e09d-AxWwdW_fw192
//详情大图 http://img.hb.aicdn.com/daa44953fc2ff0ef4b7c39b152aa8d19ecc85759e09d-AxWwdW_fw554
let baseImage = "http://img.hb.aicdn.com/"
let baseFile =  "http://hbfile.b0.upaiyun.com/"
let baseTopic = "http://hb-topic-img.b0.upaiyun.com/"

let imageSize192 = "_fw192"
let imageSize320 = "_fw320"
let imageSize554 = "_fw554"
let imageSize658 = "_fw658"
// 头像
let imageSize75  = "_sq75"
let imageSize140  = "_sq140"

class AppUser : NSObject
{
    
    // 资源多
    var urlname = "aocknqhy"
    var user_id: NSNumber = 15375173
    var username = "ミ獨家試愛丶"
    var avatar = "http://img.hb.aicdn.com/2c20ac1d01e64f122adaf1219320306c0eb0e8532d1a-2iokJg_sq75"
    
    override init() {
        super.init()
    }
    
    class var defaultUser: AppUser {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AppUser? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = AppUser()
            //            if let dict = XHSaveHelper.getAnyObjectForKey("DefaultUser") {
            //                Static.instance?.mj_setKeyValues(dict)
            //            }
        }
        return Static.instance!
    }
    
    func updateUser(model: User) {
        self.user_id = model.user_id
        self.username = model.username
        self.urlname = model.urlname
        self.avatar = model.avatar as! String
        
        XHSaveHelper.save(self.mj_keyValues(), forKey: "DefaultUser\(self.user_id)")
    }
}


class AppURL {
    
    //{"id":"home","name":"家居/装饰","group":0,"nav_link":"/favorite/home/"}
    let discoverModel = CategoryModel().mj_setKeyValues(["name":"发现", "nav_link":"/all"])
    let latestModel = CategoryModel().mj_setKeyValues(["name":"最新", "nav_link":"/all"])
    
    class var shareInstance: AppURL {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AppURL? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = AppURL()
        }
        return Static.instance!
    }
    
    enum getDataList: String {
        case categories = "/categories/" //获取分类列表
        
        /**
        http://huaban.com/mobile_topics/75/posts? 朋友圈必备图
        */
        //http://api.huaban.com/mobile_topics/featured
        case topicIds = "/mobile_topics/featured" // 获取id
        
    }
    
    /**
     {"id":"beauty","name":"美女","group":5,"nav_link":"/favorite/beauty/"}
     */
    func discoverCategory(category: String) -> String {
        //http://api.huaban.com/favorite/beauty  "nav_link":"/favorite/games/"
        return String(format: "http://api.huaban.com%@", category)
    }
    
    enum SearchType: String {
        case pin    = "pin" // 采集
        case boards = "boards" // 画板
        case people = "people" // 用户
        case gift   = "gift" // 用户
        
    }
    //http://huaban.com/zpalzqleic/following/boards
    
    enum UserInfoType: String {
        
        //http://huaban.com/zpalzqleic/likes/boards/
        case commodities = "商品"
        case likes = "likes" // 喜欢的采集 默认//http://huaban.com/zpalzqleic/likes/?igm95w0i&max=39032023&limit=20&wfl=1
        //        case likesBoards = "likes/boards" //喜欢的画板//http ://huaban.com/zpalzqleic/likes/boards/?igm972wk&limit=20&wfl=1
        case pins   = "pins" // 采集
        case people = "people" // 用户
        case boards = "boards"// 默认就是画板
    }
    
    enum FollowType: String {
        case followers = "followers" // 粉丝
        case following = "following" // 关注 默认关注的人
        case followExplores = "following/explores" // 关注的兴趣点
        case followBoards = "following/boards" // 关注的画板
    }
    
    // 热门
    enum PopularType: String {
        case pin    = "/popular" // 热门采集
        case board  = "/boards/popular/" // 热门画板
        case user   = "/users/popular/" // 热门推荐用户
    }
    
    static func search(str: String) -> String {
        return self.search(str, categoryName: nil, type: nil)
    }
    
    static func search(str: String, categoryName: String?, type: SearchType?) -> String {
        //http ://huaban.com/search/?q=%E5%A9%9A%E7%BA%B1&md=404in
        //http ://huaban.com/search/?q=%E5%96%B5%E6%98%9F%E4%BA%BA&category=anime
        //http ://huaban.com/search/?q=%E5%96%B5%E6%98%9F%E4%BA%BA
        //http ://huaban.com/search/gift/?q=%E5%96%B5%E6%98%9F%E4%BA%BA
        //http ://huaban.com/search/boards/?q=%E5%96%B5%E6%98%9F%E4%BA%BA
        //http ://huaban.com/search/people/?q=%E5%96%B5%E6%98%9F%E4%BA%BA
        
        let typeStr = type == nil ? "" : type!.rawValue
        let cateStr = categoryName == nil ? "" : ("&category=" + categoryName!)
        
        let searchStr = String(format: "%@/search/%@/?q=%@%@", baseUrl, typeStr, str, cateStr)
        
        return searchStr
    }
}

