//
//  logApp.swift
//  log
//
//  Created by 4 on 9/26/23.
//

import SwiftUI

@main
struct logApp: App {
    @State var lastActive: Date? = nil
#if os(iOS)
    let activeNotification = UIApplication.didBecomeActiveNotification
    let resignNotification = UIApplication.willResignActiveNotification
#elseif os(macOS)
    let activeNotification = NSApplication.willBecomeActiveNotification
    let resignNotification = NSApplication.willResignActiveNotification
#endif
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .font(Font.custom("Baskerville", size: fontSize))
                .background(Color.black, ignoresSafeAreaEdges: .all)

                .onReceive(NotificationCenter.default.publisher(for: activeNotification)) { _ in
                    Storage.main.mergeEntries()
//                    DateHelper.main.startTimeSlotTimer()
                    if (lastActive?.timeIntervalSinceNow ?? -100000) < -10800 {
                        DateHelper.main.updateDay()
                    }
                    if (lastActive?.timeIntervalSinceNow ?? -100000) > -300 { return }
                    if let currentTime = DateHelper.main.getCurrentSlot(offset: -300) {
                        FocusHelper.main.changeTime(to: currentTime, animate: false)
                        FocusHelper.main.focus = true
                        FocusHelper.main.adjustScroll(animate: false)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: resignNotification)) { _ in
                    lastActive = .now
                    Storage.main.mergeEntries()
//                    DateHelper.main.stopTimeSlotTimer()
                    Storage.main.stopUpdateTimer()
                }
        }
    }
}
