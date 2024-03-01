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
    @State var colors: [Int: Set<Int>] = [:]
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                VStack {
                    dayTitle
                    entriesList
                }
#if os(iOS)
                VStack(spacing: 0) {
                    Spacer()
                    colorButtons
                    Color.black.frame(height: 110)
                }
                .offset(y: focusHelper.focus ? 0 : 400)
                .animation(.easeInOut(duration: 0.3), value: focusHelper.focus)
#elseif os(macOS)
                if !focusHelper.editingText {
                    colorButtons.opacity(0)
                    dayButtons.opacity(0)
                    switchEntryWithArrowButtons.opacity(0)
                }
                focusButtons.opacity(0)
                switchEntryWithDButtons.opacity(0)
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
        Text(dateHelper.day)
            .font(Font.custom("Baskerville", size: 20.0))
            .padding(.vertical, 5)
    }
    
    var entriesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack {
                    if let time = focusHelper.time, focusHelper.focus, let entry = storage.entries[time] {
                        VStack(spacing: 0) {
                            Spacer().frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900 + entry.duration)*slotHeight)
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
#if os(iOS)
            ZStack {
                Text(name)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if !entry.colors.contains(num) {
                    color
                }
            }
            .animation(nil, value: FocusHelper.main.time)
            .onTapGesture(perform: changeColor)
#elseif os(macOS)
            Button(name, action: changeColor)
                .keyboardShortcut(Categories.keyFromNum[num], modifiers: [])
#endif
        }
        
        func changeColor() {
            guard let time = focusHelper.time, let entry = Storage.main.entries[time] else { return }
            if entry.colors.contains(num) {
                entry.colors.remove(num)
            } else {
                entry.colors.insert(num)
            }
            updating.toggle()
        }
    }
    
    var dayButtons: some View {
        VStack(spacing: 0) {
            Button("previous day") {
                dateHelper.changeDay(forward: false)
            }
            .keyboardShortcut(.leftArrow, modifiers: [])
            Button("next day") {
                dateHelper.changeDay(forward: true)
            }
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
    
    var switchEntryWithArrowButtons: some View {
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
            .keyboardShortcut(.upArrow, modifiers: [])
            Button("next entry") {
                if var time = focusHelper.time {
                    repeat {
                        time += 900
                        guard dateHelper.times.contains(time) else { return }
                    } while storage.entries[time] == nil
                    focusHelper.changeTime(to: time, animate: false)
                }
            }
            .keyboardShortcut(.downArrow, modifiers: [])
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
        VStack(spacing: 0) {
            Button("focus") {
                if focusHelper.editingText {
                    return
                } else if focusHelper.focus {
                    focusHelper.editingText = true
                } else if focusHelper.time != nil {
                    withAnimation {
                        focusHelper.focus = true
                        focusHelper.adjustScroll()
                    }
                } else {
                    focusHelper.changeTime(to: dateHelper.getPertinentSlot())
                }
            }
            .keyboardShortcut("e", modifiers: [.command])
            Button("unfocus") {
                if focusHelper.editingText {
                    focusHelper.editingText = false
                } else if focusHelper.focus {
                    withAnimation {
                        focusHelper.focus = false
                        focusHelper.adjustScroll()
                    }
                } else {
                    withAnimation {
                        focusHelper.changeTime(to: nil)
                    }
                }
            }
            .keyboardShortcut("e", modifiers: [.command, .option])
        }
    }
}
