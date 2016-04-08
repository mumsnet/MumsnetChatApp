//
//  ReadableDate.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 08/04/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import Foundation

extension NSDate {
    
    
    func readableDateShort() -> String {
        
        /* STRING           HOW RECENT?  */
        
        // Just now         (0 - 10s)
        // Xs ago           (10s - 60s)
        // Xm ago           (60s - 60m)
        // xx:xx            (60m - start of today)
        // Yesterday        (anytime yDay)
        // <Day of week>    (Beginnging of yDay - Beginning of 7 days ago)
        // dd/MM/yyyy       (Beyond a week ago)
        
        
        
        let seconds = abs(NSDate().timeIntervalSince1970 - self.timeIntervalSince1970)
        if seconds <= 10 {
            return "just now"
        }
        if seconds <= 60 {
            return "\(seconds)s ago"
        }
        
        // Xm ago           (60s - 60m)
        let minutes = Int(floor(seconds / 60))
        if minutes <= 60 {
            return "\(minutes)m ago"
        }
        
        // xx:xx            (60m - start of today)
        if self.isToday() {
            self.toString()
        }
        
        
        // Yesterday        (anytime yDay)
        if self.isYesterday() {
            return "Yesterday"
        }
        
        // <Day of week>    (Beginning of yDay - Beginning of 7 days ago)
        let startOfToday = self.dateAtStartOfDay()
        
        // Is within the last week
        if NSDate().dateByAddingDays(-6).isEarlierThanDate(startOfToday) {
            return self.weekdayToString()
        }
        
        // Default case
        // dd/MM/yyyy       (Beyond a week ago)
        return NSDateFormatter.insightddmmyy().stringFromDate(self)
        
        
        
//        let hours = minutes / 60
//        if hours <= 24 {
//            return "\(hours) hrs ago"
//        }
//        if hours <= 48 {
//            return "yesterday"
//        }
//        let days = hours / 24
//        if days <= 30 {
//            return "\(days) days ago"
//        }
//        if days <= 14 {
//            return "last week"
//        }
//        let months = days / 30
//        if months == 1 {
//            return "last month"
//        }
//        if months <= 12 {
//            return "\(months) months ago"
//        }
//        let years = months / 12
//        if years == 1 {
//            return "last year"
//        }
//        return "\(years) years ago"
    }
    
}


