//
//  DateHelper.swift
//  log
//
//  Created by 4 on 2023.12.27.
//

import Foundation

class DateHelper: ObservableObject {
    static var main = DateHelper()
    
    @Published var day: String
    @Published var times: [Int] = []
    @Published var hourStrings: [Int: String] = [:]
    private var dayRef: Double = UserDefaults.standard.value(forKey: "day") as? Double ?? Date.now.timeIntervalSinceReferenceDate
    
    init() {
        day = DateHelper.dayString(for: Date(timeIntervalSinceReferenceDate: dayRef))
        UserDefaults.standard.setValue(dayRef, forKey: "day")
    }

    static func dayString(for date: Date = .now) -> String {
        let comp = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let yearString = String((comp.year ?? 1997) - 1997)
        return "," + yearString + "." + String(comp.month ?? 0) + "." + String(comp.day ?? 0)
    }
    
    private static func timeZoneOffset() -> Int {
        Calendar.current.timeZone.secondsFromGMT()
    }
    
    func changeDay(forward: Bool) {
//        dayRef +=
        // use https://developer.apple.com/documentation/foundation/datecomponents/1780435-isvaliddate
    }
    
    func loadTimes(lo: Int?, hi: Int?) {
        let offset = DateHelper.timeZoneOffset()
        let lo = min(-offset, lo ?? -offset)
        let hi = max(108000-offset, hi ?? 108000-offset)
        
        times = []
        
        var i = lo
        while i <= hi {
            times.append(i)
            i += 900
        }
        
        hourStrings = [:]
        
        for time in times {
            if (time + offset) % 3600 == 0 {
                hourStrings[time] = "," + String((time + offset)/3600)
            }
        }
    }
    
    func getTimeString(start: Int, duration: Int) -> String {
        let offset = DateHelper.timeZoneOffset()
        
        let startHour = String((start + offset)/3600)
        let startMinute = String(((start + offset + 360000) % 3600)/60)
        let startString = "," + startHour + "." + startMinute
        
        let end = start + duration*900
        let endHour = String((end + offset)/3600)
        let endMinute = String(((end + offset + 360000) % 3600)/60)
        let endString = "," + endHour + "." + endMinute
        
        return startString + " - " + endString
    }
    
    func currentTimeSlot() -> Int? {
        let now = Date.now
        let todayString = DateHelper.dayString(for: now)
        
        let currentTimeToday = (Int(now.timeIntervalSince(Calendar.current.startOfDay(for: now))) - DateHelper.timeZoneOffset())/900*900
        
        if day == todayString {
            return currentTimeToday
        }
        
        let tomorrow = DateHelper.dayString(for: now.addingTimeInterval(86400))
        if day == tomorrow {
            return currentTimeToday - 86400
        }
        
        let yesterday = DateHelper.dayString(for: now.addingTimeInterval(-86400))
        if day == yesterday {
            return currentTimeToday + 86400
        }
        
        return nil
    }
}
