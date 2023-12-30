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
    @State var isCurrentTime: Bool
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            Color.white
                .frame(height: DateHelper.main.hourStrings[time] != nil ? 2 : 1)
            HStack(spacing: 0) {
                ZStack {
                    if isCurrentTime {
                        Color.white
                        Text(DateHelper.main.hourStrings[time] ?? "")
                            .foregroundStyle(Color.black)
                    } else {
                        Color.black
                        Text(DateHelper.main.hourStrings[time] ?? "")
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(width: 40)
                Rectangle()
                    .foregroundStyle(Color.white)
                    .frame(width: 1)
                ZStack {
//                    TODO add in a color thing that HStacks color based on the colors listed
//                    if #available(macOS 14.0, *) {
                    HStack(spacing: 0) {
                        Spacer()
                        Text(entry.text == promptText ? "" : entry.text)
                            .lineLimit(1) // laterDO allow for multiple lines? honestly maybe not
//                            .multilineTextAlignment(.center)
                            .id(time)
                        Spacer()
                    }.background { Color.black }
                }
                    
            }
            .frame(height: 20)
        }
        .onTapGesture {
            ScrollHelper.main.focusTimeSlot = time
        }
    }
}
