//
//  EntryFocusPopup.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

let promptText = "tap to edit"

struct EntryFocusPopup: View {
    @State var lastDragHeight: CGFloat? = nil
    @State var movingStart: Bool? = nil
    
    @ObservedObject var storage = Storage.main
    @ObservedObject var dateHelper = DateHelper.main
    @ObservedObject var focusHelper = FocusHelper.main
    
    var body: some View {
        VStack(spacing: 0) {
            durationEditor
            VStack(spacing: 0) {
                if let time = focusHelper.time, let entry = storage.entries[time] {
                    EntryFocusView(entry: entry)
                }
                buttonRow
                if focusHelper.editingColors {
                    colorButtons
                }
                Color.black.frame(height: 110)
            }
            .background(Color.black)
        }
        .offset(x: 0, y: focusHelper.time == nil ? 200 : 105)
    }
    
    struct EntryFocusView: View {
        @ObservedObject var entry: Entry
        @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
        @FocusState var isFocused: Bool
        
        var body: some View {
            VStack(spacing: 0) {
                Text(DateHelper.main.getTimeString())
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
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
                TextEditor(text: $entry.text)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .onChange(of: isFocused) {
                        focusHelper.editingText = isFocused
                        focusHelper.editingColors = false
                        
                        if isFocused && entry.text == promptText {
                            entry.text = ""
                        } else if !isFocused && entry.text == "" {
                            entry.text = promptText
                        }
                        focusHelper.adjustScroll()
                    }
                    .onChange(of: focusHelper.editingText) {
                        isFocused = focusHelper.editingText
                    }
                .frame(height: focusHelper.editingDuration ? 1 : 200)
            }
        }
    }
    
    var durationEditor: some View {
        VStack(spacing: 0) {
            if focusHelper.editingDuration {
                Color.black.opacity(0.0001)
                    .gesture(changeEntryStartGesture)
                Color.black.opacity(0.0001)
                    .gesture(changeEntryDurationGesture)
            } else {
                Spacer()
            }
        }
    }
    
    var changeEntryStartGesture: some Gesture {
        DragGesture()
            .onChanged { drag in
                guard let scrollingUp = scrollingUp(for: drag) else { return }
                guard let time = focusHelper.time else { return }
                guard let entry = storage.entries[time] else { return }
                movingStart = (movingStart ?? true) ? entry.duration > 1 || scrollingUp : entry.duration == 1 && scrollingUp
                if movingStart == true {
                    if scrollingUp {
                        moveEntryStartEarlier(entry: entry, time: time)
                    } else {
                        moveEntryStartLater(entry: entry, time: time)
                    }
                } else {
                    if scrollingUp {
                        moveEntryEndEarlier(entry: entry, time: time)
                    } else {
                        moveEntryEndLater(entry: entry, time: time)
                    }
                }
            }
            .onEnded { _ in
                lastDragHeight = nil
                movingStart = nil
            }
    }
    
    var changeEntryDurationGesture: some Gesture {
        DragGesture()
            .onChanged { drag in
                guard let scrollingUp = scrollingUp(for: drag) else { return }
                guard let time = focusHelper.time else { return }
                guard let entry = storage.entries[time] else { return }
                movingStart = (movingStart ?? false) ? entry.duration > 1 || scrollingUp : entry.duration == 1 && scrollingUp
                if movingStart == true {
                    if scrollingUp {
                        moveEntryStartEarlier(entry: entry, time: time)
                    } else {
                        moveEntryStartLater(entry: entry, time: time)
                    }
                } else {
                    if scrollingUp {
                        moveEntryEndEarlier(entry: entry, time: time)
                    } else {
                        moveEntryEndLater(entry: entry, time: time)
                    }
                }
            }
            .onEnded { _ in
                lastDragHeight = nil
                movingStart = nil
            }
    }
    
    func scrollingUp(for drag: DragGesture.Value) -> Bool? {
        let height = drag.translation.height
        let travel = height - (lastDragHeight ?? 0)
        if abs(travel) > 20 {
            lastDragHeight = height
            return travel < 0
        }
        return nil
    }
    
