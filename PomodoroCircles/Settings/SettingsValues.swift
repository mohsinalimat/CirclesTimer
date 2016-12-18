import Foundation

protocol PomodoroSettingsValuesDelegate: class {
    func pomodoroTimeUpdate(_ forActivity: PomodoroActivityStates)
}

protocol ChartsSettingsValuesDelegate: class {
    func chartSettingsUpdate()
}

class SettingsValues {
    
    static fileprivate let defaults = UserDefaults.standard
    static weak var pomodoroDelegate: PomodoroSettingsValuesDelegate?
    static weak var chartsDelegate: ChartsSettingsValuesDelegate?
    
    static func registerDefaults() {
        let settingsURL = Bundle.main.url(forResource: "DefaultSettings", withExtension: "plist")!
        let settingsDictionary = NSDictionary(contentsOf: settingsURL)!
        var settings : [String: AnyObject] = [:]
        for item in settingsDictionary.allKeys {
            settings[item as! String] = settingsDictionary.object(forKey: item) as AnyObject?
        }
        defaults.register(defaults: settings)
    }
    
    static func deleteSettings() {
        let keys = [
            pomodoroWorkKey,
            pomodoroShortBreakKey,
            pomodoroLongBreakKey,
            pomodoroBreakPeriodicityKey,
            pomodoroAutomaticallyChangeStateKey,
            
            notificationsWorkSoundKey,
            notificationsShortBreakSoundKey,
            notificationsLongBreakSoundKey,
            
            chartIncludeZeroDaysKey,
            chartLastUnitsCountKey,
            
            pomodoroCurrentDateKey,
            pomodoroCurrentBreakCountKey
        ]
        
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        
        pomodoroDelegate?.pomodoroTimeUpdate(.work)
        pomodoroDelegate?.pomodoroTimeUpdate(.shortBreak)
        pomodoroDelegate?.pomodoroTimeUpdate(.longBreak)
        chartsDelegate?.chartSettingsUpdate()
    }
    
    // MARK: - Pomodoro
    
    static fileprivate let pomodoroWorkKey = "PomodoroWork"
    static let pomodoroWorkName = NSLocalizedString("main.work", comment: "")
    static var pomodoroWork : Int {
        get {
            return defaults.integer(forKey: pomodoroWorkKey)
        }
        
        set {
            defaults.set(newValue, forKey: pomodoroWorkKey)
            defaults.synchronize()
            pomodoroDelegate?.pomodoroTimeUpdate(.work)
        }
    }
    
    static fileprivate let pomodoroShortBreakKey = "PomodoroShortBreak"
    static let pomodoroShortBreakName = NSLocalizedString("main.short-break", comment: "")
    static var pomodoroShortBreak : Int {
        get {
            return defaults.integer(forKey: pomodoroShortBreakKey)
        }
        
        set {
            defaults.set(newValue, forKey: pomodoroShortBreakKey)
            defaults.synchronize()
            pomodoroDelegate?.pomodoroTimeUpdate(.shortBreak)
        }
    }
    
    static fileprivate let pomodoroLongBreakKey = "PomodoroLongBreak"
    static let pomodoroLongBreakName = NSLocalizedString("main.long-break", comment: "")
    static var pomodoroLongBreak : Int {
        get {
            return defaults.integer(forKey: pomodoroLongBreakKey)
        }
        
        set {
            defaults.set(newValue, forKey: pomodoroLongBreakKey)
            defaults.synchronize()
            pomodoroDelegate?.pomodoroTimeUpdate(.longBreak)
        }
    }
    
