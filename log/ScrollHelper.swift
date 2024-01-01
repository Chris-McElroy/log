//
//  ScrollHelper.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

class ScrollHelper: ObservableObject {
    static let main: ScrollHelper = ScrollHelper()
    
    @Published var mainViewScrollProxy: ScrollViewProxy? = nil
    @Published var focusTimeSlot: Int? = nil
    
    func changeFocusTimeSlot(to time: Int, animate: Bool = true, keyboardUp: Bool = false, center: Bool = false) {
        focusTimeSlot = time
        let topDistance = keyboardUp ? 1 : (center ? 15 : 5)
        let topTime = max(DateHelper.main.times.min() ?? 0, time - topDistance*900)
        if animate {
            withAnimation {
                mainViewScrollProxy?.scrollTo(topTime, anchor: .top)
            }
        } else {
            mainViewScrollProxy?.scrollTo(topTime, anchor: .top)
        }
    }
}
