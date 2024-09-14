//
//  logApp.swift
//  log
//
//  Created by 4 on 9/26/23.
//

import SwiftUI

var muteTaps: Bool = false

@main
struct logApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var lastActive: Date? = nil
#if os(iOS)
    let activeNotification = UIApplication.didBecomeActiveNotification
    let resignNotification = UIApplication.willResignActiveNotification
#elseif os(macOS)
    let activeNotification = NSApplication.willBecomeActiveNotification
    let resignNotification = NSApplication.willResignActiveNotification
#endif
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .font(Font.custom("Baskerville", size: fontSize))
                .background(Color.black, ignoresSafeAreaEdges: .all)

                .onReceive(NotificationCenter.default.publisher(for: activeNotification)) { _ in
                    Storage.main.mergeEntries()
//                    DateHelper.main.startTimeSlotTimer()
                    if (lastActive?.timeIntervalSinceNow ?? -100000) < -10800 {
                        DateHelper.main.updateDay()
                    }
                    if (lastActive?.timeIntervalSinceNow ?? -100000) > -300 { return }
                    if let currentTime = DateHelper.main.getCurrentSlot(offset: 0) {
                        FocusHelper.main.changeTime(to: currentTime, animate: false)
//                        FocusHelper.main.focus = true
//                        FocusHelper.main.adjustScroll(animate: false)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: resignNotification)) { _ in
                    lastActive = .now
                    Storage.main.mergeEntries()
//                    DateHelper.main.stopTimeSlotTimer()
                    Storage.main.stopUpdateTimer()
                }
        }.windowStyle(.hiddenTitleBar)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            setupWindow(window)
        }
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        muteTaps = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            muteTaps = false
        })
    }
    
    func setupWindow(_ window: NSWindow) {
        // very useful: https://github.com/lukakerr/NSWindowStyles
//        window.titleVisibility = .hidden
//        window.titlebarSeparatorStyle = .none
//        window.titlebarAppearsTransparent = true
//        window.styleMask.remove(.titled)
//        window.styleMask.insert(.nonactivatingPanel)
//        window.styleMask.insert(.fullSizeContentView)
        window.standardWindowButton(NSWindow.ButtonType.closeButton)?.isHidden = true
        window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
//        window.isOpaque = true
//        window.hasShadow = false
//        window.level = .floating
//        window.backgroundColor = NSColor.clear
//        window.isReleasedWhenClosed = false
//        window.isMovableByWindowBackground = true
//        window.collectionBehavior = .canJoinAllSpaces
//        window.titlebarSeparatorStyle = .none
//        window.ignoresMouseEvents = true // comment this out for clickability (vera's)
        window.delegate = self
    }
}