    static fileprivate let pomodoroBreakPeriodicityKey = "PomodoroBreakPeriodicity"
    static let pomodoroBreakPeriodicityName = NSLocalizedString("settings.timer.break-periodicity", comment: "")
    static var pomodoroBreakPeriodicity : Int {
        get {
            return defaults.integer(forKey: pomodoroBreakPeriodicityKey)
        }
        
        set {
            defaults.set(newValue, forKey: pomodoroBreakPeriodicityKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let pomodoroAutomaticallyChangeStateKey = "PomodoroAutomaticallyChangeState"
    static let pomodoroAutomaticallyChangeStateName = NSLocalizedString("settings.timer.automatically-change-state", comment: "")
    static var pomodoroAutomaticallyChangeState : Bool {
        get {
            return defaults.bool(forKey: pomodoroAutomaticallyChangeStateKey)
        }
        
        set {
            defaults.set(newValue, forKey: pomodoroAutomaticallyChangeStateKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let pomodoroCurrentDateKey = "PomodoroCurrentDate"
    static fileprivate let pomodoroCurrentBreakCountKey = "PomodoroCurrentBreakCount"
    static var pomodoroCurrentBreakCount : Int {
        get {
            let calendar = Calendar.current
            let date = defaults.object(forKey: pomodoroCurrentDateKey)
            if let day = date as? Date {
                if calendar.isDateInToday(day) {
                    return defaults.integer(forKey: pomodoroCurrentBreakCountKey)
                }
            }
            defaults.set(0, forKey: pomodoroCurrentBreakCountKey)
            defaults.set(Date(), forKey: pomodoroCurrentDateKey)
            defaults.synchronize()
            return 0
        }
        
        set {
            let calendar = Calendar.current
            let date = defaults.object(forKey: pomodoroCurrentDateKey)
            if let day = date as? Date {
                if calendar.isDateInToday(day) {
                    defaults.set(newValue, forKey: pomodoroCurrentBreakCountKey)
                    defaults.synchronize()
                    return
                }
            }
            defaults.set(0, forKey: pomodoroCurrentBreakCountKey)
            defaults.set(Date(), forKey: pomodoroCurrentDateKey)
            defaults.synchronize()
        }
    }
    
    static func getPomodoroCurrentBreakCount(for date: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = defaults.object(forKey: pomodoroCurrentDateKey)
        if let day = currentDate as? Date {
            if calendar.isDate(day, inSameDayAs: date) {
                return defaults.integer(forKey: pomodoroCurrentBreakCountKey)
            }
        }
        return 0
    }
    
    static func setPomodoroCurrentBreakCount(count: Int, for date: Date){
        defaults.set(count, forKey: pomodoroCurrentBreakCountKey)
        defaults.set(date, forKey: pomodoroCurrentDateKey)
        defaults.synchronize()
    }
    
    static fileprivate let pomodoroRestoringActivityStateKey = "PomodoroRestoringActivityState"
    static var pomodoroRestoringActivityState : PomodoroActivityStates {
        get {
            let stateValue = defaults.integer(forKey: pomodoroRestoringActivityStateKey)
            return PomodoroActivityStates(rawValue: stateValue)!
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: pomodoroRestoringActivityStateKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let pomodoroRestoringTimerStateKey = "PomodoroRestoringTimerState"
    static var pomodoroRestoringTimerState : PomodoroTimerStates {
        get {
            let stateValue = defaults.integer(forKey: pomodoroRestoringTimerStateKey)
            return PomodoroTimerStates(rawValue: stateValue)!
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: pomodoroRestoringTimerStateKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let pomodoroRestoringDateKey = "PomodoroRestoringDate"
    static var pomodoroRestoringDate : Date {
        get {
            let dateValue = defaults.double(forKey: pomodoroRestoringDateKey)
            return Date(timeIntervalSince1970: dateValue)
        }
        
        set {
            defaults.set(newValue.timeIntervalSince1970, forKey: pomodoroRestoringDateKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let pomodoroRestoringSecondsKey = "PomodoroRestoringSeconds"
    static var pomodoroRestoringSeconds : Int {
        get {
            return defaults.integer(forKey: pomodoroRestoringSecondsKey)
        }
        
        set {
            defaults.set(newValue, forKey: pomodoroRestoringSecondsKey)
            defaults.synchronize()
        }
    }
    
    // MARK: - Notifications
    
    static fileprivate let notificationsWorkSoundKey = "NotificationsWorkSound"
    static let notificationsWorkSoundName = NSLocalizedString("settings.notifications.work-sound", comment: "")
    static var notificationsWorkSound : String {
        get {
            return defaults.string(forKey: notificationsWorkSoundKey)!
        }
        
        set {
            defaults.set(newValue, forKey: notificationsWorkSoundKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let notificationsShortBreakSoundKey = "NotificationsShortBreakSound"
    static let notificationsShortBreakSoundName = NSLocalizedString("settings.notifications.short-break-sound", comment: "")
    static var notificationsShortBreakSound : String {
        get {
            return defaults.string(forKey: notificationsShortBreakSoundKey)!
        }
        
        set {
            defaults.set(newValue, forKey: notificationsShortBreakSoundKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let notificationsLongBreakSoundKey = "NotificationsLongBreakSound"
    static let notificationsLongBreakSoundName = NSLocalizedString("settings.notifications.long-break-sound", comment: "")
    static var notificationsLongBreakSound : String {
        get {
            return defaults.string(forKey: notificationsLongBreakSoundKey)!
        }
        
        set {
            defaults.set(newValue, forKey: notificationsLongBreakSoundKey)
            defaults.synchronize()
        }
    }
    
    // MARK: - Charts
    
    static fileprivate let chartIncludeZeroDaysKey = "ChartIncludeZeroDays"
    static let chartIncludeZeroDaysName = NSLocalizedString("settings.charts.include-zero-days", comment: "")
    static var chartIncludeZeroDays : Bool {
        get {
            return defaults.bool(forKey: chartIncludeZeroDaysKey)
        }
        
        set {
            defaults.set(newValue, forKey: chartIncludeZeroDaysKey)
            defaults.synchronize()
            chartsDelegate?.chartSettingsUpdate()
        }
    }
    
    static fileprivate let chartLastUnitsCountKey = "ChartLastUnitsCount"
    static let chartLastUnitsCountName = NSLocalizedString("settings.charts.last-units-count", comment: "")
    static var chartLastUnitsCount : Int {
        get {
            return defaults.integer(forKey: chartLastUnitsCountKey)
        }
        
        set {
            defaults.set(newValue, forKey: chartLastUnitsCountKey)
            defaults.synchronize()
            chartsDelegate?.chartSettingsUpdate()
        }
    }
    
    
    static fileprivate let chartTimeUnitKey = "ChartTimeUnit"
    static var chartTimeUnit : Int {
        get {
            return defaults.integer(forKey: chartTimeUnitKey)
        }
        
        set {
            defaults.set(newValue, forKey: chartTimeUnitKey)
            defaults.synchronize()
        }
    }
    
    static fileprivate let chartSwitchKey = "ChartSwitch"
    static var chartSwitch = ChartSwitch()
    struct ChartSwitch {
        subscript(index: Int) -> Bool {
            get {
                return defaults.bool(forKey: String(format: "%@%i", chartSwitchKey, index))
            }
            
            set {
                defaults.set(newValue, forKey: String(format: "%@%i", chartSwitchKey, index))
                defaults.synchronize()
            }
        }
    }
}
