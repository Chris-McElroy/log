//
//  EntrySummaryView.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

struct EntrySummaryView: View {
    @State var time: Int
    @ObservedObject var entry: Entry
    @ObservedObject var storage: Storage = Storage.main
    @ObservedObject var dateHelper: DateHelper = DateHelper.main
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    
    var body: some View {
        VStack(spacing: 0) {
            if dateHelper.hourStrings[time] != nil {
                Color.white
                    .frame(height: 1)
            }
            Text(entry.text == promptText ? "" : entry.text)
                .lineLimit(1)
                .foregroundStyle(focusHelper.time == time ? Color.black : Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 20*CGFloat(entry.duration))
        .background {
            if focusHelper.time == time {
                Color.white // Color(hue: 0, saturation: 0, brightness: 0.34)
            } else if entry.colors.isEmpty {
                Color.black
            } else {
                HStack(spacing: 0) {
                    ForEach(0..<16) { color in
                        if entry.colors.contains(color) {
                            Entry.colorList[color]
                        }
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation {
                focusHelper.changeTime(to: time)
            }
        }
        
    }
}
