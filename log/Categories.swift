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
        "working",      // 7
        "playing",      // 8
        "interacting",  // 9
        "traveling",    // 10
        "communicating",// 11
        "configuring",  // 12
        "tending",      // 13
        "thinking",     // 14
        "sleeping",     // 15
        "listening",    // 16
        "consuming",    // 17
        "failing",      // 18
        "enjoying",     // 19
    ]
    
    static let numFromPos: [[Int]] = [
        [1, 4, 8, 16],
        [19, 10, 9, 17],
        [0, 13, 14, 2],
        [18, 3, 7, 15],
    ]
    
    static let displayOrder: [Int] = [
        15, 2, 17, 16, 8, 9, 14, 7, 3, 13, 10, 4, 1, 18, 19, 0
    ]
    
    static let colors: [Color] = [
        Color(hue: 2/360, saturation: 0.98, brightness: 0.49),      // hurting, maroon
        Color(hue: 300/360, saturation: 0.75, brightness: 1),       // arousing, pink
        Color(hue: 0, saturation: 0, brightness: 0.25),              // relaxing, dark gray
        Color(hue: 232/360, saturation: 0.99, brightness: 0.47),    // eating, dark blue
        Color(hue: 0, saturation: 0, brightness: 0.6),              // exercising, light gray
        .white,    // shopping = tending
        .white,     // meeting = interacting
        Color(hue: 148/360, saturation: 1, brightness: 0.25),       // working, dark cyan
        Color(hue: 45/360, saturation: 0.98, brightness: 0.90),     // playing, gold
        Color(hue: 69/360, saturation: 1, brightness: 0.74),        // interacting, lime green
        Color(hue: 209/360, saturation: 0.64, brightness: 0.95),    // traveling, light blue
        .white,     // communicating = interacting
        .white,       // configuring = playing
        Color(hue: 232/360, saturation: 1, brightness: 1),          // tending, blue
        Color(hue: 120/360, saturation: 1, brightness: 0.46),       // thinking, green
        Color(hue: 0, saturation: 0, brightness: 0),                // sleeping, black
        Color(hue: 37/360, saturation: 1, brightness: 0.68),        // listening, tan
        Color(hue: 33/360, saturation: 1, brightness: 0.4),         // consuming, brown
        Color(hue: 270/360, saturation: 1, brightness: 0.49),           // failing, purple
        Color(hue: 1/360, saturation: 0.9, brightness: 1),           // enjoying, deep red
    ]
    
    static let keyOrder: [Character] =
    [
        "2",    // 0  - hurting
        "v",    // 1  - arousing
        "r",    // 2  - relaxing
        "d",    // 3  - eating
        "x",    // 4  - exercising
        "k",    // 5  - shopping
        "k",    // 6  - meeting
        "f",    // 7  - working
        "z",    // 8  - playing
        "a",    // 9  - interacting
        "w",    // 10 - traveling
        "k",    // 11 - commuinicating
        "k",    // 12 - configuring
        "s",    // 13 - tending
        "e",    // 14 - thinking
        "q",    // 15 - sleeping
        "3",    // 16 - listening
        "4",    // 17 - consuming
        "1",    // 18 - failing
        "c",    // 19 - enjoying
    ]
    
/* old colors:
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
 
*/
}
