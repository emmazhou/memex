//
//  Util.swift
//  Memex
//
//  Created by Emma Zhou on 10/14/20.
//

import Foundation

class Util {
    static func strip(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "EEEE, MMM dd"
        return formatter.string(from: date)
    }
    
    static func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    static func timeToDate(hour: Int, minute: Int) -> Date? {
        let today = Date()
        var calendar = Calendar.current
        calendar.timeZone = .current
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = hour
        components.minute = minute
        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: components)
    }
}
