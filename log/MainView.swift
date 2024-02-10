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
        }
        .scrollContentBackground(.hidden)
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { drag in
                dateHelper.changeDay(forward: drag.translation.width < 0)
            }
        )
    }
    
    var dayTitle: some View {
        Text(dateHelper.day)
            .font(Font.custom("Baskerville", size: 20.0))
            .padding(.vertical, 5)
    }
    
    var entriesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(dateHelper.times, id: \.self) { time in
                        if let entry = storage.entries[time] {
                            EntryView(time: time, entry: entry)
                        }
                    }
                }
//                HStack(spacing: 0) {
//                    timeList
//                    Color.white.frame(width: 1)
//                    summaryList
//                }
                Spacer().frame(height: focusHelper.time == nil ? 80 : 375)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                focusHelper.scrollProxy = proxy
            }
        }
    }
    
    struct EntryView: View {
        @State var time: Int
        @State var entry: Entry
        @ObservedObject var dateHelper = DateHelper.main
        @ObservedObject var focusHelper = FocusHelper.main
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(0..<entry.duration, id: \.self) { i in
                            TimeSlotView(subtime: time + i*900, entryTime: time)
                        }
                    }
                    Color.white.frame(width: 1)
                    EntrySummaryView(time: time, entry: entry)
                }
                .frame(height: 20*CGFloat(entry.duration))
                if time == focusHelper.time && focusHelper.focus {
                    EntryFocusView(entry: entry)
                }
            }
        }
    }
    
    struct TimeSlotView: View {
        @State var subtime: Int
        @State var entryTime: Int
        @ObservedObject var dateHelper = DateHelper.main
        @ObservedObject var focusHelper = FocusHelper.main
        @ObservedObject var storage = Storage.main
        
        var body: some View {
            VStack(spacing: 0) {
                if dateHelper.hourStrings[subtime] != nil {
                    Color.white.frame(height: 1)
                }
                Text(dateHelper.hourStrings[subtime] ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(Color.white)
            }
//            .background(focusHelper.time == entryTime ? Color.white : Color.black)
            .background {
                if focusHelper.time == entryTime {
                    LinearGradient(colors: [.black, .white.opacity(0.1), .white], startPoint: .center, endPoint: .trailing)
                } else {
                    LinearGradient(colors: [.black], startPoint: .leading, endPoint: .trailing)
                }
            }
            .frame(width: 40)
            .id(subtime)
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
