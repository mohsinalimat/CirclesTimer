import Foundation

enum PomodoroTimerStates: Int {
    case stopped = 0
    case started
    case paused
}

protocol PomodoroTimerUpdateDelegate: class {
    func timerUpdate()
    func timerFinished()
}

class PomodoroTimer: NSObject {
    
    static let sharedInstance = PomodoroTimer()
    
    weak var delegate: PomodoroTimerUpdateDelegate?
    
    fileprivate var timer: Timer?
    var state = PomodoroTimerStates.stopped
    var seconds = 0
    
    func start(time: Int) {
        seconds = time
        start()
    }
    
    func start() {
        invalidateTimer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PomodoroTimer.update), userInfo: nil, repeats: true)
        state = .started
    }
    
    func update() {
        seconds -= 1
        if seconds > 0 {
            delegate?.timerUpdate()
        } else {
            stop()
            delegate?.timerFinished()
        }
    }
    
    func stop() {
        invalidateTimer()
        state = .stopped
        seconds = 0
    }
   
    func pause() {
        invalidateTimer()
        state = .paused
    }
    
    fileprivate func invalidateTimer() {
        if let currentTimer = timer {
            currentTimer.invalidate()
            timer = nil
        }
    }
}
