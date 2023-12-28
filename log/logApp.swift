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
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    currentSlot = Int(Date.now.timeIntervalSince(Calendar.current.startOfDay(for: .now))/900)
                    scrollProxy?.scrollTo(currentSlot, anchor: .center)
                }
                .onAppear {
                    Storage.main.pullData()
                }
                .font(Font.custom("Baskerville", size: 14.0))
        }
    }
}
