//
//  NSDateExt.swift
//  DateTest
//
//  Created by chengxianghe on 15/11/4.
//  Copyright © 2015年 CXH. All rights reserved.
//

import UIKit

extension NSDateFormatter {
    
    class var dateFormatter: NSDateFormatter {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: NSDateFormatter? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = NSDateFormatter()
        }
        return Static.instance!
    }
    
    static func dateFormatterWithFormat(dateFormat: String) -> NSDateFormatter {
        self.dateFormatter.dateFormat = dateFormat
        return self.dateFormatter
    }
    
    static func defaultDateFormatter() -> NSDateFormatter {
        return self.dateFormatterWithFormat("yyyy-MM-dd HH:mm:ss")
    }
    
}

let k_MINUTE: NSTimeInterval    = 60
let k_HOUR: NSTimeInterval      = 3600
let k_DAY: NSTimeInterval       = 86400
let k_WEEK: NSTimeInterval      = 604800
let k_YEAR: NSTimeInterval      = 31556926

extension NSDate {
    
    //MARK: - 转成本地时间
    static func changeDateToLocalDate(date: NSDate) -> NSDate {
        let zone = NSTimeZone.systemTimeZone()
        let interval = Double(zone.secondsFromGMTForDate(date))
        let localDate = date.dateByAddingTimeInterval(interval)
        return localDate;
    }
    
    //MARK: - 从字符串或者NSNumber得到NSDate
    static func dateFromStringOrNumber(dateString: AnyObject) -> NSDate {
        var dateString = dateString
        if let dateNum = dateString as? NSNumber {
            dateString = dateNum.stringValue
        }
        
        if let dateStr = dateString as? NSString {
            
            let date = NSDateFormatter.defaultDateFormatter().dateFromString(dateStr as String)
            if date != nil {
                return date!
            }
            
            if dateStr.length > 10 {
                dateString = dateStr.substringToIndex(10)
            }
            
            return NSDate(timeIntervalSince1970: dateStr.doubleValue);
        }
        
        return NSDate()
    }
    
    //MARK: 时间描述
    func customTimeDescription() -> String {
        
        let dateFormatter = NSDateFormatter.dateFormatterWithFormat("MM-dd")
        
        let timeInterval = -self.timeIntervalSinceNow
        
        if timeInterval < 0 { //还未发生的时间
            return "未来";
        } else if timeInterval <= k_MINUTE {
            return "刚刚";
        } else if (timeInterval < k_HOUR) { // 1小时以内
            return String(format:"%.f分钟前", timeInterval / k_MINUTE)
        } else if (timeInterval < k_DAY) { // 24小时以内
            return String(format:"%.f小时前", timeInterval / k_HOUR)
        } else {
            // 以下需要新的计算
            // 今天已经过去的时间
            let timeIntervalDay = timeInterval - NSDate.currentDayLostTime(NSDate())
            
            dateFormatter.dateFormat = "HH:mm"

            if (timeIntervalDay < k_DAY) {// 当天以外的24小时以内
                return String(format:"昨天%@", dateFormatter.stringFromDate(self))
            } else if (timeIntervalDay < k_DAY * 2) {// 前天
                return String(format:"前天%@", dateFormatter.stringFromDate(self))
            } else if (timeIntervalDay < k_WEEK) {//一周内
                return String(format:"%.f天前", timeIntervalDay/k_DAY)
            } else {
                // 今年已经过去的时间
                let timeIntervalThisYear = NSDate.currentYearLostTime(NSDate())
                
                if (timeInterval < timeIntervalThisYear){ //一周至1年内
                    dateFormatter.dateFormat = "MM-dd"
                    return dateFormatter.stringFromDate(self)
                } else { // 不在今年了
                    let timeIntervalYear = timeInterval - NSDate.currentYearLostTime(NSDate())
                    
                    return String(format:"%.f年前", timeIntervalYear / k_YEAR + 1)
                }
            }
        }
    }
    
    func standardTimeDescription(string: String = "yyyy-MM-dd HH:mm:ss") -> String {
        return NSDateFormatter.dateFormatterWithFormat(string).stringFromDate(self);
    }
    
