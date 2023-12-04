//
//  SleepQualityChart.swift
//  SecureSnooze
//
//  Created by Alex Ely on 12/3/23.
//

import SwiftUI
import Charts
import Foundation

struct SleepQuality: Identifiable {
    let id = UUID()
    let date: Date
    let sleepQualityData: Double
}

struct SleepQualityChart: View {
    var data: [SleepQuality] = []
    
    var body: some View {
        Chart(data) { sleepQualityChart in
            LineMark(x: .value("Day", sleepQualityChart.date), y: .value("Sleep Quality", sleepQualityChart.sleepQualityData))
        } 
    }
}
