//
//  LineChartDemoView.swift
//  ShipApp
//
//  Created by wangjie on 2025/10/31.
//  Copyright © 2025 zhang. All rights reserved.
//

import SwiftUI
import Charts

struct LineChartPoint: Identifiable, Equatable {
    let id = UUID()
    let x: String
    let y: Double
}


struct LineChartDemoView: View {
    
    // 数据源
    private let data: [LineChartPoint]
    private let yFormatter: (Double) -> String
    private let xFormatter: (String) -> String
    
    @State private var selectedX: String? = nil
    
    private var selectedPoint: LineChartPoint? {
        guard let selectedX = selectedX else { return nil }
        return data.first { $0.x == selectedX }
    }

    // MARK: - Init
    init(data: [LineChartPoint],
         valueFormatter: @escaping (Double) -> String = { "\($0)" },
         xFormatter: @escaping (String) -> String = { x in x }) {
        self.data = data
        self.yFormatter = valueFormatter
        self.xFormatter = xFormatter
    }


    // MARK: - Body
    var body: some View {
        Chart {
            // 折线
            ForEach(data) { point in
                LineMark(
                    x: .value("时间", point.x),
                    y: .value("速度", point.y)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .interpolationMethod(.linear)// 折线（默认）
            
            if let selectedPoint = selectedPoint {
                RuleMark(x: .value("x", selectedPoint.x))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                
                PointMark(
                    x: .value("x", selectedPoint.x),
                    y: .value("y", selectedPoint.y)
                )
                .annotation(position: .top) {
                    VStack(alignment: .leading, spacing: 4){
                        Text(xFormatter(selectedPoint.x))
                        Text(yFormatter(selectedPoint.y))
                    }
                    .font(.system(size: 12, weight: .regular))
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.gray.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXSelection(value: $selectedX)
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisValueLabel()
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        // minimumDistance 表示手势识别前需要移动的最小距离（以 points 为单位）。
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // 将手势坐标转换到绘图区坐标系
                                let origin = geometry[proxy.plotFrame!].origin
                                let location = CGPoint(
                                    x: value.location.x - origin.x,
                                    y: value.location.y - origin.y
                                )
                                // 从位置反推出 x/y 的数据值（这里是 x:String, y:Double）
                                if let (time, _) = proxy.value(at: location, as: (String, Double).self) {
                                    // 仅在命中分类轴的有效刻度时更新
                                    selectedX = time
                                }
                            }
                            .onEnded { _ in
                                // 手势结束后可选择保留选中，或者清空
                                // 如果希望结束后清除竖线，取消注释下一行
//                                selectedX = nil
                            }
                    )
            }
        }
        .frame(height: 260)
        .padding()
    }

}


#Preview {
    ContentView()
    Spacer()
}

// Conformance to ExpressibleByArrayLiteral and ExpressibleByDictionaryLiteral
extension LineChartPoint: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    init(arrayLiteral elements: Any...) {
        guard elements.count >= 2 else {
            fatalError("LineChartPoint init failed: need [x, y]")
        }
        self.x = String(describing: elements[0])
        if let y = elements[1] as? Double {
            self.y = y
        } else if let s = elements[1] as? String, let d = Double(s) {
            self.y = d
        } else if let i = elements[1] as? Int {
            self.y = Double(i)
        } else {
            fatalError("LineChartPoint init failed: invalid y type")
        }
    }

    init(dictionaryLiteral elements: (String, Any)...) {
        var xValue: String?
        var yValue: Double?

        for (key, value) in elements {
            switch key {
            case "x":
                xValue = String(describing: value)
            case "y":
                if let d = value as? Double {
                    yValue = d
                } else if let s = value as? String, let d = Double(s) {
                    yValue = d
                } else if let i = value as? Int {
                    yValue = Double(i)
                }
            default:
                continue
            }
        }

        guard let x = xValue, let y = yValue else {
            fatalError("LineChartPoint init failed: missing x or y in dictionary literal")
        }

        self.x = x
        self.y = y
    }
}
