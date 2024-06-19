//
//  StorageHelper.swift
//  log
//
//  Created by 4 on 2023.12.01.
//

import Foundation
#if os(macOS)
import AppKit
#endif

/* largely from
https://stackoverflow.com/questions/65173861/saving-a-file-to-icloud-drive
https://developer.apple.com/documentation/uikit/documents_data_and_pasteboard/synchronizing_documents_in_the_icloud_environment
*/

class Storage: ObservableObject {
    static let main = Storage()
    
    
    @Published var entries: [Int: Entry] = [:]
    @Published var currentEntry: Entry = Entry()
    
    private var query: NSMetadataQuery? = nil
//    private var data: [String: [String: Any]] = [:]
    private var entriesDate: String = ""
    private var updateTimer: Timer? = nil
    
    private func pullData(for day: String) -> [String: Any] {
        guard let dayFile = getDayFile(for: day) else { return [:] }
        
        do {
            let nsData = try NSDictionary(contentsOf: dayFile, error: {}())
            return Dictionary(_immutableCocoaDictionary: nsData)
        } catch {
            print("couldn't get contents")
            return [:]
        }
    }
    
    private func getDayFile(for day: String) -> URL? {
        guard let icloudFolder = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            print("couldn't get icloud url")
            return nil
        }
        
        let documentsFolder = icloudFolder.appendingPathComponent("Documents")
        
        let dateComp = day.split(separator: ".")
        let yearFolder = documentsFolder.appendingPathComponent("data" + dateComp[0])
        let monthFolder = yearFolder.appendingPathComponent("data" + dateComp[0] + "." + dateComp[1])
        
        if !FileManager.default.fileExists(atPath: monthFolder.path(percentEncoded: false)) {
            do {
                try FileManager.default.createDirectory(at: monthFolder, withIntermediateDirectories: true)
            } catch {
                print("couldn't create folder")
            }
        }
        
        let dayFile = monthFolder.appendingPathComponent("data" + day + ".plist")
        
