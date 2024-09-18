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
    
    @ObservedObject var storage: Storage = Storage.main
    @ObservedObject var dateHelper: DateHelper = DateHelper.main
    @ObservedObject var focusHelper: FocusHelper = FocusHelper.main
    
    var body: some View {
        VStack(spacing: 0) {
            if focusHelper.time != nil {
                //                Spacer().frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900)*slotHeight)
                HStack(spacing: 0) {
                    Spacer().frame(width: 40)
                    VStack(spacing: 0) { // select/edit duration if entry is tapped/draged
                        Color.black.opacity(0.0001)
                            .gesture(changeEntryStartGesture)
                            .gesture(tappedTopArea)
                            .frame(height: CGFloat((time - (dateHelper.times.first ?? 0))/900 + entry.duration)*slotHeight)
                        Spacer().frame(height: 150)
                        Color.black.opacity(0.0001)
                            .gesture(changeEntryEndGesture)
                            .gesture(tappedBottomArea)
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
    
    var tappedTopArea: some Gesture {
        SpatialTapGesture(count: 1)
            .onEnded { value in
                if muteTaps {
                    muteTaps = false
                    return
                }
                if !NSApplication.shared.isActive { return }
                var timePoint = (Int(value.location.y/slotHeight))*900 + (dateHelper.times.first ?? 0)
                while storage.entries[timePoint] == nil {
                    timePoint -= 900
                    if timePoint < (dateHelper.times.first ?? -1000000) {
                        return // if we somehow missed it, return
                    }
                }
                focusHelper.changeTime(to: timePoint, animate: true)
            }
    }
    
    var tappedBottomArea: some Gesture {
        SpatialTapGesture(count: 1)
            .onEnded { value in
                if muteTaps {
                    muteTaps = false
                    return
                }
                if !NSApplication.shared.isActive { return }
                var timePoint = (Int(value.location.y/slotHeight))*900 + time + entry.duration*900
                while storage.entries[timePoint] == nil {
                    timePoint -= 900
                    if timePoint <= time {
                        return // if we somehow missed it, return
                    }
                }
                focusHelper.changeTime(to: timePoint, animate: true)
            }
    }
    
    var changeEntryStartGesture: some Gesture {
        DragGesture()
            .onChanged { drag in
                guard let scrollingUp = scrollingUp(for: drag) else { return }
                DurationEditor.main.moveStart(up: scrollingUp)
            }
            .onEnded { _ in
                lastDragHeight = nil
                focusHelper.adjustScroll()
            }
    }
    
    var changeEntryEndGesture: some Gesture {
        DragGesture()
            .onChanged { drag in
                guard let scrollingUp = scrollingUp(for: drag) else { return }
                DurationEditor.main.moveEnd(up: scrollingUp)
            }
            .onEnded { _ in
                lastDragHeight = nil
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
}

class DurationEditor {
    static let main = DurationEditor()
    
    private var shouldMoveStart: Bool? = nil // TODO change this to a time like "last move" and then make a func that checks if it was recent enough
    private var lastStartMove: Date = .distantPast
    private var lastEndMove: Date = .distantPast
    
    func moveStart(up: Bool) {
        guard let time = FocusHelper.main.time else { return }
        guard let entry = Storage.main.entries[time] else { return }
        if lastStartMove.timeIntervalSinceNow < -2.0 { shouldMoveStart = nil }
        lastStartMove = .now
        lastEndMove = .distantPast
        shouldMoveStart = (shouldMoveStart ?? true) ? entry.duration > 1 || up : entry.duration == 1 && up
        if shouldMoveStart == true {
            if up {
                moveStartEarlier(entry: entry, time: time)
            } else {
                moveStartLater(entry: entry, time: time)
            }
        } else {
            if up {
                moveEndEarlier(entry: entry, time: time)
            } else {
                moveEndLater(entry: entry, time: time)
            }
        }
    }
    
    func moveEnd(up: Bool) {
        guard let time = FocusHelper.main.time else { return }
        guard let entry = Storage.main.entries[time] else { return }
        if lastEndMove.timeIntervalSinceNow < -2.0 { shouldMoveStart = nil }
        lastEndMove = .now
        lastStartMove = .distantPast
        shouldMoveStart = (shouldMoveStart ?? false) ? entry.duration > 1 || up : entry.duration == 1 && up
        if shouldMoveStart == true {
            if up {
                moveStartEarlier(entry: entry, time: time)
            } else {
                moveStartLater(entry: entry, time: time)
            }
        } else {
            if up {
                moveEndEarlier(entry: entry, time: time)
            } else {
                moveEndLater(entry: entry, time: time)
            }
        }
    }
    
    func moveStartEarlier(entry: Entry, time: Int) {
        let newTime = time - 900 // just above the entry start
        guard Storage.main.entries[newTime]?.isEmpty() == true else { return } // next entry is blank
        Storage.main.entries[newTime] = entry
        entry.duration += 1
        FocusHelper.main.changeStartTime(to: newTime)
        Storage.main.entries[time] = nil
    #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    #endif
    }

    func moveStartLater(entry: Entry, time: Int) {
        let newTime = time + 900 // just below the entry start
        guard Storage.main.entries[newTime] == nil else { return } // entry was marked nil
        Storage.main.entries[newTime] = entry
        entry.duration -= 1
        FocusHelper.main.changeStartTime(to: newTime)
        Storage.main.entries[time] = Entry(blank: true)
    #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    #endif
    }

    func moveEndEarlier(entry: Entry, time: Int) {
        guard entry.duration > 1 else { moveStartEarlier(entry: entry, time: time); return } // TODO why the fuck is this here and not elsewhere??
        let nextTime = time + entry.duration*900 - 900 // end of the entry
        guard Storage.main.entries[nextTime] == nil else { return } // entry was marked nil
        entry.duration -= 1
    //        focusHelper.adjustScroll()
        Storage.main.entries[nextTime] = Entry(blank: true)
    #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    #endif
    }

    func moveEndLater(entry: Entry, time: Int) {
        let nextTime = time + entry.duration*900 // just below the entry end
        guard Storage.main.entries[nextTime]?.isEmpty() == true else { return } // next entry is blank
        entry.duration += 1
    //        focusHelper.adjustScroll()
        Storage.main.entries[nextTime] = nil
    #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    #endif
    }
}

