//
//  EntryFocusPopup.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

let promptText = "tap to edit"

struct EntryFocusView: View {
    @ObservedObject var entry: Entry
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    @FocusState var isFocused: Bool
    
    var body: some View {
        TextEditor(text: $entry.text)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .padding(.all, 8)
            .frame(height:  150)
            .onChange(of: isFocused) {
                focusHelper.editingText = isFocused
                focusHelper.editingColors = false
                
                if isFocused && entry.text == promptText {
                    entry.text = "" // TODO weed out prompttext in loading
                }
                focusHelper.adjustScroll()
            }
            .onChange(of: focusHelper.editingText) {
                isFocused = focusHelper.editingText
            }
    }
}

struct EntryFocusPopup: View {
    @ObservedObject var storage = Storage.main
    @ObservedObject var dateHelper = DateHelper.main
    @ObservedObject var focusHelper = FocusHelper.main
    
    var body: some View {
        VStack(spacing: 0) {
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


