//
//  DateHelper.swift
//  log
//
//  Created by 4 on 2023.12.27.
//

import Foundation

class DateHelper {
    static func day() -> String {
        let comp = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        let yearString = String((comp.year ?? 1997) - 1997)
        return "," + yearString + "." + String(comp.month ?? 0) + "." + String(comp.day ?? 0)
    }
    
    private static func timeZoneOffset() -> Int {
        Calendar.current.timeZone.secondsFromGMT()
    }
    
    static func shortTimeString(_ time: Int) -> String {
        let localTime = time + timeZoneOffset() // TODO check if plus or minus
        let hour = localTime/3600
        let minute = ((localTime + 360000) % 3600)/60
        if minute == 0 {
            return "," + String(hour)
        }
        return ""
    }
    
    static func longTimeString(_ time: Int) -> String {
        let localTime = time + timeZoneOffset() // TODO check if plus or minus
        let hour = localTime/3600
        let minute = ((localTime + 360000) % 3600)/60
        return "," + String(hour) + "." + String(minute)
    }
}
