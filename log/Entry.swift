//
//  Entry.swift
//  log
//
//  Created by 4 on 2023.12.27.
//

import SwiftUI

class Entry: ObservableObject, Equatable, Hashable {
    @Published var text: String = ""
    @Published var colors: Int = 0
    @Published var duration: Int = 1
    @Published var lastEdit: Date? = nil
    
    init(blank: Bool = false) {
        if blank {
            lastEdit = .now
        }
    }
    
    init(from dict: NSDictionary.Value) {
        guard let entryData = dict as? NSDictionary else {
            return
        }
        text = entryData["t"] as? String ?? ""
        if let colors = entryData["c"] as? NSArray {
            for color in colors.compactMap({ $0 as? Int }) {
                self.colors |= 1 << color
            }
        }
        duration = entryData["d"] as? Int ?? 1
        if let timeIntervalSinceReferenceDate = entryData["e"] as? Double {
            lastEdit = Date.init(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
        } else {
            lastEdit = nil
        }
    }
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.text == rhs.text && lhs.colors == rhs.colors && lhs.duration == rhs.duration && lhs.lastEdit == rhs.lastEdit
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(colors)
        hasher.combine(duration)
        hasher.combine(lastEdit)
    }
    
    func isEmpty() -> Bool {
        (text == "" || text == promptText) && colors == 0 && duration == 1
    }
    
    func isNil() -> Bool {
        (text == "" || text == promptText) && colors == 0 && duration == 1 && lastEdit == nil
    }
    
    func toDict() -> NSDictionary {
        var tempDict: [String: Any] = [:]
        tempDict["t"] = text
        if colors != 0 {
            var tempArray: [Int] = []
            for color in 0..<Categories.names.count {
                if colors & (1 << color) != 0 { // TODO actually change to ints in the database as well
                    tempArray.append(color)
                }
            }
            tempDict["c"] = tempArray
        }
        if duration != 1 {
            tempDict["d"] = duration
        }
        if let lastEdit {
            tempDict["e"] = Double(lastEdit.timeIntervalSinceReferenceDate)
        }
        return NSDictionary(dictionary: tempDict)
    }
    
    func updateLastEdit(old: Any, new: Any) {
        lastEdit = .now
        Storage.main.startUpdateTimer(after: 1)
    }
}
