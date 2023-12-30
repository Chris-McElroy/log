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
        .scrollContentBackground(.hidden)
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { drag in
                let w = drag.translation.width // no need for height because the scroll view overrides
                dateHelper.changeDay(forward: w < 0) // could add in limit for small w but that seems to already be filtered
                storage.loadEntries()
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
                        EntrySummaryView(entry: storage.entries[time] ?? Entry(""), time: time)
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