    func huaBanTimeDescription() -> String {
        return NSDateFormatter.dateFormatterWithFormat("yyyy年MM月dd日 HH:mm").stringFromDate(self);
    }
    
    /*标准时间日期描述*/
    func formattedTimeDescription() -> String {
        
        let formatter = NSDateFormatter.dateFormatter
        formatter.dateFormat = "YYYYMMdd"
        
        let dateNow = formatter.stringFromDate(NSDate()) as NSString
        let components = NSDateComponents()
        
        components.day = (dateNow.substringWithRange(NSMakeRange(6, 2)) as NSString).integerValue
        components.month = (dateNow.substringWithRange(NSMakeRange(4, 2)) as NSString).integerValue
        components.year = (dateNow.substringWithRange(NSMakeRange(0, 4)) as NSString).integerValue
        
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = gregorian?.dateFromComponents(components) //今天 0点时间
        
        let hour = self.hoursAfterDate(date!)
        //    NSLog("hour:%ld, 今天0点:%",hour, [NSDate changeDateToLocalDate:date]);
        
        var dateFormatter:NSDateFormatter!
        
        //hasAMPM==TURE为12小时制，否则为24小时制
        let formatStringForHours = NSDateFormatter.dateFormatFromTemplate("f", options: 0, locale: NSLocale.currentLocale())
        
        let containsA = formatStringForHours?.rangeOfString("a")
        let hasAMPM = containsA?.isEmpty != nil;
        if (!hasAMPM) { //24小时制
            if (hour <= 24 && hour >= 0) {
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("HH:mm")
            }else if (hour < 0 && hour >= -24) {
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("昨天HH:mm")
            }else {
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("yyyy-MM-dd")
            }
        }else {
            if (hour >= 0 && hour < 1) { // 00:00 - 01:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("零点00:mm")
            }else if (hour >= 1 && hour < 6) { // 01:00 - 06:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("凌晨hh:mm")
            }else if (hour >= 6 && hour < 12 ) { // 06:00 - 12:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("上午hh:mm")
            }else if (hour >= 12 && hour < 13 ) { // 12:00 - 13:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("中午hh:mm")
            }else if (hour >= 13 && hour < 18) { // 13:00 - 18:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("下午hh:mm")
            }else if (hour >= 18 && hour < 24) { // 18:00 - 24:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("晚上hh:mm")
            }else if (hour < 0 && hour >= -24){ // 18:00 - 24:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("昨天HH:mm")
            }else { // 18:00 - 24:00
                dateFormatter = NSDateFormatter.dateFormatterWithFormat("yyyy-MM-dd")
            }
            
        }
        
        let ret = dateFormatter.stringFromDate(self)
        return ret
    }
    
    
    //MARK: - Retrieving Intervals
    func secondsAfterDate(aDate: NSDate)-> NSInteger {
        
        let ti = self.timeIntervalSinceDate(aDate)
        return NSInteger(ti);
    }
    
    
    func  minutesAfterDate(aDate: NSDate)-> NSInteger
    {
        let ti = self.timeIntervalSinceDate(aDate)
        return (NSInteger) (ti / k_MINUTE);
    }
    
    func  minutesBeforeDate(aDate: NSDate)-> NSInteger
    {
        let ti = aDate.timeIntervalSinceDate(self)
        
        return (NSInteger) (ti / k_MINUTE);
    }
    
    func  hoursAfterDate(aDate: NSDate)-> NSInteger
    {
        let ti = self.timeIntervalSinceDate(aDate)
        return (NSInteger) (ti / k_HOUR);
    }
    
    func  hoursBeforeDate(aDate: NSDate)-> NSInteger
    {
        let ti = aDate.timeIntervalSinceDate(self)
        return (NSInteger) (ti / k_HOUR);
    }
    
    func  daysAfterDate(aDate: NSDate)-> NSInteger
    {
        // 这样的不准确 是按24小时来算天数的
        //let ti = self.timeIntervalSinceDate(aDate)
        //    return (NSInteger) (ti / k_DAY);
        
        return NSDate.daysBetweenBegainDate(aDate, andEndDate:self)
    }
    
