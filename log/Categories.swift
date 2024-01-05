//
//  Categories.swift
//  log
//
//  Created by 4 on 2024.01.04.
//

import SwiftUI

struct Categories {
    static let names: [String] = [
        "hurting",      // 0
        "arousing",     // 1
        "relaxing",     // 2
        "eating",       // 3
        "exercising",   // 4
        "shopping",     // 5
        "meeting",      // 6
        "researching",  // 7
        "projecting",   // 8
        "socializing",  // 9
        "traveling",    // 10
        "communicating",// 11
        "configuring",  // 12
        "tending",      // 13
        "thinking",     // 14
        "sleeping",     // 15
    ]
    
    static let numFromPos: [[Int]] = [
        [5, 12, 15, 7],
        [0, 14, 13, 6],
        [2, 8, 3, 11],
        [1, 4, 10, 9],
    ]
    
    static let displayOrder: [Int] = [
        15, 2, 4, 10, 13, 3, 0, 5, 1, 9, 11, 6, 7, 8, 12, 14
    ]
    
    static let colors: [Color] = [
        Color(hue: 276/360, saturation: 1, brightness: 0.85),       // hurting, blue-purple
        Color(hue: 300/360, saturation: 0.75, brightness: 1),       // arousing, pink
        Color(hue: 0, saturation: 0, brightness: 0.25),             // relaxing, dark gray
        Color(hue: 232/360, saturation: 0.99, brightness: 0.47),    // eating, dark blue
        Color(hue: 0, saturation: 0, brightness: 0.65),             // exercising, light gray
        Color(hue: 332/360, saturation: 0.85, brightness: 0.58),    // shopping, maroon
        Color(hue: 60/360, saturation: 0.93, brightness: 0.82),     // meeting, gold
        Color(hue: 123/360, saturation: 1, brightness: 0.89),       // researching, light green
        Color(hue: 112/360, saturation: 1, brightness: 0.32),       // projecting, dark green
        Color(hue: 357/360, saturation: 1, brightness: 0.65),       // socializing, red
        Color(hue: 209/360, saturation: 0.64, brightness: 0.95),    // traveling, light blue
        Color(hue: 24/360, saturation: 0.91, brightness: 0.87),     // communicating, orange
        Color(hue: 168/360, saturation: 1, brightness: 0.45),       // configuring, teal
        Color(hue: 230/360, saturation: 0.85, brightness: 1),          // tending, blue
        Color(hue: 177/360, saturation: 1, brightness: 0.75),       // thinking, cyan
        Color(hue: 0, saturation: 0, brightness: 0),                // sleeping, black
    ]
}
