//
//  MainView.swift
//  log
//
//  Created by 4 on 9/26/23.
//

import SwiftUI


struct MainView: View {
    @ObservedObject var storage = Storage.main
    @ObservedObject var dateHelper = DateHelper.main
    @ObservedObject var scrollHelper = ScrollHelper.main
    
    var body: some View {
        ZStack {
            VStack {
                dayTitle
                entriesList
            }
            if let time = ScrollHelper.main.focusTimeSlot {
                if let entry = storage.entries[time] {
                    EntryFocusView(entry: entry, time: time)
                }
            }
        }
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { drag in
                let w = drag.translation.width // no need for height because the scroll view overrides
                print(w)
                if w < 0 && abs(w) > 10 {
//                    dateHelper
//                    storage.entries = MainView.loadAndGetEntries()
                }
            }
        )
    }
    
    var dayTitle: some View {
        Text(dateHelper.day)
            .font(Font.custom("Baskerville", size: 20.0))
            .padding(.vertical, 10)
    }
    
    var entriesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(dateHelper.times, id: \.self) { time in
                        EntrySummaryView(entry: storage.entries[time] ?? Entry(""),
                                         time: time,
                                         isCurrentTime: time == dateHelper.currentTimeSlot())
                    }
                }
                .onAppear {
                    scrollHelper.mainViewScrollProxy = proxy
                    proxy.scrollTo(scrollHelper.focusTimeSlot, anchor: .top)
                    // TODO anchor like 3/4 of the way up for ios
                }
            }
        }
    }
}