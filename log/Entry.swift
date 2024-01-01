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
        text == "" && colors.isEmpty && duration == 1
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
    
    static let colorList: [Color] = [
        Color(hue: 0.025, saturation: 1, brightness: 0.5),      // red
        Color(hue: 0.833, saturation: 1, brightness: 0.63),     // pink
        Color(hue: 0.922, saturation: 0.74, brightness: 0.33),  // maroon
        Color(hue: 0.067, saturation: 0.85, brightness: 0.28),  // brown
        Color(hue: 0.067, saturation: 0.84, brightness: 0.56),  // orange
        Color(hue: 0.131, saturation: 1, brightness: 0.42),     // gold
        Color(hue: 0.164, saturation: 0.99, brightness: 0.27),  // camo
        Color(hue: 0.333, saturation: 1, brightness: 0.28),     // green
        Color(hue: 0.642, saturation: 0.99, brightness: 0.29),  // dark blue
        Color(hue: 0.636, saturation: 1, brightness: 0.51),     // blue
        Color(hue: 0.528, saturation: 1, brightness: 0.50),     // light blue
        Color(hue: 0.503, saturation: 0.94, brightness: 0.34),  // teal
        Color(hue: 0.761, saturation: 0.54, brightness: 0.41),  // purple
        Color(hue: 0, saturation: 0, brightness: 0.57),         // light gray
        Color(hue: 0, saturation: 0, brightness: 0.35),         // dark gray
        Color(hue: 0, saturation: 0, brightness: 0),            // black
    ]
}
