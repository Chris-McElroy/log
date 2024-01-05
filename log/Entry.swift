//
//  Entry.swift
//  log
//
//  Created by 4 on 2023.12.27.
//

import SwiftUI

class Entry: ObservableObject, Equatable {
    @Published var text: String = ""
    @Published var colors: Set<Int> = []
    @Published var duration = 1
    
    init(_ text: String) {
        self.text = text
    }
    
    init(from dict: NSDictionary.Value) {
        guard let entryData = dict as? NSDictionary else {
            return
        }
        text = entryData["t"] as? String ?? ""
        if let colors = entryData["c"] as? NSArray {
            self.colors = Set(colors.compactMap { $0 as? Int })
        }
        duration = entryData["d"] as? Int ?? 1
    }
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.text == rhs.text && lhs.colors == rhs.colors && lhs.duration == rhs.duration
    }
    
    func isEmpty() -> Bool {
        (text == "" || text == promptText) && colors.isEmpty && duration == 1
    }
    
    func toDict() -> NSDictionary {
        var tempDict: [String: Any] = [:]
        tempDict["t"] = text
        if !colors.isEmpty {
            tempDict["c"] = Array(colors)
        }
        if duration != 1 {
            tempDict["d"] = duration
        }
        return NSDictionary(dictionary: tempDict)
    }
}
