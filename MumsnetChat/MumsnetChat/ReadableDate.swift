//
//  ReadableDate.swift
//  MumsnetChat
//
//  Created by Tim Windsor Brown on 08/04/2016.
//  Copyright © 2016 MumsnetChat. All rights reserved.
//

import Foundation

public extension NSDate {
    
    
    func readableDateShort() -> String {
        
        /* STRING           HOW RECENT?  */
        
        // Just now         (0 - 10s)
        // Xs ago           (10s - 60s)
        // Xm ago           (60s - 60m)
        // xx:xx            (60m - start of today)
        // Yesterday        (anytime yDay)
        // <Day of week>    (Beginnging of yDay - Beginning of 7 days ago)
        // dd/MM/yyyy       (Beyond a week ago)
        
        
        if self.isInFuture() {
            // Future date, default to 'just now'
            return "Just now"
        }
        
        let seconds = abs(NSDate().timeIntervalSince1970 - self.timeIntervalSince1970)
        if seconds <= 10 {
            return "Just now"
        }
        if seconds <= 60 {
            return "\(Int(seconds))s ago"
        }
        
        // Xm ago           (60s - 60m)
        let minutes = Int(floor(seconds / 60))
        if minutes <= 60 {
            return "\(minutes)m ago"
        }
        
        // xx:xx            (60m - start of today)
        if self.isToday() {
            return self.toString(format: DateFormat.ISO8601(ISO8601Format.HoursMinutes))
        }
        
        
        // Yesterday        (anytime yDay)
        if self.isYesterday() {
            return "Yesterday"
        }
        
        // <Day of week>    (Beginning of yDay - Beginning of 7 days ago)
        let startOfToday = self.dateAtStartOfDay()
        
        // Is within the last week
        if NSDate().dateByAddingDays(-7).isEarlierThanDate(startOfToday) {
            return self.weekdayToString()
        }
        
        
        // Default case
        // 01/04/2016
        return self.toString(format: DateFormat.ISO8601(ISO8601Format.DateOnlyReadable))
    }
    
    func readableDateLong() -> String {
        
        /* STRING           HOW RECENT?  */
        
        // Today mm:HH              (0s - start of today)
        // Yesterday mm:HH          (anytime yDay)
        // Saturday mm:HH           (Beginnging of yDay - Beginning of 7 days ago)
        // Fri 1 Apr, mm:hh         (Beyond a week ago)
        // Fri 1 Apr 2015, mm:hh    (A previous year)
        
        
        if self.isInFuture() {
            // Rogue future date, default to Fri 1 Apr, mm:hh
            return self.toString(format: DateFormat.ISO8601(ISO8601Format.DateTimeReadable))
        }
        
        // Today mm:HH              (0s - start of today)
        if self.isToday() {
            return "Today " + self.toString(format: DateFormat.ISO8601(ISO8601Format.HoursMinutes))
        }
        
        // Yesterday mm:HH          (anytime yDay)
        if self.isYesterday() {
            return "Yesterday " + self.toString(format: DateFormat.ISO8601(ISO8601Format.HoursMinutes))
        }
        
        // Saturday mm:HH           (Beginnging of yDay - Beginning of 7 days ago)
        let startOfToday = self.dateAtStartOfDay()
        
        // Is within the last week
        if NSDate().dateByAddingDays(-7).isEarlierThanDate(startOfToday) {
            return self.toString(format: DateFormat.ISO8601(ISO8601Format.DayTimeReadable))
        }
        
        if self.isThisYear() {
            // Fri 1 Apr, mm:hh         (Beyond a week ago)
            return self.toString(format: DateFormat.ISO8601(ISO8601Format.DateTimeReadable))
        }
        else { // Is a previous year
            // Fri 1 Apr 2015, mm:hh    (A previous year)
            return self.toString(format: DateFormat.ISO8601(ISO8601Format.DateTimeYearReadable))
        }
        
    }
}



