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
    @ObservedObject var focusHelper = FocusHelper.main
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                ZStack {
                    VStack {
                        dayTitle
                        entriesList
                    }
                }
#if os(iOS)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
#endif
            }
            EntryFocusPopup()
        }
        .scrollContentBackground(.hidden)
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { drag in
                storage.mergeEntries()
                dateHelper.changeDay(forward: drag.translation.width < 0)
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
                HStack(spacing: 0) {
                    timeList
                    Color.white.frame(width: 1)
                    summaryList
                }
                Spacer().frame(height: focusHelper.time == nil ? 80 : 375)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                focusHelper.scrollProxy = proxy
            }
        }
    }
    
    var timeList: some View {
        VStack(spacing: 0) {
            ForEach(dateHelper.times, id: \.self) { time in
                VStack(spacing: 0) {
                    if dateHelper.hourStrings[time] != nil {
                        Color.white
                            .frame(height: 1)
                    }
                    Text(dateHelper.hourStrings[time] ?? "")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(time == dateHelper.currentTimeSlot ? Color.black : Color.white)
                        .background(time == dateHelper.currentTimeSlot ? Color.white : Color.black)
                }
                .frame(width: 40, height: 20)
                .id(time)
            }
        }
    }
    
    var summaryList: some View {
        VStack(spacing: 0) {
            ForEach(dateHelper.times, id: \.self) { time in
                if let entry = storage.entries[time] {
                    EntrySummaryView(time: time, entry: entry)
                }
            }
        }
    }
}
