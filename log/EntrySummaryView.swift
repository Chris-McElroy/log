//
//  EntrySummaryView.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

struct EntrySummaryView: View {
    @ObservedObject var entry: Entry
    @State var time: Int
    @ObservedObject var dateHelper: DateHelper = DateHelper.main
    @ObservedObject var scrollHelper: ScrollHelper = ScrollHelper.main
    
    var body: some View {
        VStack(spacing: 0) {
            Color.white
                .frame(height: dateHelper.hourStrings[time] != nil ? 2 : 1)
            HStack(spacing: 0) {
                ZStack {
                    if time == dateHelper.currentTimeSlot {
                        Color.white
                        Text(dateHelper.hourStrings[time] ?? "")
                            .foregroundStyle(Color.black)
                    } else {
                        Color.black
                        Text(dateHelper.hourStrings[time] ?? "")
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(width: 40)
                Color.white
                    .frame(width: 1)
                ZStack {
//                    if #available(macOS 14.0, *) {
                    HStack(spacing: 0) {
                        Spacer()
                        Text(entry.text == promptText ? "" : entry.text)
                            .lineLimit(1) // laterDO allow for multiple lines? honestly maybe not
//                            .multilineTextAlignment(.center)
                            .id(time)
                        Spacer()
                    }
                }
                    
            }
            .frame(height: 20*CGFloat(entry.duration))
            .offset(y: 10*CGFloat(entry.duration - 1))
            .background {
                if ScrollHelper.main.focusTimeSlot == time {
                    Color(hue: 0, saturation: 0, brightness: 0.34)
                } else if entry.colors.isEmpty {
                    Color.black
                } else {
                    HStack(spacing: 0) {
                        Color.black.frame(width: 41)
                        ForEach(0..<16) { color in
                            if entry.colors.contains(color) {
                                Entry.colorList[color]
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation {
                ScrollHelper.main.changeFocusTimeSlot(to: time)
            }
        }
    }
}
