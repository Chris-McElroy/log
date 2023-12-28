//
//  Entry.swift
//  log
//
//  Created by 4 on 2023.12.27.
//

import Foundation

struct Entry {
    var text: String = ""
    var colors: [Int] = []
    var duration = 1
    
    init(_ text: String) {
        self.text = text
    }
    
    init(from dict: NSDictionary.Value) {
        guard let entryData = dict as? NSDictionary else {
            return
        }
        text = entryData["t"] as? String ?? ""
        if let colors = entryData["c"] as? NSArray {
            self.colors = colors.compactMap { $0 as? Int }
        }
        duration = entryData["d"] as? Int ?? 1
    }
    
    func toDict() -> NSDictionary {
        var tempDict: [String: Any] = [:]
        tempDict["t"] = text
        if !colors.isEmpty {
            tempDict["c"] = colors
        }
        if duration != 1 {
            tempDict["d"] = duration
        }
        return NSDictionary(dictionary: tempDict)
    }
}
