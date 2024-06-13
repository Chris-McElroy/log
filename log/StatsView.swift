//
//  StatsView.swift
//  log
//
//  Created by 4 on '24.6.13.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var storage = Storage.main
    @State var timeList: [Int: (Double, Double)] = [:]
    
    var body: some View {
        VStack(spacing: 20) {
            if let overallTimes = timeList[-1], overallTimes.0 != 0 {
                Spacer().frame(height: 30)
                timeLine(i: nil, times: overallTimes)
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 2)
                ForEach(0..<16) { i in
                    if let times = timeList[i] {
                        timeLine(i: i, times: times)
                    }
                }
                Spacer()
            } else {
                Spacer()
            }
        }
        .onChange(of: storage.entries, {
            recalculateStats()
        })
    }
    
    func recalculateStats() {
        var proportionalTotal: Double = 0
        var totalTotal: Double = 0
        
        for i in (0..<16) {
            let c = Categories.displayOrder[i]
            var totalTime: Double = 0
            var proportionalTime: Double = 0
            for entry in Storage.main.entries.values {
                if entry.colors & (1 << c) == 0 { continue }
                totalTime += Double(entry.duration)/4
                proportionalTime += Double(entry.duration)/Double(entry.colors.nonzeroBitCount)/4
            }
            
            proportionalTotal += proportionalTime
            totalTotal += totalTime
            timeList[i] = (totalTime == 0 ? nil : (proportionalTime, totalTime))
        }
        timeList[-1] = (proportionalTotal, totalTotal)
    }
    
    func timeLine(i: Int?, times: (Double, Double)) -> (some View)? {
        var color = Color.black
        if let i {
            color = Categories.colors[Categories.displayOrder[i]]
        }
        
        return HStack {
            Text("\(times.0, specifier: "%.2f")")
                .font(Font.custom("Baskerville", size: 22.0))
            Spacer()
            Text("x \(times.1/times.0, specifier: "%.2f")") // hair space
                .font(Font.custom("Baskerville", size: 18.0))
            Spacer()
            Text("\(times.1, specifier: "%.2f")")
                .font(Font.custom("Baskerville", size: 22.0))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .background {
            Rectangle().foregroundStyle(color).frame(height: 50)
        }
        .frame(width: 250)
    }
}
