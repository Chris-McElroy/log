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
        editingText = false // otherwise text editor edits the old text
        
        if let old = self.time, Storage.main.entries[old]?.text == promptText {
            Storage.main.entries[old]?.text = ""
        }
        Storage.main.saveEntries()
        
        self.time = time
        if let new = time, Storage.main.entries[new]?.text == "" {
            Storage.main.entries[new]?.text = promptText
            adjustScroll(animate: animate)
        }
    }
    
    func adjustScroll(animate: Bool = true) {
        guard let time = time else { return }
        let topDistance = (editingText || editingColors) ? 1 : (editingDuration ? 15 : 5)
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
