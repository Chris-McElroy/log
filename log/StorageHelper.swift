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
    
    private var query: NSMetadataQuery? = nil
    @Published var entries: [Int: Entry] = [:]
    private var data: [String: [String: Any]] = [:]
    private var updateTimer: Timer? = nil
    
    private func pullData() {
        guard let dayFile = getDayFile() else { return }
        
        do {
            let nsData = try NSDictionary(contentsOf: dayFile, error: {}())
            data[DateHelper.main.day] = Dictionary(_immutableCocoaDictionary: nsData)
        } catch {
            print("couldn't get contents")
        }
    }
    
    private func getDayFile() -> URL? {
        guard let icloudFolder = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            print("couldn't get icloud url")
            return nil
        }
        
        let documentsFolder = icloudFolder.appendingPathComponent("Documents")
        
        let dayString = DateHelper.main.day
        let dateComp = dayString.split(separator: ".")
        let yearFolder = documentsFolder.appendingPathComponent("data" + dateComp[0])
        let monthFolder = yearFolder.appendingPathComponent("data" + dateComp[0] + "." + dateComp[1])
        
        if !FileManager.default.fileExists(atPath: monthFolder.path(percentEncoded: false)) {
            do {
                try FileManager.default.createDirectory(at: monthFolder, withIntermediateDirectories: true)
            } catch {
                print("couldn't create folder")
            }
        }
        
        let dayFile = monthFolder.appendingPathComponent("data" + DateHelper.main.day + ".plist")
        
        return dayFile
    }
    
    private func getEntries() -> [Int: Entry] {
        pullData()
        
        var tempEntries: [Int: Entry] = [:]
        for (time, entryData) in data[DateHelper.main.day] ?? [:] {
            guard let entryDict = entryData as? NSDictionary else { continue }
            tempEntries[Int(time.dropFirst()) ?? 0] = Entry(from: entryDict)
        }
        
        return tempEntries
    }
    
    func loadEntries() {
        updateEntries(from: getEntries())
        
        if let time = FocusHelper.main.time {
            FocusHelper.main.changeTime(to: time, animate: true)
        }
    }
    
    private func updateEntries(from dict: [Int: Entry]) {
        var tempEntries = dict
        
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
        
        DispatchQueue.main.async {
            self.entries = tempEntries
        }
    }
    
    func mergeEntries() {
        guard !entries.isEmpty else { loadEntries(); return }
        
        startUpdateTimer()
        
        let onlineEntries = getEntries()
            
        let onlineEntrySet = getEntrySet(from: onlineEntries)
        let localEntrySet = getEntrySet(from: entries)
        
        guard localEntrySet != onlineEntrySet else { print("not saving"); return }
        
        let localDifference = localEntrySet.subtracting(onlineEntrySet)
        let onlineDifference = onlineEntrySet.subtracting(localEntrySet)
        
        let localTimes = localDifference.map { $0.time }
        let onlineTimes = onlineDifference.map { $0.time }
        
        if onlineTimes == localTimes {
            var allEmpty = true
            for time in localTimes {
                if onlineEntries[time]?.isEmpty() != true || entries[time]?.isEmpty() != true {
                    allEmpty = false
                    break
                }
            }
            if allEmpty {
                print("not saving 2")
                return
            }
        }
        
        print("saving")
        print(localEntrySet.subtracting(onlineEntrySet).map { ($0.time, $0.entry.text, $0.entry.lastEdit!.timeIntervalSinceNow) })
        print(onlineEntrySet.subtracting(localEntrySet).map { ($0.time, $0.entry.text, $0.entry.lastEdit!.timeIntervalSinceNow) })
        
        let entrySet = onlineEntrySet.union(localEntrySet)
        
        let entryList = entrySet.sorted(by: {
            $0.entry.lastEdit ?? .init(timeIntervalSinceReferenceDate: 0) > $1.entry.lastEdit ?? .init(timeIntervalSinceReferenceDate: 0)
        })
        
        var currentTimes: Set<Int> = []
        let dayString = DateHelper.main.day
        data[dayString] = [:] // resetting so that nil entries are not kept
        var newEntries: [Int: Entry] = [:]
        
        for info in entryList {
            if currentTimes.isDisjoint(with: info.times) {
                currentTimes.formUnion(info.times)
                data[dayString]?["g\(info.time)"] = info.entry.toDict()
                newEntries[info.time] = info.entry
            }
        }
        
        updateEntries(from: newEntries)
        
        guard let dayFile = getDayFile() else { return }
        do {
            try NSDictionary(dictionary: data[dayString] ?? [:], copyItems: false).write(to: dayFile)
        }
        catch {
            print("couldn't write", dayString, error.localizedDescription)
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
            self.mergeEntries()
        })
    }
    
    func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
