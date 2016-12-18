import UIKit

class ChartsViewController: UIViewController, ChartsSettingsValuesDelegate {
    
    @IBOutlet weak var timeUnitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var previousUnitSwitch: PomodoroSwicth!
    @IBOutlet weak var averagePreviousUnitSwitch: PomodoroSwicth!
    @IBOutlet weak var averagePreviousIntervalSwitch: PomodoroSwicth!
    @IBOutlet weak var previousUnitLabel: UILabel!
    @IBOutlet weak var averagePreviousUnitLabel: UILabel!
    @IBOutlet weak var averagePreviousIntervalLabel: UILabel!
    
    fileprivate var previousChartBounds = CGRect.zero
    fileprivate var chartGenerator: ChartGenerator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(moveChartBackward))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(moveChartForward))
        swipeDown.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(swipeDown)
        
        timeUnitSegmentedControl.setTitle(TimeUnit.week.title, forSegmentAt: 0)
        timeUnitSegmentedControl.setTitle(TimeUnit.month.title, forSegmentAt: 1)
        timeUnitSegmentedControl.selectedSegmentIndex = SettingsValues.chartTimeUnit
        let currentTimeUnit = TimeUnit(rawValue: timeUnitSegmentedControl.selectedSegmentIndex)!
        timeUnitSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 10)], for: UIControlState())
        
        previousUnitSwitch.customColor = ChartConstants.previousUnitColor
        previousUnitSwitch.isOn = SettingsValues.chartSwitch[0]
        averagePreviousUnitSwitch.customColor = ChartConstants.averagePreviousUnitColor
        averagePreviousUnitSwitch.isOn = SettingsValues.chartSwitch[1]
        averagePreviousIntervalSwitch.customColor = ChartConstants.averagePreviousIntervalColor
        averagePreviousIntervalSwitch.isOn = SettingsValues.chartSwitch[2]

        let visibility : [AverageUnit: Bool] = [
            .previousUnit: previousUnitSwitch.isOn,
            .averagePreviousUnit: averagePreviousUnitSwitch.isOn,
            .averagePreviousInterval: averagePreviousIntervalSwitch.isOn]
        chartGenerator = ChartGenerator(chartHolder: chartView, timeUnit: currentTimeUnit, visibility: visibility)
        
        updateLabels(currentTimeUnit)
        SettingsValues.chartsDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if chartView.bounds != previousChartBounds {
            previousChartBounds = chartView.bounds
            chartGenerator.createChart()
        }
    }
    
    @IBAction func moveChartBackward(_ sender: AnyObject) {
        chartGenerator.scrollPage(.backward)
    }
    
    @IBAction func moveChartForward(_ sender: AnyObject) {
        chartGenerator.scrollPage(.forward)
    }
    
    @IBAction func changeSwitchState(_ sender: AnyObject) {
        chartGenerator.setVisibilityState(sender.isOn, for: AverageUnit(rawValue: sender.tag)!)
        SettingsValues.chartSwitch[sender.tag] = sender.isOn
    }
    
    @IBAction func changeTimeUnit(_ sender: AnyObject) {
        let currentTimeUnit = TimeUnit(rawValue: sender.selectedSegmentIndex)!
        updateLabels(currentTimeUnit)
        chartGenerator.changeTimeUnit(to: currentTimeUnit)
        SettingsValues.chartTimeUnit = sender.selectedSegmentIndex
    }
    
    func chartSettingsUpdate() {
        let currentTimeUnit = TimeUnit(rawValue: timeUnitSegmentedControl.selectedSegmentIndex)!
        updateLabels(currentTimeUnit)
        chartGenerator.scrollPage(.none)
    }
    
    func updateLabels(_ currentTimeUnit: TimeUnit) {
        switch currentTimeUnit {
        case .week:
            previousUnitLabel.text = NSLocalizedString("charts.last-week", comment: "")
            averagePreviousUnitLabel.text = NSLocalizedString("charts.last-week-average", comment: "")
            averagePreviousIntervalLabel.text = String.localizedStringWithFormat(NSLocalizedString("average %d for week", comment: ""), SettingsValues.chartLastUnitsCount)
        case .month:
            previousUnitLabel.text = NSLocalizedString("charts.last-month", comment: "")
            averagePreviousUnitLabel.text = NSLocalizedString("charts.last-month-average", comment: "")
            averagePreviousIntervalLabel.text = String.localizedStringWithFormat(NSLocalizedString("average %d for month", comment: ""), SettingsValues.chartLastUnitsCount)
        }
    }
        
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
