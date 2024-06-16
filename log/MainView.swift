//
//  MainView.swift
//  log
//
//  Created by 4 on 9/26/23.
//

import SwiftUI

#if os(iOS)
let slotHeight: CGFloat = 28
let fontSize: CGFloat = 15
#elseif os(macOS)
let slotHeight: CGFloat = 20
let fontSize: CGFloat = 13
#endif

struct MainView: View {
    @ObservedObject var storage = Storage.main
    @ObservedObject var dateHelper = DateHelper.main
    @ObservedObject var focusHelper = FocusHelper.main
    @State var updating = false
    @State var colors: [Int: Int] = [:]
    @State var testtext = "hi i'm some text!" // TODO remove
    
    var body: some View {
        GeometryReader { gr in
            ZStack {
                VStack {
                    StatsView()
                        .frame(height: focusHelper.stats ? nil : 0)
                        .opacity(focusHelper.stats ? 1 : 0)
                    dayTitle
                    Spacer().frame(height: focusHelper.stats ? 100 : 0)
                    entriesList
                        .frame(height: focusHelper.stats ? 0 : nil)
                }
#if os(macOS)
                .background(KeyPressHelper())
                .onChange(of: focusHelper.editingText) {
                    if !focusHelper.editingText {
                        KeyPressHelper.reattach()
                    }
                }
#endif
#if os(macOS)
                if focusHelper.editingText {
                    switchEntryWithDButtons.opacity(0)
                    focusButtons.opacity(0)
                }
#elseif os(iOS)
                VStack(spacing: 0) {
                    Spacer()
                    colorButtons
                    Color.black.frame(height: 110)
                }
                .offset(y: focusHelper.focus ? 0 : 400)
                .animation(.easeInOut(duration: 0.3), value: focusHelper.focus)
#endif
            }
#if os(iOS)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
#endif
        }
        .scrollContentBackground(.hidden)
//        .onAppear(colors) // TODO have colors be linked to the thing to see if that solves this with less delay than the observed object shit. i think it might. and then i think there might be a way to pin everything here or something, idk.
#if os(iOS)
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { drag in
                dateHelper.changeDay(forward: drag.translation.width < 0)
            }
        )
#endif
    }
    
    var dayTitle: some View {
        Text(dateHelper.dayTitle)
            .font(Font.custom("Baskerville", size: 20.0))
            .padding(.vertical, 5)
            .gesture(DragGesture(minimumDistance: 20)
                .onEnded { drag in
                    guard focusHelper.time == nil else { return }
                    if abs(drag.translation.height) > abs(drag.translation.width) {
                        if (drag.translation.height < 0) == focusHelper.stats {
                            withAnimation(.linear) {
                                focusHelper.stats.toggle()
                            }
                        }
                    }
                })
    }
    
    var entriesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack {
                    VStack(spacing: 0) {
                        if let time = focusHelper.time, focusHelper.focus, let entry = storage.entries[time] {
                            Spacer().frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900 + entry.duration)*slotHeight)
                        }
                        EntryFocusView()
                        Spacer()
                    }
                    .animation(.none, value: focusHelper.focus)
                    .animation(.none, value: focusHelper.time)
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
                            .animation(.none, value: focusHelper.time)
                        Color.white.frame(width: 1)
                    }
                }
                .onTapGesture {
                    withAnimation {
                        focusHelper.changeTime(to: nil)
                    }
                }
                .frame(width: 40, height: slotHeight)
                .padding(.bottom, (focusHelper.time ?? 0) + ((storage.entries[focusHelper.time ?? 0]?.duration ?? 0) - 1)*900 == time && focusHelper.focus ? 150 : 0)
                .id(time)
            }
        }
    }
    
    var summaryList: some View {
        VStack(spacing: 0) {
            ForEach(dateHelper.times, id: \.self) { time in
                if let entry = storage.entries[time] {
                    EntrySummaryView(time: time, updating: $updating, entry: entry)
                        .frame(height: slotHeight*CGFloat(entry.duration))
                        .padding(.bottom, focusHelper.time == time && focusHelper.focus ? 150 : 0)
                }
            }
        }
    }
    
    var colorButtons: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            if let time = focusHelper.time, let entry = storage.entries[time] {
                ForEach(0..<4) { row in
                    GridRow {
                        ForEach(0..<4) { column in
                            ColorButton(num: Categories.numFromPos[row][column], entry: entry, updating: $updating)
                                .frame(height: 70)
                        }
                    }
                }
            }
        }
        .frame(height: 280)
        .background(Color.black)
    }
    
    struct ColorButton: View {
        let num: Int
        let name: String
        let color: Color
        @Binding var updating: Bool
        @ObservedObject var entry: Entry
        @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
        
        init(num: Int, entry: Entry, updating: Binding<Bool>) {
            self.num = num
            name =  Categories.names[num]
            color = Categories.colors[num]
            self.entry = entry
            self._updating = updating
        }
        
        var body: some View {
            ZStack {
                Text(name)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if entry.colors & (1 << num) == 0 {
                    color
                }
            }
            .animation(nil, value: FocusHelper.main.time)
            .onTapGesture(perform: changeColor)
        }
        
        func changeColor() {
            guard let time = focusHelper.time, let entry = Storage.main.entries[time] else { return }
            entry.colors ^= 1 << num
            updating.toggle()
        }
    }
    
    var switchEntryWithDButtons: some View {
        VStack(spacing: 0) {
            Button("previous entry") {
                if var time = focusHelper.time {
                    repeat {
                        time -= 900
                        guard dateHelper.times.contains(time) else { return }
                    } while storage.entries[time] == nil
                    focusHelper.changeTime(to: time, animate: false)
                }
            }
            .keyboardShortcut("d", modifiers: [.command, .option])
            Button("next entry") {
                if var time = focusHelper.time {
                    repeat {
                        time += 900
                        guard dateHelper.times.contains(time) else { return }
                    } while storage.entries[time] == nil
                    focusHelper.changeTime(to: time, animate: false)
                }
            }
            .keyboardShortcut("d", modifiers: [.command])
        }
    }
    
    var focusButtons: some View {
        Button("unfocus") {
            if focusHelper.editingText {
                focusHelper.editingText = false
            }
        }
        .keyboardShortcut("e", modifiers: [.command, .option])
    }
}
