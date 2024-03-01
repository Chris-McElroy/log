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
    @Published var focus: Bool = false
    @Published var newTime: Int? = nil
    
    func changeTime(to time: Int?, animate: Bool = true) {
        if time == self.time {
            withAnimation(animate ? .default : nil) {
                focus = false
                adjustScroll()
            }
        }
        newTime = time
        editingText = false // otherwise text editor edits the old text
        
        if let old = self.time, Storage.main.entries[old]?.text == promptText {
            Storage.main.entries[old]?.text = ""
        }
        
        if var new = time {
            while Storage.main.entries[new] == nil && new > DateHelper.main.times[0] {
                new -= 900
            }
            
            withAnimation(animate ? .default : nil) {
                self.time = new
            }
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
        guard let time = time, let entry = Storage.main.entries[time] else { return }
        let bottomTime = time + entry.duration*900
//        let topDistance = (editingText || editingColors) ? 1 : (editingDuration ? 16 - ((Storage.main.entries[time]?.duration ?? 1))/2 : 5)
//        let topTime = max(DateHelper.main.times.min() ?? 0, time - topDistance*900)
#if os(iOS)
        let anchorPoint = focus ? UnitPoint.init(x: 0, y: 0.43) : UnitPoint.center
        let anchorTime = bottomTime // focus ? max(DateHelper.main.times.min() ?? 0, time + ((Storage.main.entries[time]?.duration ?? 0) - 3)*900) : time
#elseif os(macOS)
        let anchorPoint = UnitPoint.center
        let anchorTime = bottomTime
#endif
        withAnimation(animate ? .default : nil) {
            scrollProxy?.scrollTo(anchorTime, anchor: anchorPoint)
        }
    }
}
