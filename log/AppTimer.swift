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
        // determine the current day
        let midnight = Date.now.advanced(by: -18000) // sets 5 am to midnight
        let todayRef = Calendar.current.dateComponents([.year, .month, .day], from: midnight)
        let today = DateHelper.dayString(from: todayRef)
        
        // determine the current time in the current day
        var time = (Int(Date.now.timeIntervalSince(Calendar.current.startOfDay(for: midnight))) - DateHelper.timeZoneOffset())/900*900
        
        // load all the entries for that day
        let entries = Storage.main.returnAllEntries(for: today)
        
        // determine the entry that is over the current time in the current day
        while entries[time] == nil && time > entries.keys.min() ?? 0 {
            time -= 900
        }
        
        // if there is none, return
        guard entries[time] != nil else { return }
        
        // otherwise, for each app, see how long it's viable, and add that to a dictionary
        var appTimers: [String: String] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        for (app, validCategories) in appColors {
            var localTime = time
            while (entries[localTime]?.colors ?? 0) & validCategories != 0 {
                localTime += 900
                while entries[localTime] == nil && localTime < entries.keys.max() ?? 0 {
                    localTime += 900
                }
            }
            let stopTime = Date.init(timeInterval: TimeInterval(localTime + DateHelper.timeZoneOffset()), since: Calendar.current.startOfDay(for: midnight))
            appTimers[app] = formatter.string(from: stopTime)
        }
        
        // write that dictionary
        guard let appTimerFile = getAppTimerFile() else { return }
        
        do {
            let nsData = try NSDictionary(contentsOf: appTimerFile, error: {}())
            let oldData: [String: String] = Dictionary(_immutableCocoaDictionary: nsData)
            if oldData == appTimers { return }
        } catch {
            print("couldn't get contents")
            return
        }
        
        do {
            try NSDictionary(dictionary: appTimers, copyItems: false).write(to: appTimerFile)
        }
        catch {
            print("couldn't write app timer", error.localizedDescription)
        }
    }
    
    static let appColors: [String: Int]  = [
        // consuming
        "Consuming": 1 << 17,
        "Orion": 1 << 17 | 1 << 8 | 1 << 7, // also playing and working
        "Books": 1 << 17 | 1 << 7, // also working
        
        // interacting
        "Beeper": 1 << 9,
        "Mail": 1 << 9,
        "Messages": 1 << 9,
        "Signal": 1 << 9,
        "Messenger": 1 << 9,
        "WhatsApp": 1 << 9,
        "Interacting": 1 << 9,
        
        // playing
        "Xcode": 1 << 8,
        "Visual Studio Code": 1 << 8 | 1 << 7, // also working
        "Fello AI": 1 << 8 | 1 << 7, // also working
        "Tinkertool": 1 << 8,
        "Warp": 1 << 8,
        "Alfred Preferences": 1 << 8,
        "System Settings": 1 << 8,
        "Shortcuts": 1 << 8,
        "Minecraft": 1 << 8,
        "App Store": 1 << 8,
        "Playing": 1 << 8,
        
        // working
        "PDF Viewer": 1 << 7,
        "RStudio": 1 << 7,
        "Microsoft Word": 1 << 7,
        "Microsoft Excel": 1 << 7,
        "Microsoft PowerPoint": 1 << 7,
        "Working": 1 << 7,
        
        // thinking (or playing or working or tending)
        "TickTick": 1 << 13 | 1 << 14 | 1 << 8 | 1 << 7,
        "Obsidian": 1 << 13 | 1 << 14 | 1 << 8 | 1 << 7,
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
