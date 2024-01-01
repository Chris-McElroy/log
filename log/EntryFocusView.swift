//
//  EntryFocusView.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI
import UIKit

let promptText = "tap to edit"

struct EntryFocusView: View {
    @ObservedObject var entry: Entry
    @FocusState var isFocused: Bool
    @State var editingColors: Bool = false
    @State var editingDuration: Bool = false
    @State var durationDragLength: CGFloat? = nil
    let time: Int
    let timeString: String

    init(entry: Entry, time: Int) {
        self.entry = entry
        self.time = time
        timeString = DateHelper.main.getTimeString(start: time, duration: entry.duration)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if editingDuration {
                Color.black.opacity(0.05)
                    .gesture(DragGesture()
                        .onChanged { drag in
                            // TODO add haptic feedback
                            // TODO make sure it doesn't override real entries
                            let height = drag.translation.height
                            let travel = abs(abs(height) - (durationDragLength ?? 0))
                            print("drag", height, travel, drag.startLocation.y < UIScreen.main.bounds.height/2)
                            if travel > 20 {
                                durationDragLength = abs(height)
                                if drag.startLocation.y < UIScreen.main.bounds.height/2 {
                                    let newTime = height < 0 ? time - 900 : time + 900
                                    // top
                                    Storage.main.entries[time] = Entry("")
                                    Storage.main.entries[newTime] = entry
                                    entry.duration += height < 0 ? 1 : -1
                                    ScrollHelper.main.focusTimeSlot = newTime
                                    // TODO handle if the new time is off then DateHelper time list
                                } else {
                                    entry.duration += height < 0 ? 1 : -1
                                }
                            }
                        }
                        .onEnded { _ in
                            durationDragLength = nil
                        }
                    )
            } else {
                Spacer()
            }
            VStack(spacing: 0) {
                Text(timeString)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
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
                    if editingColors {
                        Color.black.opacity(0.05)
                    }
                }
                .frame(height: editingDuration ? 1 : 200)
                HStack {
                    Button("", systemImage: "arrow.up.and.line.horizontal.and.arrow.down") {
                        if isFocused || editingColors {
                            isFocused = false
                            editingColors = false
                            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                                withAnimation {
                                    editingDuration.toggle()
                                    ScrollHelper.main.changeFocusTimeSlot(to: time, center: editingDuration)
                                }
                            }
                            return
                        }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            editingDuration.toggle()
                            ScrollHelper.main.changeFocusTimeSlot(to: time, center: editingDuration)
                        }
                    }
                    Spacer()
                    Button("", systemImage: "rectangle.grid.2x2") {
                        if isFocused || editingDuration {
                            isFocused = false
                            editingDuration = false
                            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                                withAnimation {
                                    editingColors.toggle()
                                }
                            }
                            return
                        }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            editingColors.toggle()
                        }
                    }
                    Spacer()
                    Button("", systemImage: "arrow.up") {
                        ScrollHelper.main.changeFocusTimeSlot(to: time - 900, keyboardUp: isFocused)
                    }
                    Spacer()
                    Button("", systemImage: "arrow.down") {
                        ScrollHelper.main.changeFocusTimeSlot(to: time + 900, keyboardUp: isFocused)
                    }
                    Spacer()
                    Button("", systemImage: isFocused ? "keyboard.chevron.compact.down" : "keyboard") {
                        if isFocused {
                            isFocused = false
                        } else if !editingColors && !editingDuration {
                            isFocused = true
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                editingColors = false
                                editingDuration = false
                            }
                            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                                isFocused = true
                            }
                        }
                    }
                    Spacer()
                    Button("", systemImage: "chevron.down.square") {
                        if isFocused {
                            isFocused = false
                            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                                withAnimation {
                                    ScrollHelper.main.focusTimeSlot = nil
                                }
                            }
                            return
                        }
                        withAnimation { // TODO have this lower instead of fade in
                            editingColors = false
                            editingDuration = false
                            ScrollHelper.main.focusTimeSlot = nil
                        }
                    }
                }
                .padding(.all, 20)
                if editingColors {
                    colorButtons
                }
                Color.black
                    .frame(height: 80)
            }
            .background(Color.black)
            .offset(x: 0, y: 90)
        }
        .onChange(of: isFocused) {
            if isFocused {
                if entry.text == promptText {
                    entry.text = ""
                }
            } else {
                if entry.text == "" {
                    entry.text = promptText
                }
            }
            ScrollHelper.main.changeFocusTimeSlot(to: time, animate: true, keyboardUp: isFocused)
        }
    }
    
    var colorButtons: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<4) { row in
                GridRow {
                    ForEach(0..<4) { column in
                        ColorButton(num: row*4 + column, selected: {
                            return entry.colors.contains(row*4 + column)
                        })
                    }
                }
            }
        }
    }
    
    struct ColorButton: View {
        let num: Int
        let name: String
        let color: Color
        let selected: () -> Bool
        
        init(num: Int, selected: @escaping () -> Bool) {
            self.num = num
            name = ColorButton.nameList[num]
            color = Entry.colorList[num]
            self.selected = selected
        }
        
        var body: some View {
            Text(selected() ? name : "")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(selected() ? Color.black : color)
                .onTapGesture {
                    if let time = ScrollHelper.main.focusTimeSlot {
                        if selected() {
                            Storage.main.entries[time]?.colors.remove(num)
                        } else {
                            Storage.main.entries[time]?.colors.insert(num)
                        }
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
