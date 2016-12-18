import Foundation

struct ProgressData {
    let totalSeconds: Int?
    let currentSeconds: Int
}

protocol PomodoroStateChangeDelegate: class {
    func activityStateChanged(newState: PomodoroActivityStates)
    func timerStateChanged(newState: PomodoroTimerStates)
    func pomodoroProgressChanged(newProgress: ProgressData)
}

class PomodoroState: PomodoroTimerUpdateDelegate, PomodoroSettingsValuesDelegate {
    
    static let sharedInstance = PomodoroState()
    
    weak var pomodoroDelegate: PomodoroStateChangeDelegate?
    
    fileprivate let pomodoroTimer = PomodoroTimer.sharedInstance
    fileprivate var activityState = PomodoroActivityStates.work
    
    init() {
        pomodoroTimer.delegate = self
        SettingsValues.pomodoroDelegate = self
    }
    
    func startClick() {
        pomodoroTimer.start(time: activityState.seconds)
        pomodoroDelegate?.timerStateChanged(newState: pomodoroTimer.state)
    }
    
    func pauseClick() {
        if pomodoroTimer.state == .paused {
            pomodoroTimer.start()
        } else {
            pomodoroTimer.pause()
        }
        pomodoroDelegate?.timerStateChanged(newState: pomodoroTimer.state)
    }
    
    func stopClick() {
        pomodoroTimer.stop()
        pomodoroDelegate?.timerStateChanged(newState: pomodoroTimer.state)
        pomodoroDelegate?.pomodoroProgressChanged(newProgress: ProgressData(totalSeconds: activityState.seconds, currentSeconds: activityState.seconds))
    }
    
    func stateUpdate(newState: PomodoroActivityStates) {
        if newState != activityState {
            activityState = newState
            pomodoroDelegate?.activityStateChanged(newState: activityState)
            pomodoroDelegate?.pomodoroProgressChanged(newProgress: ProgressData(totalSeconds: nil, currentSeconds: activityState.seconds))
        }
    }
    
    fileprivate func switchState() {
        switch activityState {
        case .work:
            if SettingsValues.pomodoroCurrentBreakCount >= SettingsValues.pomodoroBreakPeriodicity {
                activityState = .longBreak
            } else {
                activityState = .shortBreak
            }
            PomodoroDataProvider.sharedInstance.addTime(seconds: activityState.seconds)
        case .shortBreak:
            SettingsValues.pomodoroCurrentBreakCount += 1
            activityState = .work
        case .longBreak:
            SettingsValues.pomodoroCurrentBreakCount = 0
            activityState = .work
        }
        pomodoroTimer.seconds = activityState.seconds
    }
    
    // MARK: - PomodoroTimerUpdateDelegate
    
    func timerUpdate() {
        pomodoroDelegate?.pomodoroProgressChanged(newProgress: ProgressData(totalSeconds: activityState.seconds, currentSeconds: pomodoroTimer.seconds))
    }
    
    func timerFinished() {
        PomodoroScheduler.sharedInstance.createNotification(for: activityState, atTime: Date(timeIntervalSinceNow: 0.5))

        switchState()
        
        if SettingsValues.pomodoroAutomaticallyChangeState {
            pomodoroTimer.start()
        }
        
        pomodoroDelegate?.activityStateChanged(newState: activityState)
        pomodoroDelegate?.timerStateChanged(newState: pomodoroTimer.state)
        pomodoroDelegate?.pomodoroProgressChanged(newProgress: ProgressData(totalSeconds: activityState.seconds, currentSeconds: pomodoroTimer.seconds))
    }
    
    // MARK: - PomodoroSettingsValuesDelegate
    
    func pomodoroTimeUpdate(_ forActivity: PomodoroActivityStates) {
        if pomodoroTimer.state == .stopped && forActivity == activityState {
            pomodoroDelegate?.pomodoroProgressChanged(newProgress: ProgressData(totalSeconds: nil, currentSeconds: activityState.seconds))
        }
    }
    
    // MARK: - Restoring
    
    func saveState() {
        let calendar = Calendar.current
        SettingsValues.pomodoroRestoringTimerState = pomodoroTimer.state
        SettingsValues.pomodoroRestoringActivityState = activityState
        
        switch pomodoroTimer.state {
        case .started:
            let notificationDate = calendar.date(byAdding: .second, value: pomodoroTimer.seconds, to: Date())!
            SettingsValues.pomodoroRestoringDate = notificationDate
            PomodoroScheduler.sharedInstance.scheduleNotifications(for: activityState, atTime: notificationDate, repeated: SettingsValues.pomodoroAutomaticallyChangeState)
            fallthrough
        case .paused:
            SettingsValues.pomodoroRestoringSeconds = pomodoroTimer.seconds
        case .stopped: break
        }
    }
    
    func initState() {
        let timerState = SettingsValues.pomodoroRestoringTimerState
        activityState = SettingsValues.pomodoroRestoringActivityState
        
        switch timerState {
        case .stopped:
            pomodoroTimer.seconds = activityState.seconds
        case .paused:
            pomodoroTimer.seconds = SettingsValues.pomodoroRestoringSeconds
            pomodoroTimer.pause()
        case .started:
            let notificationDate = SettingsValues.pomodoroRestoringDate
            let differenceInSeconds = Int(notificationDate.timeIntervalSince1970 - NSDate().timeIntervalSince1970)
            if differenceInSeconds <= activityState.seconds {
                if differenceInSeconds > 0 {
                    pomodoroTimer.start(time: differenceInSeconds)
                } else {
                    if SettingsValues.pomodoroAutomaticallyChangeState {
                        let restoredState = PomodoroScheduler.sharedInstance.restoreActivityState(for: activityState, atTime: SettingsValues.pomodoroRestoringDate)
                        activityState = restoredState.activity
                        if restoredState.isRunning {
                            pomodoroTimer.start(time: restoredState.seconds)
                        } else {
                            pomodoroTimer.stop()
                            pomodoroTimer.seconds = activityState.seconds
                        }
                    } else {
                        pomodoroTimer.stop()
                        switchState()
                    }
                }
            } else {
                pomodoroTimer.stop()
                pomodoroTimer.seconds = activityState.seconds
            }
        }
        
        pomodoroDelegate?.activityStateChanged(newState: activityState)
        pomodoroDelegate?.timerStateChanged(newState: pomodoroTimer.state)
        pomodoroDelegate?.pomodoroProgressChanged(newProgress: ProgressData(totalSeconds: activityState.seconds, currentSeconds: pomodoroTimer.seconds))
    }
}
