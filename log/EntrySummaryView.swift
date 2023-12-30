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
