//
//  ContentView.swift
//  ChartsDemo
//
//  Created by wangjie on 2025/11/1.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            Section {
                let arr = [
                    LineChartPoint(x: "1730419200", y: 10),
                    LineChartPoint(x: "1730505600", y: 9),
                    LineChartPoint(x: "1730592000", y: 6.0),
                    LineChartPoint(x: "1730678400", y: 8.0),
                ]
                
                
                let arr1: [LineChartPoint] = [["1730419200", 10],
                                              LineChartPoint(x: "1730505600", y: 9),
                                              ["x": "1730592000", "y": 6.0]]
                
                
                LineChartDemoView(data: arr1) { y in
                    "航速度:\(y)kn"
                } xFormatter: { x in
                    if let ts = TimeInterval(x) {
                        let date = Date(timeIntervalSince1970: ts)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM-dd"
                        return formatter.string(from: date)
                    }
                    return ""
                }
            }
                        
        }
    }
}

#Preview {
    ContentView()
    Spacer()
}
