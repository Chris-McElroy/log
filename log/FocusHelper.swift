//
//  FocusHelper.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

class FocusHelper: ObservableObject {
    static let main: FocusHelper = FocusHelper()
    
    @Published var editingText: Bool = false
    @Published var editingColors: Bool = false
    @Published var editingDuration: Bool = false
    @Published var scrollProxy: ScrollViewProxy? = nil
    @Published var time: Int? = nil
    
    func changeTime(to time: Int?, animate: Bool = true) {
        let wasEditing = editingText
        editingText = false // otherwise text editor edits the old text
        Storage.main.mergeEntries() // this is where it auto overwrites
        
        if let old = self.time, Storage.main.entries[old]?.text == promptText {
            Storage.main.entries[old]?.text = ""
        }
        
        if var new = time {
            while Storage.main.entries[new] == nil && new > DateHelper.main.times[0] {
                new -= 900
            }
            self.time = new
            if Storage.main.entries[new]?.text == "" && !wasEditing {
                Storage.main.entries[new]?.text = promptText
            }
            editingText = wasEditing
            adjustScroll(animate: animate)
        } else {
            self.time = time
        }
    }
    
    func changeStartTime(to time: Int) {
        self.time = time
        adjustScroll()
    }
    
    func adjustScroll(animate: Bool = true) {
        guard let time = time else { return }
        let topDistance = (editingText || editingColors) ? 1 : (editingDuration ? 16 - ((Storage.main.entries[time]?.duration ?? 1))/2 : 5)
        let topTime = max(DateHelper.main.times.min() ?? 0, time - topDistance*900)
        if animate {
            withAnimation {
                scrollProxy?.scrollTo(topTime, anchor: .top)
            }
        } else {
            scrollProxy?.scrollTo(topTime, anchor: .top)
        }
    }
}
