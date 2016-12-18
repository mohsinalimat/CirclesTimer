import Foundation
import SwiftCharts

struct ChartPage {
    
    var productivityLinePoints = [ChartPoint]()
    var previousUnitLinePoints = [ChartPoint]()
    var averagePreviousUnitLinePoints = [ChartPoint]()
    var averagePreviousIntervalLinePoints = [ChartPoint]()
    var xValues = [ChartAxisValue]()
    let xModel: ChartAxisModel
    
    init(_ pomodoroDaysStatistics: [PomodoroDayStatistics]) {
        let yLabelSettings = ChartLabelSettings()
        let xLabelSettings = ChartLabelSettings(font: ChartConstants.monospaceFont, fontColor: ChartConstants.mainColor, rotation: -60, rotationKeep: .bottom, shiftXOnRotation: false)
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.setLocalizedDateFormatFromTemplate(ChartConstants.formatterTemplate)
        
        let showLabels = pomodoroDaysStatistics.count == 7
        var todayTruncated = false
        
        for (index, statistics) in pomodoroDaysStatistics.enumerated() {
            let i = index + 1
            let chartAxisValueX = ChartAxisValueDouble(i, labelSettings: xLabelSettings)
            
            if let productivity = statistics.day.hours {
                productivityLinePoints.append(ChartPoint(x: chartAxisValueX, y: ChartAxisValueDouble(productivity, labelSettings: yLabelSettings)))
            } else if !todayTruncated {
                if index > 0 {
                    productivityLinePoints.append(ChartPoint(x: ChartAxisValueDouble(index, labelSettings: xLabelSettings), y: ChartAxisValueDouble(0.0, labelSettings: yLabelSettings)))
                }
                todayTruncated = true
            }
            
            if let previousUnit = statistics.previousUnit {
                previousUnitLinePoints.append(ChartPoint(x: chartAxisValueX, y: ChartAxisValueDouble(previousUnit, labelSettings: yLabelSettings)))
            }
            
            if let averagePreviousUnit = statistics.averagePreviousUnit {
                averagePreviousUnitLinePoints.append(ChartPoint(x: chartAxisValueX, y: ChartAxisValueDouble(averagePreviousUnit, labelSettings: yLabelSettings)))
            }
            
            if let averagePreviousInterval = statistics.averagePreviousInterval {
                averagePreviousIntervalLinePoints.append(ChartPoint(x: chartAxisValueX, y: ChartAxisValueDouble(averagePreviousInterval, labelSettings: yLabelSettings)))
            }
            
            if showLabels || i % 3 == 1 {
                xValues.append(ChartAxisValueString(formatter.string(from: statistics.day.date), order: i, labelSettings: xLabelSettings))
            }
        }
        if pomodoroDaysStatistics.count == 29 || pomodoroDaysStatistics.count == 30 {
            let invisibleLabelSettings = ChartLabelSettings(fontColor: ChartConstants.noColor, rotation: -60, rotationKeep: .bottom, shiftXOnRotation: false)
            xValues.append(ChartAxisValueString("", order: pomodoroDaysStatistics.count, labelSettings: invisibleLabelSettings))
        }
        xModel = ChartAxisModel(axisValues: xValues, lineColor: ChartConstants.mainColor)
    }
}