    func  daysBeforeDate(aDate: NSDate)-> NSInteger
    {
        //    let ti = aDate.timeIntervalSinceDate(self)
        //    return (NSInteger) (ti / k_DAY);
        return NSDate.daysBetweenBegainDate(self, andEndDate:aDate)
    }
    
    
    static func daysBetweenBegainDate(begainDate: NSDate, andEndDate endDate :NSDate) -> NSInteger {
        // 总时间差
        var totalTime = endDate.timeIntervalSince1970 - begainDate.timeIntervalSince1970
        
        // 计算开始当天剩余的时间
        let todayRemainTime = NSDate.currentDayRemainTime(begainDate)
        
        var days = 0;
        
        // 如果开始当天余下的时间大于时间差,则间隔天数为0
        if (todayRemainTime > totalTime) {
            days = 0;
        } else {
            // 今天以外的剩余时间差 = 总时间差 - 开始当天余下的时间
            totalTime -= todayRemainTime;
            // 间隔天数 = 开始当天 + 剩余时间差/一天时间
            days = NSInteger(1 + totalTime / k_DAY)
            
        }
        
        return days
    }
    
    static func daysToNowWithBegainDate(begainDate: NSDate) -> NSInteger {
        
        return self.daysBetweenBegainDate(begainDate, andEndDate: NSDate())
    }
    
    //MARK: - 计算剩余时间 已过时间
    static func currentDayRemainTime(currentData: NSDate) -> NSTimeInterval {
        
        let format = NSDateFormatter.dateFormatterWithFormat("HH:mm:ss")
        
        let todayTimeStr = format.stringFromDate(currentData)
        
        let arr = todayTimeStr.componentsSeparatedByString(":")
        
        let hour = (arr[0] as NSString).doubleValue
        let minute = (arr[1] as NSString).doubleValue
        let second = (arr[2] as NSString).doubleValue
        
        let todayRemainTime = k_DAY - hour*k_HOUR - minute*k_MINUTE - second;
        
        return todayRemainTime;
    }
    
    // 计算当天已经过的时间
    static func currentDayLostTime(currentData: NSDate) -> NSTimeInterval {
        let format = NSDateFormatter.dateFormatterWithFormat("HH:mm:ss")
        
        let todayTimeStr = format.stringFromDate(currentData)
        
        let arr = todayTimeStr.componentsSeparatedByString(":")
        
        let hour = (arr[0] as NSString).doubleValue
        let minute = (arr[1] as NSString).doubleValue
        let second = (arr[2] as NSString).doubleValue
        
        
        let todayRemainTime = hour*k_HOUR + minute*k_MINUTE + second;
        
        return todayRemainTime;
    }
    
    // 计算当年已经过的时间(一年内)
    static func currentYearLostTime(currentData: NSDate) -> NSTimeInterval {
        
        // 当年已经过的总时间
        let totalTime = currentData.timeIntervalSince1970
        let format = NSDateFormatter.dateFormatterWithFormat("yyyy")
        
        let yearTimeString = format.stringFromDate(currentData)
        
        // 今年年初的时间
        let yearTime = format.dateFromString(yearTimeString)!.timeIntervalSince1970
        
        // 当年剩下的时间
        return totalTime - yearTime;
    }
    
    //MARK: is判断
    //MARK: 判断现在是否在一段时间内
    static func isInCurrentTimeWithStart(start: String, andEnd end: String) -> Bool {
        
        let dateFormatter = NSDateFormatter.dateFormatterWithFormat("yyyy-MM-dd HH:mm:ss")
        
        let begainDate = dateFormatter.dateFromString(start) // 开始的年月日
        let endDate = dateFormatter.dateFromString(end) //结束的年月日
        
        let begainTime = begainDate?.timeIntervalSince1970
        let endTime = endDate?.timeIntervalSince1970
        
        let nowTime = NSDate().timeIntervalSince1970
        
        if (nowTime > begainTime && nowTime < endTime) {
            return true;
        }
        
        return false;
    }
    
    //MARK: 判断是不是今天
    static func isToday(date: NSDate) -> Bool {
        let format = NSDateFormatter.dateFormatterWithFormat("dd")
        
        let todayTimeString = format.stringFromDate(NSDate())
        let dateString = format.stringFromDate(date)
        
        return dateString == todayTimeString
    }
    
}
