//
//  EntryFocusView.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

let promptText = "tap to edit"

struct EntryFocusView: View {
    @ObservedObject var entry: Entry
    let time: Int
    let timeString: String
    init(entry: Entry, time: Int) {
        self.entry = entry
        self.time = time
        timeString = DateHelper.main.getTimeString(start: time, duration: entry.duration)
    }
    
    var body: some View {
        VStack(spacing: 0) {
//            Color.black.opacity(0.1)
//                .frame(height: 400)
//                .onTapGesture {
//                    ScrollHelper.main.focusTimeSlot = nil
//                    saveEntry()
//                }
            Spacer().frame(height: 400)
            VStack {
                Text(timeString)
                    .padding(.vertical, 15)
                TextEditor(text: $entry.text)
                    .multilineTextAlignment(.center)
                    .frame(height: 300)
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                        if entry.text == promptText {
                            entry.text = ""
                        }
                        // TODO show buttons above keyboard, move offsets appropriately
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                        // TODO hide buttons above keyboard, move offsets appropriately
                    }
            }
            .background(Color.black)
            .offset(x: 0, y: 40)
        }
        .onAppear {
            if entry.text == "" {
                entry.text = promptText
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            saveEntry()
        }
    }
    
    func saveEntry() {
        if entry.text == promptText {
            entry.text = ""
        }
        Storage.main.set(entry, at: time)
    }
}
