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
                .padding(.bottom, 1)
                .font(Font.custom("Baskerville", size: 14.0))
//                .foregroundStyle(Color.white) // this was making everything error out?
                .background(Color.black, ignoresSafeAreaEdges: .all)
            
                .onAppear {
                    Storage.main.loadEntries()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    ScrollHelper.main.focusTimeSlot = DateHelper.main.getCurrentTimeSlot()
                    ScrollHelper.main.mainViewScrollProxy?.scrollTo(ScrollHelper.main.focusTimeSlot, anchor: .top)
                }
            // TODO force restart MainView when calendar (ie time zone) changes
        }
    }
}
