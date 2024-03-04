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
//            .onChange(of: entry.text) {
                // hoping this helps with the sometimes-deleting bug, not sure if it's necessary
//                if let time = FocusHelper.main.time {
//                    Storage.main.entries[time]?.text = entry.text
//                }
//            }
    }
}

