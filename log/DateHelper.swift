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
    @Published var currentTimeSlot: Int? = nil
    private var dateRef: DateComponents
    
    init() {
        let year = UserDefaults.standard.value(forKey: "year") as? Int ?? 2024
        let month = UserDefaults.standard.value(forKey: "month") as? Int ?? 1
        let day = UserDefaults.standard.value(forKey: "day") as? Int ?? 1
        
        let dateRef = DateComponents(year: year, month: month, day: day)
        
        self.dateRef = dateRef
        self.day = DateHelper.dayString(from: dateRef)
    }

    static func dayString(from date: DateComponents) -> String {
        let yearString = String((date.year ?? 2024) - 1997)
        return yearString + "." + String(date.month ?? 1) + "." + String(date.day ?? 1)
    }
    
    private static func timeZoneOffset() -> Int {
        Calendar.current.timeZone.secondsFromGMT()
    }
    
    func changeDay(forward: Bool) {
        let dateRefDate = Calendar.current.date(from: dateRef) ?? .now
        let newDate = Calendar.current.date(byAdding: .day, value: forward ? 1 : -1, to: dateRefDate) ?? .now
        dateRef = Calendar.current.dateComponents([.year, .month, .day], from: newDate)
        day = DateHelper.dayString(from: dateRef)
        
        UserDefaults.standard.setValue(dateRef.year ?? 2024, forKey: "year")
        UserDefaults.standard.setValue(dateRef.month ?? 1, forKey: "month")
        UserDefaults.standard.setValue(dateRef.day ?? 1, forKey: "day")
    }
    
    func loadTimes(lo: Int?, hi: Int?) {
        let offset = DateHelper.timeZoneOffset()
        let lo = min(-offset, lo ?? -offset)
        let hi = max(108000-offset, hi ?? 108000-offset)
        
        var tempTimes: [Int] = []
        
        var i = lo
        while i <= hi {
            tempTimes.append(i)
            i += 900
        }
        
        var tempHourStrings: [Int: String] = [:]
        
        for time in tempTimes {
            if (time + offset) % 3600 == 0 {
                tempHourStrings[time] = "," + String((time + offset)/3600)
            }
        }
        
        times = tempTimes
        hourStrings = tempHourStrings
        currentTimeSlot = getCurrentTimeSlot()
        let nextSlotTime = Calendar.current.nextDate(after: .now, matching: DateComponents(minute: 0), matchingPolicy: .nextTime) ?? .now
        
        let slotTimer = Timer.init(fire: nextSlotTime, interval: 900, repeats: true, block: { _ in
            self.currentTimeSlot = self.getCurrentTimeSlot()
        })
        RunLoop.current.add(slotTimer, forMode: .common)
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
    
    func getCurrentTimeSlot() -> Int? {
        let now = Date.now
        let todayRef = Calendar.current.dateComponents([.year, .month, .day], from: now)
        
        let currentTimeToday = (Int(now.timeIntervalSince(Calendar.current.startOfDay(for: now))) - DateHelper.timeZoneOffset())/900*900
        
        if dateRef == todayRef {
            return currentTimeToday
        }
        
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? .now
        let tomorrowRef = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        if dateRef == tomorrowRef {
            return currentTimeToday - 86400
        }
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? .now
        let yesterdayRef = Calendar.current.dateComponents([.year, .month, .day], from: yesterday)
        if dateRef == yesterdayRef {
            return currentTimeToday + 86400
        }
        
        return nil
    }
}
