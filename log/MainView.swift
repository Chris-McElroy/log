//
//  MainView.swift
//  log
//
//  Created by 4 on 9/26/23.
//

import SwiftUI

var scrollProxy: ScrollViewProxy? = nil
var currentSlot: Int = Int(Date.now.timeIntervalSince(Calendar.current.startOfDay(for: .now))/900)

struct MainView: View {
    @State var entries: [Int: Entry] = Storage.main.getEntries(on: DateHelper.day())
    @State var focusTime: Int? = nil
    @State var times: [Int] = [] // [-9000, -8100] etc TODO generate, should equal timeStrings.keys
    @State var hourStrings: [Int: String] = [:] // converts times that line up to the hours to short time strings
    @State var timeStrings: [Int: String] = [:] // converts times to long time strings, for all gtimes
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(times, id: \.self) { time in
                            // TODO make this a separate file/struct
                            VStack(spacing: 0) {
                                if abs(Double(currentSlot - slot) + 0.5) < 1 {
                                    Color.red
                                        .frame(height: (slot % 4) == 0 ? 2 : 1)
                                } else {
                                    Color.white
                                        .frame(height: (slot % 4) == 0 ? 2 : 1)
                                }
                                HStack(spacing: 0) {
                                    ZStack {
                                        Color.black
                                        Text(DateHelper.shortTimeString(slot))
                                    }
                                    .frame(width: 40)
                                    
                                    Rectangle()
                                        .foregroundColor(currentSlot == slot ? .red : .white)
                                        .frame(width: 1)
                                    ZStack {
        //                                TODO add in a color thing that HStacks color based on the colors listed
        //                                if #available(macOS 14.0, *) {
                                        HStack(spacing: 0) {
                                            Spacer()
                                            Text(activity[slot] ?? "testey")
            //                                    .multilineTextAlignment(.center)
            //                                    .padding(.top, 5)
                                                .id(slot)
//                                                .scrollContentBackground(.hidden) // hides the background of the scrolling content, i don't think this is important/necessary
            //                                        .focused($focusedText, equals: h+96)
            //                                        .onKeyPress(.return, action: {
            //                                            focusedText = nil
            //                                            return .handled
            //                                        })
            //                                }
                                            Spacer()
                                        }.background { Color.black }
                                    }
                                        
                                }
                                .frame(height: 20)
                                .onTapGesture {
                                    focusSlot = slot
                                }
                            }
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                    .foregroundStyle(.white)
                }
        //        .onAppear {
        //            focusedText = 10
        //        }
                
            }
            
    //        VStack(spacing: 0) {
    //            Spacer()
    //            ZStack {
    //                Rectangle().foregroundColor(.black)
    //                Text("hello")
    //            }
    //        }.opacity(halfFocus != nil ? 1 : 0)
            if let slot = focusSlot { // TODO also make this its own view/file/struct
                VStack(spacing: 0) {
                    if !fullFocus {
                        Color.black.opacity(0.1)
                            .frame(height: 400)
                            .onTapGesture {
                                focusSlot = nil
                            }
                    }
                    VStack {
                        Text("," + String(slot/4) + "." + String(15*((slot + 1000) % 4)))
                            .padding(.vertical, 15)
                        TextField("no text", text: .constant(activity[slot] ?? ""))
                            .multilineTextAlignment(.center)
//                            .lineLimit(10)
//                            .focused($fullFocus)
                    }
                    .background { Color.black }
//                    .onTapGesture {
//                        if !fullFocus {
//                            fullFocus = true
//                        }
//                    }
                }
                .gesture(DragGesture(minimumDistance: 20)
                    .onEnded { drag in
                        let h = drag.translation.height
                        let w = drag.translation.width
                        if h/abs(w) > 0.8 {
                            if fullFocus {
                                fullFocus = false
                            } else {
                                focusSlot = nil
                            }
                        }
                    }
                )
            }
        }
    }
}
