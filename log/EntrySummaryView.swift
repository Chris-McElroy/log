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
    
    @Binding var updating: Bool
    @ObservedObject var entry: Entry
    @ObservedObject var storage: Storage = Storage.main
    @ObservedObject var dateHelper: DateHelper = DateHelper.main
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    @State var colorInt: Int = 0
    
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        //.frame(height: colorsChanged ? 2 : 15)
                }
                .onAppear {
                    colorInt = entry.colors
                }
//                .onChange(of: focusHelper.time) {
//                    if focusHelper.time == time { print("changing") }
//                    self.currentEntry = storage.entries[focusHelper.time ?? 0] ?? Entry()
//                }
//                .onChange(of: currentEntry.colors) {
//                    print("colors changed!")
//                }
            }
        }
        .background {
            HStack(spacing: 0) {
                ForEach(0..<16) { i in
                    let color = Categories.displayOrder[i]
//                    if entry.colors.contains(color) {
//                        Categories.colors[color]
//                    }
                    if colorInt & (1 << color) != 0 {
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
        .onChange(of: entry.colors) {
            colorInt = entry.colors
        }
        .onChange(of: colorInt) {
            entry.colors = colorInt
        }
    }
}