        return dayFile
    }
    
    private func getEntries(for day: String) -> [Int: Entry] {
        let data = pullData(for: day)
        
        var tempEntries: [Int: Entry] = [:]
        for (time, entryData) in data {
            guard let entryDict = entryData as? NSDictionary else { continue }
            tempEntries[Int(time.dropFirst()) ?? 0] = Entry(from: entryDict)
        }
        
        return tempEntries
    }
    
    private func loadEntries(for day: String) {
        var tempEntries = getEntries(for: day)
        
        let timeList = DateHelper.main.loadTimes(lo: tempEntries.keys.min(), hi: tempEntries.keys.max())
        var nilQueue = 0
        for time in timeList {
            if nilQueue > 0 {
                tempEntries[time] = nil
                nilQueue -= 1
            } else if let entry = tempEntries[time] {
                nilQueue += entry.duration - 1
            } else {
                tempEntries[time] = Entry()
            }
        }
        
        self.entriesDate = day
        self.entries = tempEntries
        
        if let time = FocusHelper.main.time {
            FocusHelper.main.changeTime(to: time, animate: true)
        }
    }
    
    func returnAllEntries(for day: String) -> [Int: Entry] {
        var tempEntries = getEntries(for: day)
        
        let timeList = DateHelper.main.getTimeSet(lo: tempEntries.keys.min(), hi: tempEntries.keys.max())
        var nilQueue = 0
        for time in timeList {
            if nilQueue > 0 {
                tempEntries[time] = nil
                nilQueue -= 1
            } else if let entry = tempEntries[time] {
                nilQueue += entry.duration - 1
            } else {
                tempEntries[time] = Entry()
            }
        }
        
        return tempEntries
    }
    
    func mergeEntries() {
        startUpdateTimer() // this keeps it checking for external updates
        guard !entries.isEmpty && entriesDate == DateHelper.main.day else { loadEntries(for: DateHelper.main.day); return }

        let day = entriesDate
        let onlineEntries = getEntries(for: day)
            
        let onlineEntrySet = getEntrySet(from: onlineEntries)
        let localEntrySet = getEntrySet(from: entries)
        
        guard localEntrySet != onlineEntrySet else { return }
        
        let localDifference = localEntrySet.subtracting(onlineEntrySet)
        let onlineDifference = onlineEntrySet.subtracting(localEntrySet)
        
        let localTimes = localDifference.map { $0.time }
        let onlineTimes = onlineDifference.map { $0.time }
        
        if onlineTimes == localTimes {
            // only save if any of the differences are not empty entries; nil and empty are both ignored
            if localTimes.filter({ onlineEntries[$0]?.isEmpty() == false || entries[$0]?.isEmpty() == false }).isEmpty {
                return
            }
        }
        
        let entrySet = onlineEntrySet.union(localEntrySet)
        
        let entryList = entrySet.sorted(by: {
            $0.entry.lastEdit ?? .init(timeIntervalSinceReferenceDate: 0) > $1.entry.lastEdit ?? .init(timeIntervalSinceReferenceDate: 0)
        })
        
        var currentTimes: Set<Int> = []
        var newEntries: [Int: Entry] = [:]
        
        for info in entryList {
            if currentTimes.isDisjoint(with: info.times) {
                currentTimes.formUnion(info.times)
                newEntries[info.time] = info.entry
            }
        }
        
        let oldTimeList = DateHelper.main.getTimeSet(lo: entries.keys.min(), hi: entries.keys.max())
        let newTimeList = DateHelper.main.getTimeSet(lo: newEntries.keys.min(), hi: newEntries.keys.max())
        let timeList = Array(Set(oldTimeList).union(newTimeList)).sorted()
        var nilQueue = 0
        
        for time in timeList {
            if nilQueue > 0 {
                entries[time] = nil
                nilQueue -= 1
            } else if let entry = newEntries[time] {
                nilQueue += entry.duration - 1
                if let oldEntry = entries[time] {
                    oldEntry.text = entry.text
                    oldEntry.colors = entry.colors
                    oldEntry.duration = entry.duration
                    oldEntry.lastEdit = entry.lastEdit
                } else {
                    entries[time] = entry
                }
            } else {
                if let oldEntry = entries[time], !oldEntry.isEmpty() {
                    oldEntry.text = ""
                    oldEntry.colors = 0
                    oldEntry.duration = 1
                } else {
                    entries[time] = Entry()
                }
            }
        }
        
        _ = DateHelper.main.loadTimes(lo: entries.keys.min(), hi: entries.keys.max())
        
        guard let dayFile = getDayFile(for: day) else { return }
        var data: [String: Any] = [:]
        for (time, entry) in entries where !entry.isNil() {
            data["g\(time)"] = entry.toDict()
        }
        
        do {
            try NSDictionary(dictionary: data, copyItems: false).write(to: dayFile)
        }
        catch {
            print("couldn't write", day, error.localizedDescription)
        }
        
        struct EntryInfo: Hashable {
            let time: Int
            let times: Set<Int>
            let entry: Entry
        }
        
        func getEntrySet(from dict: [Int: Entry]) -> Set<EntryInfo> {
            return Set(dict.compactMap { (time, entry) in
                if entry.isNil() { return nil }
                return EntryInfo(time: time, times: getEntryTimes(time: time, duration: entry.duration), entry: entry)
            })
        }
        
        func getEntryTimes(time: Int, duration: Int) -> Set<Int> {
            var currentTime = time
            var times: Set<Int> = []
            for _ in 0..<duration {
                times.insert(currentTime)
                currentTime += 900
            }
            return times
        }
    }
    
    func startUpdateTimer(after wait: TimeInterval = 5) {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: wait, repeats: false, block: { _ in
            DispatchQueue.main.async {
                self.mergeEntries()
            }
        })
    }
    
    func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
