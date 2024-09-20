//
//  EntryFocusPopup.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

let promptText = "tap to edit"

struct EntryFocusView: View {
    @State var text = ""
    @State var textEditTime: Int = Int.max
    @State var textEditDay: String = ""
    @ObservedObject var entry: Entry = Storage.main.currentEntry
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    @ObservedObject var dateHelper: DateHelper = DateHelper.main
    @ObservedObject var storage: Storage = Storage.main
    @FocusState var isFocused: Bool
    
    var body: some View {
        TextEditor(text: $text)
            .multilineTextAlignment(.leading)
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .padding(.all, 8)
            .frame(height: 150)
            .opacity(focusHelper.focus ? 1 : 0) // helps it dissapear well when animating
        
        // changing focus
            .onChange(of: isFocused) {
                focusHelper.editingText = isFocused
                focusHelper.editingColors = false
                focusHelper.adjustScroll()
            }
            .onChange(of: focusHelper.editingText) {
                isFocused = focusHelper.editingText
            }
        
        // switching entries
            .onChange(of: focusHelper.time, {
                if let time = focusHelper.time, let entry = storage.entries[time] {
                    text = entry.text
                    storage.currentEntry = entry
                    textEditTime = time
                    textEditDay = dateHelper.day
                } else {
                    text = ""
                    storage.currentEntry = Entry()
                    textEditTime = Int.max
                    textEditDay = ""
                }
            })
        
        // editing text
            .onChange(of: text, {
                if let time = focusHelper.time, let entry = storage.entries[time], !focusHelper.changing {
                    if textEditTime == time && textEditDay == dateHelper.day {
                        entry.text = text
                    } else {
                        text = entry.text
                        storage.currentEntry = entry
                        textEditTime = time
                        textEditDay = dateHelper.day
                    }
                } else if !focusHelper.changing {
                    text = ""
                }
            })
            .onChange(of: entry.text, {
                if let time = focusHelper.time, let entry = storage.entries[time], !focusHelper.changing {
                    text = entry.text
                } else if !focusHelper.changing {
                    text = ""
                }
            })
    }
}

