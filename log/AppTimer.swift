//
//  AppTimer.swift
//  log
//
//  Created by 4 on .3.1.
//

import Foundation
#if os(macOS)
import AppKit
#endif

class AppTimer {
    static func updateTimes() {
        print("doin timers!")
        // determine the current day
        let midnight = Date.now.advanced(by: -18000) // sets 5 am to midnight
        let todayRef = Calendar.current.dateComponents([.year, .month, .day], from: midnight)
        let today = DateHelper.dayString(from: todayRef)
        
        // determine the current time in the current day
        var time = (Int(Date.now.timeIntervalSince(Calendar.current.startOfDay(for: midnight))) - DateHelper.timeZoneOffset())/900*900
        print("initial time", time)
        
        // load all the entries for that day
        let entries = Storage.main.returnAllEntries(for: today)
        
        // determine the entry that is over the current time in the current day
        while entries[time] == nil && time > entries.keys.min() ?? 0 {
            time -= 900
        }
        
        // if there is none, return
        guard entries[time] != nil else { return }
        print("got entry!", today, entries.count, time)
        
        // otherwise, for each app, see how long it's viable, and add that to a dictionary
        var appTimers: [String: String] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        for (app, validCategories) in appColors {
            var localTime = time
            while (entries[localTime]?.colors ?? 0) & validCategories != 0 {
                print("looping", entries[localTime]?.colors, validCategories, (entries[localTime]?.colors ?? 0) & validCategories)
                localTime += 900
                while entries[localTime] == nil && localTime < entries.keys.max() ?? 0 {
                    localTime += 900
                }
            }
            let stopTime = Date.init(timeInterval: TimeInterval(localTime + DateHelper.timeZoneOffset()), since: Calendar.current.startOfDay(for: midnight))
            appTimers[app] = formatter.string(from: stopTime)
        }
        
        print("got dict")
        print(appTimers)
        
        // write that dictionary
        guard let appTimerFile = getAppTimerFile() else { return }
        
        do {
            try NSDictionary(dictionary: appTimers, copyItems: false).write(to: appTimerFile)
        }
        catch {
            print("couldn't write app timer", error.localizedDescription)
        }
    }
    
    static let appColors: [String: Int]  = [
        "Orion": 1 << 17
    ]
    
    private static func getAppTimerFile() -> URL? {
        guard let icloudFolder = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            print("couldn't get icloud url")
            return nil
        }
        
        let documentsFolder = icloudFolder.appendingPathComponent("Documents")
        
        return documentsFolder.appendingPathComponent("apps.plist")
    }
}
