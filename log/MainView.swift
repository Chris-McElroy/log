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
            GeometryReader { _ in
                ZStack {
                    VStack {
                        dayTitle
                        entriesList
                    }
                }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            if let time = ScrollHelper.main.focusTimeSlot { // TODO remove these ifs, focus view should always be there, just hidden
                if let entry = storage.entries[time] {
                    EntryFocusView(entry: entry, time: time)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { drag in
                let w = drag.translation.width // no need for height because the scroll view overrides
                dateHelper.changeDay(forward: w < 0)
                storage.loadEntries()
            }
        )
        .onChange(of: scrollHelper.focusTimeSlot) { old, new in
            if let old {
                if storage.entries[old]?.text == promptText { // TODO move these to entry focus view when that's always active, ensure it doesn't happen when isFocused
                    storage.entries[old]?.text = ""
                }
            }
            storage.saveEntries()
            if let new {
                if storage.entries[new]?.text == "" {
                    storage.entries[new]?.text = promptText
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            storage.saveEntries()
        }
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
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
