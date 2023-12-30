//
//  ScrollHelper.swift
//  log
//
//  Created by 4 on 2023.12.29.
//

import SwiftUI

class ScrollHelper: ObservableObject {
    static let main: ScrollHelper = ScrollHelper()
    
    @Published var mainViewScrollProxy: ScrollViewProxy? = nil
    @Published var focusTimeSlot: Int? = nil
}
