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
#elseif os(macOS)
    let activeNotification = NSApplication.willBecomeActiveNotification
#endif
    
#if os(iOS)
    let resignNotification = UIApplication.willResignActiveNotification
#elseif os(macOS)
    let resignNotification = NSApplication.willResignActiveNotification
#endif
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .font(Font.custom("Baskerville", size: 14.0))
                .buttonStyle(PlainButtonStyle())
                .background(Color.black, ignoresSafeAreaEdges: .all)

                .onReceive(NotificationCenter.default.publisher(for: activeNotification)) { _ in
                    Storage.main.mergeEntries()
                    DateHelper.main.startTimeSlotTimer()
                    if (lastActive?.timeIntervalSinceNow ?? -100000) > -300 { return }
                    if let currentTime = DateHelper.main.getCurrentTimeSlot() {
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                            FocusHelper.main.changeTime(to: currentTime, animate: false) // TODO move this to mainview
                        })
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: resignNotification)) { _ in
                    lastActive = .now
                    Storage.main.mergeEntries()
                    DateHelper.main.stopTimeSlotTimer()
                    Storage.main.stopUpdateTimer()
                }
            // laterDo force restart MainView when calendar (ie time zone) changes
            // laterDo stop the current slot timer when the app resigns active and restart it when it becomes active
        }
    }
}
