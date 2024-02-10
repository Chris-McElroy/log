//
//  EntrySummaryView.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

struct EntrySummaryView: View {
    @State var time: Int
    @State var colorsChanged: Bool = false
    
    @ObservedObject var entry: Entry
    @ObservedObject var storage: Storage = Storage.main
    @ObservedObject var dateHelper: DateHelper = DateHelper.main
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if dateHelper.hourStrings[time] != nil {
                    Color.white.frame(height: 1)
                }
                HStack(spacing: 0) {
                    Text(focusHelper.time == time && focusHelper.focus ? dateHelper.getTimeString() : entry.text)
                        .lineLimit(1)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 6)
                    Spacer().frame(height: colorsChanged ? 2 : 15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: entry.colors) { colorsChanged.toggle() }
            }
        }
        .background {
            HStack(spacing: 0) {
                ForEach(0..<16) { i in
                    let color = Categories.displayOrder[i]
                    if entry.colors.contains(color) {
                        Categories.colors[color]
                    }
                }
            }
        }
        .background(Color.black)
        .onTapGesture {
            withAnimation {
                focusHelper.changeTime(to: time)
            }
        }
        .onChange(of: entry.text, entry.updateLastEdit)
        .onChange(of: entry.duration, entry.updateLastEdit)
        .onChange(of: entry.colors, entry.updateLastEdit)
    }
}
