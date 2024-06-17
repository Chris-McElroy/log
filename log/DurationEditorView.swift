//
//  DurationEditorView.swift
//  log
//
//  Created by 4 on .2.9.
//

import SwiftUI

struct DurationEditorView: View {
    var time: Int { focusHelper.time ?? 100000 }
    var entry: Entry { storage.entries[time] ?? Entry() }
    @State var lastDragHeight: CGFloat? = nil
    @State var movingStart: Bool? = nil
    
    @ObservedObject var storage: Storage = Storage.main
    @ObservedObject var dateHelper: DateHelper = DateHelper.main
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    
    var body: some View {
        VStack(spacing: 0) {
            if focusHelper.time != nil && !focusHelper.editingText {
//                Spacer().frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900)*slotHeight)
                HStack(spacing: 0) {
                    Spacer().frame(width: 40)
                    VStack(spacing: 0) { // select/edit duration if entry is tapped/draged
                        Color.black.opacity(0.0001)
                            .gesture(changeEntryStartGesture)
                            .frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900 + entry.duration)*slotHeight)
                        Spacer().frame(height: 150)
                        Color.black.opacity(0.0001)
                            .gesture(changeEntryDurationGesture)
                    }
//                    .onTapGesture(count: 1) {
//                        withAnimation {
//                            focusHelper.focus.toggle()
//                            focusHelper.adjustScroll()
//                        }
//                    }
                }
//                .frame(height: CGFloat(entry.duration)*slotHeight)
//                Spacer()
            }
//            else if focusHelper.time != nil && focusHelper.editingText {
//                VStack(spacing: 0) {
//                    Color.black.opacity(0.0001)
//                        .frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900 + entry.duration)*slotHeight)
//                    Spacer().frame(height: 150)
//                    Color.black.opacity(0.0001)
//                }
//                .onTapGesture {
//                    focusHelper.editingText = false
//                }
//            }
        }
        .animation(nil, value: focusHelper.time) // so that it doesn't flow in between entries and mess up taps
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
                focusHelper.adjustScroll()
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
                focusHelper.adjustScroll()
            }
    }
    
    func scrollingUp(for drag: DragGesture.Value) -> Bool? {
        let height = drag.translation.height
        let travel = height - (lastDragHeight ?? 0)
        if abs(travel) > slotHeight {
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
#if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
    }
    
    func moveEntryStartLater(entry: Entry, time: Int) {
        let newTime = time + 900 // just below the entry start
        guard storage.entries[newTime] == nil else { return } // entry was marked nil
        storage.entries[newTime] = entry
        entry.duration -= 1
        focusHelper.changeStartTime(to: newTime)
        storage.entries[time] = Entry(blank: true)
#if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
    }
    
    func moveEntryEndEarlier(entry: Entry, time: Int) {
        let nextTime = time + entry.duration*900 - 900 // end of the entry
        guard storage.entries[nextTime] == nil else { return } // entry was marked nil
        entry.duration -= 1
//        focusHelper.adjustScroll()
        storage.entries[nextTime] = Entry(blank: true)
#if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
    }
    
    func moveEntryEndLater(entry: Entry, time: Int) {
        let nextTime = time + entry.duration*900 // just below the entry end
        guard storage.entries[nextTime]?.isEmpty() == true else { return } // next entry is blank
        entry.duration += 1
//        focusHelper.adjustScroll()
        storage.entries[nextTime] = nil
#if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
    }
}

