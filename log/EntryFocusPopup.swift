//
//  EntryFocusPopup.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI
import UIKit

let promptText = "tap to edit"

struct EntryFocusPopup: View {
    @State var durationDragLength: CGFloat? = nil
    
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
                            ForEach(0..<16) { color in
                                if entry.colors.contains(color) {
                                    Entry.colorList[color]
                                }
                            }
                        }
                    }
                ZStack {
                    TextEditor(text: $entry.text)
                        .multilineTextAlignment(.center)
                        .focused($isFocused)
                        .onChange(of: isFocused) {
                            if focusHelper.editingText != isFocused {
                                focusHelper.editingText = isFocused
                            }
                            if isFocused && entry.text == promptText {
                                entry.text = ""
                            } else if !isFocused && entry.text == "" {
                                entry.text = promptText
                            }
                            focusHelper.adjustScroll()
                        }
                        .onChange(of: focusHelper.editingText) {
                            if focusHelper.editingText != isFocused {
                                isFocused = focusHelper.editingText
                            }
                        }
                    if focusHelper.editingColors {
                        Color.black.opacity(0.05)
                    }
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
                Spacer().frame(height: 160)
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
                guard let time = focusHelper.time else { return }
                guard let entry = storage.entries[time] else { return }
                let height = drag.translation.height
                let travel = abs(abs(height) - (durationDragLength ?? 0))
                if travel > 20 {
                    durationDragLength = abs(height)
                    let newTime = height < 0 ?
                                    time - 900 : // if scrolling up, next entry is the one preceding current start
                                    time + 900   // if scrolling down, next entry is the one following current start
                    if height < 0 {
                        // if scrolling up, make sure next entry is blank
                        guard storage.entries[newTime]?.isEmpty() == true else { return }
                    } else {
                        // if scrolling down, make sure this entry will have positive duration
                        guard storage.entries[newTime] == nil && entry.duration > 1 else { return }
                    }
                    storage.entries[newTime] = entry
                    focusHelper.changeTime(to: newTime)
                    storage.entries[time] = height < 0 ? nil : Entry("")
                    entry.duration += height < 0 ? 1 : -1
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { _ in
                durationDragLength = nil
            }
    }
    
    var changeEntryDurationGesture: some Gesture {
        DragGesture()
            .onChanged { drag in
                guard let time = focusHelper.time else { return }
                guard let entry = storage.entries[time] else { return }
                let height = drag.translation.height
                let travel = abs(abs(height) - (durationDragLength ?? 0))
                if travel > 20 {
                    durationDragLength = abs(height)
                    let nextTime = height > 0 ?
                                        time + entry.duration*900 : // if scrolling down, next entry is the one following the end time
                                        time + entry.duration*900 - 900 // if scrolling up, the next entry is the bottom of this entry
                    if height > 0 {
                        // if scrolling down, make sure next entry is blank
                        guard storage.entries[nextTime]?.isEmpty() == true else { return }
                    } else {
                        // if scrolling up, make sure this entry will have positive duration
                        guard storage.entries[nextTime] == nil && entry.duration > 1 else { return }
                    }
                    entry.duration += height > 0 ? 1 : -1
                    storage.entries[nextTime] = height > 0 ? nil : Entry("")
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { _ in
                durationDragLength = nil
            }
    }
    
    var buttonRow: some View {
        HStack {
            editDurationButton
            Spacer()
            editColorsButton
            Spacer()
            moveFocusEarlierButton
            Spacer()
            moveFocusLaterButton
            Spacer()
            editTextButton
            Spacer()
            lowerPopupButton
        }
        .padding(.all, 20)
        .frame(height: 40)
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
    
    var colorButtons: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            if let time = focusHelper.time, let entry = storage.entries[time] {
                ForEach(0..<4) { row in
                    GridRow {
                        ForEach(0..<4) { column in
                            ColorButton(num: row*4 + column, entry: entry)
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
            name = ColorButton.nameList[num]
            color = Entry.colorList[num]
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
        
        static let nameList: [String] = [
            "hurting",
            "arousing",
            "relaxing",
            "eating",
            "exercising",
            "shopping",
            "meeting",
            "researching",
            "projecting",
            "socializing",
            "traveling",
            "communicating",
            "configuring",
            "householding",
            "thinking",
            "sleeping",
        ]
    }
}


