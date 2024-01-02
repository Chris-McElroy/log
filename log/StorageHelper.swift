//
//  StorageHelper.swift
//  log
//
//  Created by 4 on 2023.12.01.
//

import Foundation

/* largely from
https://stackoverflow.com/questions/65173861/saving-a-file-to-icloud-drive
https://developer.apple.com/documentation/uikit/documents_data_and_pasteboard/synchronizing_documents_in_the_icloud_environment
*/

class Storage: ObservableObject {
    static let main = Storage()
    
    @Published var entries: [Int: Entry] = [:]
    private var data: [String: [String: Any]] = [:]
    
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
    
    func loadEntries() {
        pullData()
        
        var tempEntries: [Int: Entry] = [:]
        for (time, entryData) in data[DateHelper.main.day] ?? [:] {
            guard let entryDict = entryData as? NSDictionary else { continue }
            tempEntries[Int(time.dropFirst()) ?? 0] = Entry(from: entryDict)
        }
        
        DateHelper.main.loadTimes(lo: tempEntries.keys.min(), hi: tempEntries.keys.max())
        var nilQueue = 0
        for time in DateHelper.main.times {
            if nilQueue > 0 {
                tempEntries[time] = nil
                nilQueue -= 1
            } else if let entry = tempEntries[time] {
                nilQueue += entry.duration - 1
            } else {
                tempEntries[time] = Entry("")
            }
        }
        
        entries = tempEntries
        
        if let time = FocusHelper.main.time {
            FocusHelper.main.changeTime(to: time, animate: true)
        }
    }
    
    func saveEntries() {
        let dayString = DateHelper.main.day
        data[dayString] = [:] // resetting so that nil entries are not kept
        
        for (time, entry) in entries {
            let timeString = "g" + String(time)
            if !entry.isEmpty() {
                data[dayString]?[timeString] = entry.toDict()
            }
        }
        
        guard let dayFile = getDayFile() else { return }
        
        do {
            try NSDictionary(dictionary: data[dayString] ?? [:], copyItems: false).write(to: dayFile)
        }
        catch {
            print("couldn't write", dayString, error.localizedDescription)
        }
    }
}
