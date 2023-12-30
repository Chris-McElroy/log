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
    
    func pullData() {
        guard let icloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            print("couldn't get icloud url")
            return
        }
        
        let containerUrl = icloudUrl.appendingPathComponent("Documents")
        
        let fileUrl = containerUrl.appendingPathComponent("data26.plist")
        
        do {
            let nsData = try NSDictionary(contentsOf: fileUrl, error: {}())
            data = Dictionary(_immutableCocoaDictionary: nsData)
        } catch {
            print("couldn't get contents")
        }
    }
    
    func pushData() {
        guard let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            print("couldn't get container url")
            return
        }
        
        let fileUrl = containerUrl.appendingPathComponent("data26.plist")
        
        do {
            try NSDictionary(dictionary: data, copyItems: false).write(to: fileUrl)
        }
        catch {
            print("couldn't write", error.localizedDescription)
        }
    }
    
    func loadEntries() {
        pullData()
        
        var tempEntries: [Int: Entry] = [:]
        for (time, entryData) in data[DateHelper.main.day] ?? [:] {
            guard let entryDict = entryData as? NSDictionary else { continue }
            tempEntries[Int(time.dropFirst()) ?? 0] = Entry(from: entryDict)
        }
        
        DateHelper.main.loadTimes(lo: tempEntries.keys.min(), hi: tempEntries.keys.max())
        for time in DateHelper.main.times {
            if tempEntries[time] == nil {
                tempEntries[time] = Entry("")
            }
        }
        
        entries = tempEntries
    }
    
    func set(_ entry: Entry, at time: Int) {
        pullData()
        let timeString = "g" + String(time)
        print("old:", data[DateHelper.main.day]?[timeString] ?? "no previous entry")
        if entry.isEmpty() {
            data[DateHelper.main.day]?[timeString] = nil
        } else {
            data[DateHelper.main.day, default: [:]][timeString] = entry.toDict()
        }
        pushData()
    }
}
