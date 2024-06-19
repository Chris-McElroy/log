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
//    @Published var editingDuration: Bool = false
    @Published var scrollProxy: ScrollViewProxy? = nil
    @Published var time: Int? = nil
    @Published var changing: Bool = false
    @Published var focus: Bool = false
    @Published var newTime: Int? = nil
    @Published var stats: Bool = false
    
    func changeTime(to time: Int?, animate: Bool = true) {
        changing = true
        if time == nil {
            withAnimation(animate ? .default : nil) {
                focus = false
                adjustScroll()
            }
            editingText = false
        }
        newTime = time
        
        if let old = self.time {
            if Storage.main.entries[old]?.text == promptText {
                Storage.main.entries[old]?.text = ""
            }
            Storage.main.mergeEntries()
        }
        if var new = time {
            if new == self.time {
                editingText.toggle()
                return
            }
            
//            self.time = nil // hoping this will help with the duplication bug
            
            while Storage.main.entries[new] == nil && new > DateHelper.main.times[0] {
                new -= 900
            }
            
//            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                withAnimation(animate ? .default : nil) {
                    self.time = new
                    focus = true
                    editingText = true
                }
                self.adjustScroll(animate: animate)
                self.changing = false
//            }
        } else {
            self.time = nil
            changing = false
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
