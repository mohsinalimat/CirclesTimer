import UIKit

class PomodoroViewController: UIViewController, HorizontalPickerViewUpdateDelegate, PomodoroStateChangeDelegate
{
    
    @IBOutlet weak var seconds: UILabel!
    @IBOutlet weak var minutes: UILabel!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var pickerView: HorizontalPickerView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
   
    fileprivate var buttons: [UIButton]!
    fileprivate var previousBounds = CGRect.zero
    fileprivate let pomodoroState = PomodoroState.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttons = [pauseButton, startButton, stopButton]
        pickerView.delegate = self
        pomodoroState.pomodoroDelegate = self
        pomodoroState.initState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if view.bounds != previousBounds && progressView.circleWidth > 0 {
            previousBounds = view.bounds
            
            for button in buttons {
                button.layer.cornerRadius = button.bounds.width / 2
                button.layer.borderWidth = progressView.circleWidth
            }
        }
    }
  
    @IBAction func start(_ button: UIButton) {
        pomodoroState.startClick()
    }
    
    @IBAction func pause(_ button: UIButton) {
        pomodoroState.pauseClick()
    }
    
    @IBAction func stop(_ button: UIButton) {
        pomodoroState.stopClick()
    }

    func applicationEnterForeground() {
        pomodoroState.initState()
    }
    
    func applicationEnterBackground() {
        pomodoroState.saveState()
    }
    
    // MARK: - PomodoroStateChangeDelegate
    
    func activityStateChanged(newState: PomodoroActivityStates) {
        pickerView.changeState(newState)
        for button in buttons {
            button.layer.borderColor = newState.color.cgColor
        }
        progressView.circlesColor = newState.color
    }
    
    func timerStateChanged(newState: PomodoroTimerStates) {
        switch newState {
        case .started:
            pauseButton.layer.opacity = 1
            stopButton.layer.opacity = 1
            startButton.layer.opacity = 0
            pauseButton.setImage(UIImage(named: "Pause")!, for: UIControlState())
            progressView.start()
            pickerView.activated = false
        
        case .paused:
            pauseButton.layer.opacity = 1
            stopButton.layer.opacity = 1
            startButton.layer.opacity = 0
            pauseButton.setImage(UIImage(named: "Resume")!, for: UIControlState())
            progressView.pause()
            pickerView.activated = false
            
        case .stopped:
            pauseButton.layer.opacity = 0
            stopButton.layer.opacity = 0
            startButton.layer.opacity = 1
            pauseButton.setImage(UIImage(named: "Pause")!, for: UIControlState())
            progressView.stop()
            pickerView.activated = true
        }
    }
    
    func pomodoroProgressChanged(newProgress: ProgressData) {
        let minutesCount = newProgress.currentSeconds / 60
        let secondsCount = newProgress.currentSeconds % 60
        minutes.text = String(format: "%02d", minutesCount)
        seconds.text = String(format: "%02d", secondsCount)
        
        if let totalSeconds = newProgress.totalSeconds {
            let percent = Double(newProgress.currentSeconds) / Double(totalSeconds)
            progressView.progress = percent
        }
    }
    
    // MARK: - HorizontalPickerViewUpdateDelegate
    
    func activityStateUpdate(_ selectedActivity: PomodoroActivityStates) {
        pomodoroState.stateUpdate(newState: selectedActivity)
    }
    
    // MARK: - Other
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
