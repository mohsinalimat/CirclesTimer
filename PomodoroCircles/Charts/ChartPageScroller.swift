import UIKit
import SwiftCharts

class ChartPageScroller {
    
    fileprivate let pomodoroDataProvider = PomodoroDataProvider.sharedInstance
    
    var chartPage: ChartPage
    var positionFromNow = 0
    var currentTimeUnit: TimeUnit {
        didSet {
            if oldValue != currentTimeUnit {
                scrollPage(.start)
            }
        }
    }
    
    init(timeUnit: TimeUnit) {
        currentTimeUnit = timeUnit
        let days = currentTimeUnit == .week ? pomodoroDataProvider.getWeekStatistics(positionFromNow) : pomodoroDataProvider.getMonthStatistics(positionFromNow)
        chartPage = ChartPage(days)
    }
    
    func createYAxisModel() -> ChartAxisModel {
        let visibleLabelSettings = ChartLabelSettings(font: ChartConstants.monospaceFont, fontColor: ChartConstants.mainColor)
        let invisibleLabelSettings = ChartLabelSettings(font: ChartConstants.monospaceFont, fontColor: ChartConstants.noColor)
        let yValues = stride(from: 0, through: pomodoroDataProvider.maximumHourValue, by: 0.5).map ({ (value: Double) -> ChartAxisValue in
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                let intValue = Int(value)
                return ChartAxisValueString("\(intValue) \(NSLocalizedString("charts.hour", comment: ""))", order: intValue, labelSettings: visibleLabelSettings)
            } else {
                return ChartAxisValueDouble(value, labelSettings: invisibleLabelSettings)
            }
        })
        return ChartAxisModel(axisValues: yValues, lineColor: ChartConstants.mainColor)
    }
    
    func scrollPage(_ direction: ScrollingDirection) {
        switch direction {
        case .forward:
            positionFromNow += 1
        case .backward:
            positionFromNow -= 1
        case .start:
            positionFromNow = 0
        case .none:
            break
        }
        changePage()
    }
    
    fileprivate func changePage() {
        let days = currentTimeUnit == .week ? pomodoroDataProvider.getWeekStatistics(positionFromNow) : pomodoroDataProvider.getMonthStatistics(positionFromNow)
        chartPage = ChartPage(days)
    }
}
