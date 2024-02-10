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
        .scrollContentBackground(.hidden)
//        .gesture(DragGesture(minimumDistance: 20)
//            .onEnded { drag in
//                dateHelper.changeDay(forward: drag.translation.width < 0)
//            }
//        )
    }
    
    var dayTitle: some View {
        Text(dateHelper.day)
            .font(Font.custom("Baskerville", size: 20.0))
            .padding(.vertical, 10)
    }
    
    var entriesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack {
                    if let time = focusHelper.time, focusHelper.focus, let entry = storage.entries[time] {
                        VStack(spacing: 0) {
                            Spacer().frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900 + entry.duration)*20)
                            EntryFocusView(entry: entry)
                            Spacer()
                        }
                    }
                    HStack(spacing: 0) {
                        timeList
                        summaryList
                    }
                    DurationEditorView()
                }
//                Spacer().frame(height: focusHelper.time == nil ? 80 : 375)
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
                    HStack(spacing: 0) {
                        Text(dateHelper.hourStrings[time] ?? "")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(Color.white)
                            .background {
                                if let focusTime = focusHelper.time, let entry = storage.entries[focusTime], time >= focusTime && time < focusTime + entry.duration*900 {
                                    LinearGradient(colors: [.black, .white.opacity(0.1), .white], startPoint: .center, endPoint: .trailing)
                                } else {
                                    LinearGradient(colors: [.black], startPoint: .leading, endPoint: .trailing)
                                }
                            }
                        Color.white.frame(width: 1)
                    }
                }
                .frame(width: 40, height: 20)
                .padding(.bottom, (focusHelper.time ?? 0) + ((storage.entries[focusHelper.time ?? 0]?.duration ?? 0) - 1)*900 == time && focusHelper.focus ? 150 : 0)
                .id(time)
            }
        }
    }
    
    var summaryList: some View {
        VStack(spacing: 0) {
            ForEach(dateHelper.times, id: \.self) { time in
                if let entry = storage.entries[time] {
                    EntrySummaryView(time: time, entry: entry)
                        .frame(height: 20*CGFloat(entry.duration))
                        .padding(.bottom, focusHelper.time == time && focusHelper.focus ? 150 : 0)
                }
            }
        }
    }
}
