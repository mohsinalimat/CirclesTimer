import UIKit

enum TimeUnit: Int {
    case week = 0
    case month
    
    var title: String {
        get {
            switch self {
            case .week:
                return NSLocalizedString("charts.week", comment: "")
            case .month:
                return NSLocalizedString("charts.month", comment: "")
            }
        }
    }
}

enum AverageUnit: Int {
    case previousUnit = 0
    case averagePreviousUnit
    case averagePreviousInterval
}

enum ScrollingDirection {
    case forward
    case backward
    case start
    case none
}

class ChartConstants {
    
    static let mainColor = UIColor.white
    static let noColor = UIColor.clear
    static let areaColor = UIColor.white.withAlphaComponent(0.4)
    
    static let previousUnitColor = UIColor.yellow
    static let averagePreviousUnitColor = UIColor.orange
    static let averagePreviousIntervalColor = UIColor.red
    
    static let minimumDisplayedHours = 6.0
    
    static let monospaceFont = UIFont(name: "CourierNewPS-BoldMT", size: 12)!
    static let formatterTemplate = "MMddeee"
}
