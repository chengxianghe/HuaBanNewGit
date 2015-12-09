//
//  FileManagerExt.swift
//  HuaBanNew
//
//  Created by chengxianghe on 15/12/3.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

extension NSFileManager {
    
    
    static func createFile(path: String, data: NSData?, attributes: [String : AnyObject]?) -> Bool {
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            // 已经存在 删除
            self.removeItem(path)
        }
        
        return NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: attributes)
    }

    static func createDirectory(path: String) -> Bool {
        
        if self.isDirectory(path) {
            // 已经存在此文件夹
            return true
        }
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let error as NSError {
            // deal with error
            print ("create directory failed, error =: \(error.localizedDescription)")
            return false
        }
        
    }
    
    static func removeItem(path: String) -> Bool {
        if  !NSFileManager.defaultManager().fileExistsAtPath(path) {
            // 不存在此文件
            return true
        } else {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
                return true
            } catch let error as NSError {
                // deal with error
                print ("remove item failed, error =: \(error.localizedDescription)")
                return false
            }

        }
    }
    
    static func checkDirectory(path: String) -> (isExists: Bool, isDirectory: Bool) {
        var isDir: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory:&isDir) {
            if isDir {
                // file exists and is a directory
                return (true, true)
            } else {
                return (true, false)
            }
        } else {
            return (false, false)
        }
        
    }
    
    static func isDirectory(path: String) -> Bool {
        var isDir: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory:&isDir) {
            if isDir {
                // file exists and is a directory
                return true
            }
        }
        
        return false
    }
    
    //遍历文件夹获得文件夹大小，返回多少M
    static func folderSizeAtPath(folderPath: String) -> CGFloat {
        var totalSize: CGFloat = 0
        
        do {
            let list = try NSFileManager.defaultManager().subpathsOfDirectoryAtPath(folderPath)
            
//            print("all Files and Dirs:", list);
            
            for fileName in list {
                let fileAbsolutePath = folderPath.stringByAppendingString("/" + fileName)
                totalSize += self.fileSizeAtPath(fileAbsolutePath)
            }
            
        } catch let error as NSError {
            print ("folderSizeAtPath (Error): \(error.localizedDescription)")
        }
        return totalSize
    }
    
    //单个文件的大小
    static func fileSizeAtPath(filePath: String) -> CGFloat {
        let manager = NSFileManager.defaultManager()
        
        if manager.fileExistsAtPath(filePath) {
            
            do {
                let attr = try manager.attributesOfItemAtPath(filePath)
                
                return attr[NSFileSize] as! CGFloat
                
            } catch let error as NSError {
                // deal with error
                print("fileSizeAtPath (Error): \(error.localizedDescription)")
            }
            
        }
        
        return 0
    }

}
