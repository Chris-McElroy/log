//
//  DateHelper.swift
//  log
//
//  Created by 4 on 2023.12.27.
//

import SwiftUI

class DateHelper: ObservableObject {
    static var main = DateHelper()
    
    @Published var day: String
    @Published var dayTitle: String
    @Published var times: [Int] = []
    @Published var hourStrings: [Int: String] = [:]
//    @Published var currentTimeSlot: Int? = nil
    private var dateRef: DateComponents
    private var timeSlotTimer: Timer? = nil
    
    init() {
        let year = UserDefaults.standard.value(forKey: "year") as? Int ?? 2024
        let month = UserDefaults.standard.value(forKey: "month") as? Int ?? 1
        let day = UserDefaults.standard.value(forKey: "day") as? Int ?? 1
        let weekday = UserDefaults.standard.value(forKey: "weekday") as? Int ?? 1
        
        let dateRef = DateComponents(year: year, month: month, day: day, weekday: weekday)
        
        self.dateRef = dateRef
        self.day = DateHelper.dayString(from: dateRef)
        self.dayTitle = DateHelper.dayTitle(from: dateRef)
    }

    static func dayString(from date: DateComponents) -> String {
        let yearString = String((date.year ?? 2024) - 1997)
        return yearString + "." + String(date.month ?? 1) + "." + String(date.day ?? 1)
    }
    
    static func dayTitle(from date: DateComponents) -> String {
        let yearString = String((date.year ?? 2024) - 1997)
        let weekdayChar = ["x", "u ", "m ", "t ", "w ", "r ", "f ", "s "][date.weekday ?? 1] // these are hair spaces
        return weekdayChar + yearString + "." + String(date.month ?? 1) + "." + String(date.day ?? 1)
    }
    
    static func timeZoneOffset() -> Int {
        Calendar.current.timeZone.secondsFromGMT()
    }
    
    func changeDay(forward: Bool) {
        Storage.main.mergeEntries()
        withAnimation(.easeInOut(duration: 0.1)) {
            FocusHelper.main.changeTime(to: nil)
        }
        let dateRefDate = Calendar.current.date(from: dateRef) ?? .now
        let newDate = Calendar.current.date(byAdding: .day, value: forward ? 1 : -1, to: dateRefDate) ?? .now
        dateRef = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: newDate)
        day = DateHelper.dayString(from: dateRef)
        dayTitle = DateHelper.dayTitle(from: dateRef)
        
        UserDefaults.standard.setValue(dateRef.year ?? 2024, forKey: "year")
        UserDefaults.standard.setValue(dateRef.month ?? 1, forKey: "month")
        UserDefaults.standard.setValue(dateRef.day ?? 1, forKey: "day")
        UserDefaults.standard.setValue(dateRef.weekday ?? 1, forKey: "weekday")
        Storage.main.mergeEntries()
    }
    
    func updateDay() {
        // get the current time minus 4 hours
        let currentDate = Date.now.advanced(by: -14400)
        let currentDateRef = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: currentDate)
        if currentDateRef == dateRef { return }
        
        if !Storage.main.entries.isEmpty { Storage.main.mergeEntries() }
        
        dateRef = currentDateRef
        day = DateHelper.dayString(from: dateRef)
        dayTitle = DateHelper.dayTitle(from: dateRef)
        
        UserDefaults.standard.setValue(dateRef.year ?? 2024, forKey: "year")
        UserDefaults.standard.setValue(dateRef.month ?? 1, forKey: "month")
        UserDefaults.standard.setValue(dateRef.day ?? 1, forKey: "day")
        UserDefaults.standard.setValue(dateRef.weekday ?? 1, forKey: "weekday")
        
        Storage.main.mergeEntries()
    }
    
    func getTimeSet(lo: Int?, hi: Int?) -> [Int] {
        let offset = DateHelper.timeZoneOffset()
        let lo = min(-offset, lo ?? -offset)
        let hi = max(110700-offset, hi ?? 110700-offset)
        
        var tempTimes: [Int] = []
        
        var i = lo
        while i <= hi {
            tempTimes.append(i)
            i += 900
        }
        
        return tempTimes
    }
    
    func loadTimes(lo: Int?, hi: Int?) -> [Int] {
        let offset = DateHelper.timeZoneOffset()
        let tempTimes = getTimeSet(lo: lo, hi: hi)
        var tempHourStrings: [Int: String] = [:]
        
        for time in tempTimes {
            if (time + offset) % 3600 == 0 {
                tempHourStrings[time] = "," + String((time + offset)/3600)
            }
        }
        
        self.times = tempTimes
        self.hourStrings = tempHourStrings
//        self.currentTimeSlot = self.getCurrentTimeSlot()
        
        return tempTimes
    }
    
//    func startTimeSlotTimer() {
//        let minute = Calendar.current.dateComponents([.minute], from: .now).minute ?? 0
//        let nextSlotMinute = ((minute/15 + 1)*15) % 60
//        let nextSlotTime = Calendar.current.nextDate(after: .now, matching: DateComponents(minute: nextSlotMinute), matchingPolicy: .nextTime) ?? .now
//        
//        timeSlotTimer?.invalidate()
//        timeSlotTimer = Timer.init(fire: nextSlotTime, interval: 2, repeats: true, block: { _ in
//            self.currentTimeSlot = self.getCurrentTimeSlot()
//        })
//        if let timeSlotTimer {
//            RunLoop.current.add(timeSlotTimer, forMode: .common)
//        }
//    }
    
//    func stopTimeSlotTimer() {
//        timeSlotTimer?.invalidate()
//        timeSlotTimer = nil
//    }
    
    func getTimeString() -> String {
        let offset = DateHelper.timeZoneOffset()
        guard let start = FocusHelper.main.time else { return "" }
        guard let duration = Storage.main.entries[start]?.duration else { return "" }
        
        let startHour = String((start + offset)/3600)
        let startMinute = String(((start + offset + 360000) % 3600)/60)
        let startString = "," + startHour + "." + startMinute
        
        let end = start + duration*900
        let endHour = String((end + offset)/3600)
        let endMinute = String(((end + offset + 360000) % 3600)/60)
        let endString = "," + endHour + "." + endMinute
        
        return startString + " - " + endString
    }
    
    func getCurrentSlot(offset: Double = 0) -> Int? {
        let pertinentTime = Date.now.advanced(by: offset)
        let todayRef = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: pertinentTime)
        
        let currentTimeToday = (Int(pertinentTime.timeIntervalSince(Calendar.current.startOfDay(for: pertinentTime))) - DateHelper.timeZoneOffset() + 86400)/900*900 - 86400 // plus minus because swift is a god damn piece of shit and can't round negative numbers the right way so help it god
        print(currentTimeToday)
        
        if dateRef == todayRef {
            return currentTimeToday
        }
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: pertinentTime) ?? pertinentTime
        let tomorrowRef = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: tomorrow)
        if dateRef == tomorrowRef && times.contains(currentTimeToday - 86400) {
            return currentTimeToday - 86400
        }
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: pertinentTime) ?? pertinentTime
        let yesterdayRef = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: yesterday)
        if dateRef == yesterdayRef && times.contains(currentTimeToday + 86400) {
            print("yesterday", currentTimeToday, currentTimeToday + 86400)
            return currentTimeToday + 86400
        }
        
        return nil
    }
}
