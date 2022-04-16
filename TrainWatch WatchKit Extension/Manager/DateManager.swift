//
//  DateManager.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 04.01.22.
//

import Foundation

class DateManager {
    
    static func parseDate(isoString: String) -> Date {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return dateFormatter.date(from: isoString) ?? Date()
    }
    
    static func formatDate(isoString: String) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: parseDate(isoString: isoString))
    }
    
    static func calulateDelay(plannedDeparture: Date, actualDeparture: Date) -> String {
        let delta = plannedDeparture.distance(to: actualDeparture)
        let minuteDelta = delta / 60
        
        if minuteDelta != 0 {
            return "+" + String(Int(minuteDelta)) + "min"
        } else {
            return "On time"
        }
    }
    
    static func toIso8601DateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: date)
    }
    
    static func generateDateFromHourAndMinute(hour: Int, minute: Int) -> Date? {
        let now = Date()
        
        let yearDateFormatter = DateFormatter()
        yearDateFormatter.dateFormat = "yyyy"
        let yearString = yearDateFormatter.string(from: now)
        
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "M"
        let monthString = monthDateFormatter.string(from: now)
        
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "d"
        let dayString = dayDateFormatter.string(from: now)
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(yearString)
        dateComponents.month = Int(monthString)
        dateComponents.day = Int(dayString)
        dateComponents.hour = hour
        dateComponents.minute = minute

        let userCalendar = Calendar(identifier: .gregorian)
        return userCalendar.date(from: dateComponents)
    }
    
}
