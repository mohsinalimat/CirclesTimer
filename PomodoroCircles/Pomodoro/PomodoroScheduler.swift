import Foundation
import UserNotifications

class PomodoroScheduler {
    
    static let sharedInstance = PomodoroScheduler()
    
    fileprivate let scheduledNotificationTimeLimit = 1 * 24 * 60 * 60
    
    struct RestoredState {
        let activity: PomodoroActivityStates
        let seconds: Int
        let isRunning: Bool
    }
    
    fileprivate func getNotificationTitle(for activity: PomodoroActivityStates) -> String {
        switch activity {
        case .work:
            return NSLocalizedString("notifications.title.work", comment: "")
        case .shortBreak:
            return NSLocalizedString("notifications.title.short-break", comment: "")
        case .longBreak:
            return NSLocalizedString("notifications.title.long-break", comment: "")
        }
    }
    
    fileprivate func getNotificationBody(for activity: PomodoroActivityStates) -> String {
        if !SettingsValues.pomodoroAutomaticallyChangeState {
            return NSLocalizedString("notifications.body.not-auto", comment: "")
        }
        
        return activity == .work ? NSLocalizedString("notifications.body.auto-work", comment: "") : NSLocalizedString("notifications.body.auto-break", comment: "")
    }

    func createNotification(for activity: PomodoroActivityStates, atTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = getNotificationTitle(for: activity)
        content.body = getNotificationBody(for: activity)
        content.sound = UNNotificationSound(named: activity.sound + ".aiff")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: atTime.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: "\(atTime.timeIntervalSince1970)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func restoreActivityState(for activity: PomodoroActivityStates, atTime: Date) -> RestoredState {
        let calendar = Calendar.current
        var currentActivity = activity
        var notificationTime = atTime
        
        let now = Date().timeIntervalSince1970
        let isRunning = now < Double(scheduledNotificationTimeLimit) + notificationTime.timeIntervalSince1970
        let timeLimit = min(now, Double(scheduledNotificationTimeLimit) + notificationTime.timeIntervalSince1970)
        
        var currentBreakCount = SettingsValues.getPomodoroCurrentBreakCount(for: notificationTime)
        var newTime = notificationTime
        var seconds = 0
        
        while newTime.timeIntervalSince1970 <= timeLimit {
            if !calendar.isDate(newTime, inSameDayAs: notificationTime) {
                currentBreakCount = 0
            }
            notificationTime = newTime
            if currentActivity == .work {
                PomodoroDataProvider.sharedInstance.addTime(seconds: currentActivity.seconds, date: notificationTime)
            }
            calculateNext(activity: &currentActivity, breakCount: &currentBreakCount)
            newTime = calendar.date(byAdding: .second, value: currentActivity.seconds, to: notificationTime)!
        }
        
        if newTime.timeIntervalSince1970 > now {
            seconds = Int(newTime.timeIntervalSince1970 - now)
        }
        SettingsValues.setPomodoroCurrentBreakCount(count: currentBreakCount, for: notificationTime)
        
        return RestoredState(activity: currentActivity, seconds: seconds, isRunning: isRunning)
    }
    
    func scheduleNotifications(for activity: PomodoroActivityStates, atTime: Date, repeated: Bool) {
        if repeated {
            let calendar = Calendar.current
            var currentActivity = activity
            var notificationTime = atTime
            var currentBreakCount = SettingsValues.getPomodoroCurrentBreakCount(for: notificationTime)
            var timeLimit = scheduledNotificationTimeLimit
            
            while timeLimit >= 0 {
                createNotification(for: currentActivity, atTime: notificationTime)
                calculateNext(activity: &currentActivity, breakCount: &currentBreakCount)
                
                let newTime = calendar.date(byAdding: .second, value: currentActivity.seconds, to: notificationTime)!
                if !calendar.isDate(newTime, inSameDayAs: notificationTime) {
                    currentBreakCount = 0
                }
                notificationTime = newTime
                
                timeLimit -= currentActivity.seconds
            }
        } else {
            createNotification(for: activity, atTime: atTime)
        }
    }
    
    fileprivate func calculateNext(activity: inout PomodoroActivityStates, breakCount: inout Int) {
        switch activity {
        case .work:
            if breakCount >= SettingsValues.pomodoroBreakPeriodicity {
                activity = .longBreak
            } else {
                activity = .shortBreak
            }
        case .shortBreak:
            breakCount += 1
            activity = .work
        case .longBreak:
            breakCount = 0
            activity = .work
        }
    }
}
