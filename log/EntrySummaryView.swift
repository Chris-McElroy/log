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
                Color.white.frame(height: 1)
            }
            HStack(spacing: 0) {
                Text(focusHelper.time == time && focusHelper.focus ? dateHelper.getTimeString() : entry.text)
                    .lineLimit(1)
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background {
            if entry.colors.isEmpty {
                Color.black
            } else {
                HStack(spacing: 0) {
                    ForEach(0..<16) { i in
                        let color = Categories.displayOrder[i]
                        if entry.colors.contains(color) {
                            Categories.colors[color]
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
