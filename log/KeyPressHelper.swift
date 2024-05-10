//
//  KeyPressHelper.swift
//  log
//
//  Created by 4 on 27.2.29.
//

import SwiftUI

#if os(macOS)
// based off https://stackoverflow.com/a/61155272/8222178
struct KeyPressHelper: NSViewRepresentable {
    let view: KeyView = KeyView()
    
    static var reattach: () -> Void = {}
    
    class KeyView: NSView {
        let focusHelper = FocusHelper.main
        let dateHelper = DateHelper.main
        let storage = Storage.main
        
        override var acceptsFirstResponder: Bool { true }
        
        override func keyDown(with event: NSEvent) {
            guard event.modifierFlags.isDisjoint(with: [.control, .shift]) else { return }
            if event.modifierFlags.contains(.command) {
                if event.characters == "e" {
                    focusIn()
                } else if event.characters == "´" {
                    focusOut()
                } else if event.characters == "d" {
                    nextEntry()
                } else if event.characters == "∂" {
                    prevEntry()
                }
            } else {
                if !focusHelper.editingText {
                    if event.specialKey == .downArrow || event.specialKey == .tab {
                        nextEntry()
                    } else if event.specialKey == .upArrow || event.specialKey == .backTab {
                        prevEntry()
                    } else if event.specialKey == .rightArrow {
                        dateHelper.changeDay(forward: true)
                    } else if event.specialKey == .leftArrow {
                        dateHelper.changeDay(forward: false)
                    } else if let num = Categories.keyOrder.firstIndex(of: event.characters?.first ?? "k") {
                        guard let time = focusHelper.time, let entry = Storage.main.entries[time] else { return }
                        entry.colors ^= 1 << num
                    }
                }
            }
        }
        
        func focusIn() {
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
                focusHelper.changeTime(to: dateHelper.getCurrentSlot(offset: 0))
            }
        }
        
        func focusOut() {
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
        
        func nextEntry() {
            if var time = focusHelper.time {
                repeat {
                    time += 900
                    guard dateHelper.times.contains(time) else { return }
                } while storage.entries[time] == nil
                focusHelper.changeTime(to: time, animate: true)
            }
        }
        
        func prevEntry() {
            if var time = focusHelper.time {
                repeat {
                    time -= 900
                    guard dateHelper.times.contains(time) else { return }
                } while storage.entries[time] == nil
                focusHelper.changeTime(to: time, animate: true)
            }
        }
    }

    func makeNSView(context: Context) -> NSView {
        reattachKeyPressWindow()
        KeyPressHelper.reattach = reattachKeyPressWindow
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
    
    func reattachKeyPressWindow() {
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
    }
}
#endif
