import Foundation

struct PomodoroDay {
    
    let date: Date
    let hours: Double?
    
    init(date: TimeInterval, seconds: Double?) {
        self.date = Date(timeIntervalSinceReferenceDate: date)
        if let time = seconds {
            self.hours = time / 3600
        } else {
            self.hours = seconds
        }
    }
    
    init(date: Date, seconds: Double?) {
        self.date = date
        if let time = seconds {
            self.hours = time / 3600
        } else {
            self.hours = nil
        }
    }
}

struct PomodoroDayStatistics {
    
    let day: PomodoroDay
    var previousUnit: Double?
    var averagePreviousUnit: Double?
    var averagePreviousInterval: Double?
    
    init(day: PomodoroDay, previousUnit: Double? = nil, averagePreviousUnit: Double? = nil, averagePreviousInterval: Double? = nil) {
        self.day = day
        self.previousUnit = previousUnit
        self.averagePreviousUnit = averagePreviousUnit
        self.averagePreviousInterval = averagePreviousInterval
    }
}