    func moveEntryStartEarlier(entry: Entry, time: Int) {
        let newTime = time - 900 // just above the entry start
        guard storage.entries[newTime]?.isEmpty() == true else { return } // next entry is blank
        storage.entries[newTime] = entry
        entry.duration += 1
        focusHelper.changeStartTime(to: newTime)
        storage.entries[time] = nil
        storage.saveEntries()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func moveEntryStartLater(entry: Entry, time: Int) {
        let newTime = time + 900 // just below the entry start
        guard storage.entries[newTime] == nil else { return } // entry was marked nil
        storage.entries[newTime] = entry
        entry.duration -= 1
        focusHelper.changeStartTime(to: newTime)
        storage.entries[time] = Entry("")
        storage.saveEntries()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func moveEntryEndEarlier(entry: Entry, time: Int) {
        let nextTime = time + entry.duration*900 - 900 // end of the entry
        guard storage.entries[nextTime] == nil else { return } // entry was marked nil
        entry.duration -= 1
        focusHelper.adjustScroll()
        storage.entries[nextTime] = Entry("")
        storage.saveEntries()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func moveEntryEndLater(entry: Entry, time: Int) {
        let nextTime = time + entry.duration*900 // just below the entry end
        guard storage.entries[nextTime]?.isEmpty() == true else { return } // next entry is blank
        entry.duration += 1
        focusHelper.adjustScroll()
        storage.entries[nextTime] = nil
        storage.saveEntries()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    var buttonRow: some View {
        HStack {
            editDurationButton
            editColorsButton
            moveFocusEarlierButton
            moveFocusLaterButton
            editTextButton
            lowerPopupButton
        }
        .buttonStyle(FocusButtons())
//        .padding(.horizontal, 20)
        .frame(height: 50)
    }
    
    var editDurationButton: some View {
        Button("", systemImage: "arrow.up.and.line.horizontal.and.arrow.down") {
            if focusHelper.editingText || focusHelper.editingColors {
                focusHelper.editingText = false
                focusHelper.editingColors = false
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                    withAnimation {
                        focusHelper.editingDuration.toggle()
                        focusHelper.adjustScroll()
                    }
                }
                return
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                focusHelper.editingDuration.toggle()
                focusHelper.adjustScroll()
            }
        }
    }
    
    var editColorsButton: some View {
        Button("", systemImage: "rectangle.grid.2x2") {
            if focusHelper.editingText || focusHelper.editingDuration {
                focusHelper.editingText = false
                focusHelper.editingDuration = false
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        focusHelper.editingColors.toggle()
                        focusHelper.adjustScroll()
                    }
                }
                return
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                focusHelper.editingColors.toggle()
                focusHelper.adjustScroll()
            }
        }
    }
    
    var moveFocusEarlierButton: some View {
        Button("", systemImage: "arrow.up") {
            guard let time = focusHelper.time else { return }
            var newTime = time - 900
            while storage.entries[newTime] == nil {
                newTime -= 900
                if newTime < dateHelper.times[0] { return }
            }
            focusHelper.changeTime(to: newTime)
        }
    }
    
    var moveFocusLaterButton: some View {
        Button("", systemImage: "arrow.down") {
            guard let time = focusHelper.time else { return }
            var newTime = time + 900
            while storage.entries[newTime] == nil {
                newTime += 900
                if newTime > dateHelper.times.last ?? 0 { return }
            }
            focusHelper.changeTime(to: newTime)
        }
    }
    
    var editTextButton: some View {
        Button("", systemImage: focusHelper.editingText ? "keyboard.chevron.compact.down" : "keyboard") {
            if focusHelper.editingText {
                focusHelper.editingText = false
            } else if !focusHelper.editingColors && !focusHelper.editingDuration {
                focusHelper.editingText = true
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    focusHelper.editingColors = false
                    focusHelper.editingDuration = false
                }
                Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                    focusHelper.editingText = true
                }
            }
        }
    }
    
    var lowerPopupButton: some View {
        Button("", systemImage: "chevron.down.square") {
            if focusHelper.editingText {
                focusHelper.editingText = false
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        focusHelper.changeTime(to: nil)
                    }
                }
                return
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                focusHelper.editingColors = false
                focusHelper.editingDuration = false
                focusHelper.changeTime(to: nil)
            }
        }
    }
    
    struct FocusButtons: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            HStack {
                Spacer()
                configuration.label
                    .opacity(1.0)
                    .padding(.vertical, 20)
                Spacer()
            }
        }
    }
    
    var colorButtons: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            if let time = focusHelper.time, let entry = storage.entries[time] {
                ForEach(0..<4) { row in
                    GridRow {
                        ForEach(0..<4) { column in
                            ColorButton(num: Categories.numFromPos[row][column], entry: entry)
                        }
                    }
                }
            }
        }
        .frame(height: 280)
    }
    
    struct ColorButton: View {
        let num: Int
        let name: String
        let color: Color
        @ObservedObject var entry: Entry
        
        init(num: Int, entry: Entry) {
            self.num = num
            name =  Categories.names[num]
            color = Categories.colors[num]
            self.entry = entry
        }
        
        var body: some View {
            Text(entry.colors.contains(num) ? name : "")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(entry.colors.contains(num) ? Color.black : color)
                .onTapGesture {
                    if entry.colors.contains(num) {
                        entry.colors.remove(num)
                    } else {
                        entry.colors.insert(num)
                    }
                }
        }
    }
}


