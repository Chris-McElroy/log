//
//  logApp.swift
//  log
//
//  Created by 4 on 9/26/23.
//

import SwiftUI

@main
struct logApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .font(Font.custom("Baskerville", size: 14.0))
                .buttonStyle(PlainButtonStyle())
//                .foregroundStyle(Color.white) // this was making everything error out?
                .background(Color.black, ignoresSafeAreaEdges: .all)
                .onAppear {
                    Storage.main.loadEntries()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    if let currentTime = DateHelper.main.getCurrentTimeSlot() {
                        FocusHelper.main.changeTime(to: currentTime, animate: false)
                    }
                }
            // laterDo force restart MainView when calendar (ie time zone) changes
            // laterDo stop the current slot timer when the app resigns active and restart it when it becomes active
        }
    }
}
