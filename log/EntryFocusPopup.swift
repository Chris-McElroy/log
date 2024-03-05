//
//  EntryFocusPopup.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

let promptText = "tap to edit"

struct EntryFocusView: View {
    let time: Int
    @State var text: String
    @ObservedObject var entry: Entry
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    @FocusState var isFocused: Bool
    
    init(time: Int, entry: Entry) {
        self.time = time
        self.entry = entry
        self.text = entry.text
    }
    
    var body: some View {
        TextEditor(text: $text)
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
//            .onAppear {
//                print("appearing", time)
//            }
            .onChange(of: focusHelper.editingText) {
                isFocused = focusHelper.editingText
            }
            .onChange(of: text) {
                if time == FocusHelper.main.time && !focusHelper.changing {
                    entry.text = text
                } else {
                    print("problem!", time)
                }
            }
            .onChange(of: entry.text) {
                if time == FocusHelper.main.time && !focusHelper.changing {
                    text = entry.text
                } else {
                    print("problem!", time)
                }
            }
    }
}

