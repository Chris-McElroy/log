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

class Storage {
    static let main = Storage()
    private var data: [String: [String: Any]] = [:]
    
    func pullData() {
        guard let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            print("couldn't get container url")
            return
        }
        
        let fileUrl = containerUrl.appendingPathComponent("data26.plist")
        
        do {
            let nsData = try NSDictionary(contentsOf: fileUrl, error: {}())
            data = Dictionary(_immutableCocoaDictionary: nsData)
            print(data)
        } catch {
            print("couldn't get contents")
        }
        print(data)
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
    
    func set(_ entry: Entry, at time: Int, on day: String) {
        pullData()
        let timeString = "g" + String(time)
        print("old:", data[day]?[timeString] ?? "no previous entry")
        data[day, default: [:]][timeString] = entry.toDict()
        pushData()
    }
    
    func getEntries(on day: String) -> [Int: Entry] {
        pullData()
        var tempDict: [Int: Entry] = [:]
        for day in data[day] ?? [:] {
            for entry in day.value as? NSDictionary ?? [:] {
                tempDict[Int((entry.key as? String ?? "").dropFirst()) ?? 0] = Entry(from: entry.value)
            }
        }
        return tempDict
    }
}
