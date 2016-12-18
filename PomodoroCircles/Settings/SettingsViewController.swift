import UIKit

class SettingsViewController: UITableViewController {
    
    fileprivate let tableData: [[(type: SettingsCellTypes, title: String, index: Int)]] = [
        [
            (type: .slider, title: SettingsValues.pomodoroWorkName, index: 0),
            (type: .slider, title: SettingsValues.pomodoroShortBreakName, index: 1),
            (type: .slider, title: SettingsValues.pomodoroLongBreakName, index: 2),
            (type: .slider, title: SettingsValues.pomodoroBreakPeriodicityName, index: 3),
            (type: .switch, title: SettingsValues.pomodoroAutomaticallyChangeStateName, index: 0)
        ], [
            (type: .choice, title: SettingsValues.notificationsWorkSoundName, index: 0),
            (type: .choice, title: SettingsValues.notificationsShortBreakSoundName, index: 1),
            (type: .choice, title: SettingsValues.notificationsLongBreakSoundName, index: 2)
        ], [
            (type: .switch, title: SettingsValues.chartIncludeZeroDaysName, index: 1),
            (type: .slider, title: SettingsValues.chartLastUnitsCountName, index: 4)
        ], [
            (type: .simple, title: NSLocalizedString("settings.data.delete-statistics", comment: ""), index: 0),
            (type: .simple, title: NSLocalizedString("settings.data.remove-settings", comment: ""), index: 1)
        ]
    ]
    fileprivate let sectionTitles = [
        NSLocalizedString("settings.timer.header", comment: ""),
        NSLocalizedString("settings.notifications.header", comment: ""),
        NSLocalizedString("settings.charts.header", comment: ""),
        NSLocalizedString("settings.data.header", comment: "")
    ]
    
    fileprivate let slidersArray: [(saveValue: (Int) -> Void, getValue: () -> Int, ending: String, minimum: Float, maximum: Float)] = [
        (saveValue: { SettingsValues.pomodoroWork = $0 }, getValue: { return SettingsValues.pomodoroWork }, ending: NSLocalizedString("settings.timer.time", comment: ""), minimum: 10, maximum: 60),
        (saveValue: { SettingsValues.pomodoroShortBreak = $0 }, getValue: { return SettingsValues.pomodoroShortBreak }, ending: NSLocalizedString("settings.timer.time", comment: ""), minimum: 5, maximum: 60),
        (saveValue: { SettingsValues.pomodoroLongBreak = $0 }, getValue: { return SettingsValues.pomodoroLongBreak }, ending: NSLocalizedString("settings.timer.time", comment: ""), minimum: 5, maximum: 60),
        (saveValue: { SettingsValues.pomodoroBreakPeriodicity = $0 }, getValue: { return SettingsValues.pomodoroBreakPeriodicity }, ending: "", minimum: 1, maximum: 10),
        (saveValue: { SettingsValues.chartLastUnitsCount = $0 }, getValue: { return SettingsValues.chartLastUnitsCount }, ending: "", minimum: 2, maximum: 12)
    ]
    fileprivate let switchesArray: [(saveValue: (Bool) -> Void, getValue: () -> Bool)] = [
        (saveValue: { SettingsValues.pomodoroAutomaticallyChangeState = $0 }, getValue: { return SettingsValues.pomodoroAutomaticallyChangeState }),
        (saveValue: { SettingsValues.chartIncludeZeroDays = $0 }, getValue: { return SettingsValues.chartIncludeZeroDays })
    ]
    fileprivate let choicesArray: [(saveValue: (String) -> Void, getValue: () -> String)] = [
        (saveValue: { SettingsValues.notificationsWorkSound = $0 }, getValue: { return SettingsValues.notificationsWorkSound }),
        (saveValue: { SettingsValues.notificationsShortBreakSound = $0 }, getValue: { return SettingsValues.notificationsShortBreakSound }),
        (saveValue: { SettingsValues.notificationsLongBreakSound = $0 }, getValue: { return SettingsValues.notificationsLongBreakSound })
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.init(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: SettingsCellTypes.switch.reuseIdentifier)
        tableView.register(UINib.init(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: SettingsCellTypes.slider.reuseIdentifier)
        tableView.register(UINib.init(nibName: "SimpleTableViewCell", bundle: nil), forCellReuseIdentifier: SettingsCellTypes.simple.reuseIdentifier)
        tableView.register(UINib.init(nibName: "ChoiceTableViewCell", bundle: nil), forCellReuseIdentifier: SettingsCellTypes.choice.reuseIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableData[indexPath.section][indexPath.row]
        
        switch item.type {
        case .switch:
            let cell = tableView.dequeueReusableCell(withIdentifier: item.type.reuseIdentifier) as! SwitchTableViewCell
            cell.title.text = item.title
            cell.saveValue = switchesArray[item.index].saveValue
            cell.getValue = switchesArray[item.index].getValue
            cell.initSwitch()
            return cell
        case .slider:
            let cell = tableView.dequeueReusableCell(withIdentifier: item.type.reuseIdentifier) as! SliderTableViewCell
            
            switch item.index {
            case 0:
                cell.slider.customColor = PomodoroActivityStates.work.color
            case 1:
                cell.slider.customColor = PomodoroActivityStates.shortBreak.color
            case 2:
                cell.slider.customColor = PomodoroActivityStates.longBreak.color
            default:
                cell.slider.customColor = Utils.pomodoroSliderDefaultColor
            }
            
            cell.title.text = item.title
            cell.slider.minimumValue = slidersArray[item.index].minimum
            cell.slider.maximumValue = slidersArray[item.index].maximum
            cell.saveValue = slidersArray[item.index].saveValue
            cell.getValue = slidersArray[item.index].getValue
            cell.ending = slidersArray[item.index].ending
            cell.initSlider()
            return cell
        case .simple:
            let cell = tableView.dequeueReusableCell(withIdentifier: item.type.reuseIdentifier) as! SimpleTableViewCell
            cell.title.text = item.title
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            cell.selectedBackgroundView = backgroundView
            return cell
        case .choice:
            let cell = tableView.dequeueReusableCell(withIdentifier: item.type.reuseIdentifier) as! ChoiceTableViewCell
            cell.title.text = item.title
            cell.saveValue = choicesArray[item.index].saveValue
            cell.getValue = choicesArray[item.index].getValue
            cell.initCell()
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            cell.selectedBackgroundView = backgroundView
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: item.type.reuseIdentifier)!
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            performSegue(withIdentifier: "showSoundsList", sender: tableView)
        case 3:
            if indexPath.row == 0 {
                removeStatistics(indexPath: indexPath)
            } else {
                setDefaultSettings(indexPath: indexPath)
            }
        default:
            break
        }
    }
    
    // MARK: - Other
    
    fileprivate func removeStatistics(indexPath: IndexPath) {
        let alertController = UIAlertController(title: NSLocalizedString("settings.data.statistics-alert.header", comment: ""), message: NSLocalizedString("settings.data.statistics-alert.body", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("settings.data.statistics-alert.cancel", comment: ""), style: .cancel) { action in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        let okAction = UIAlertAction(title: NSLocalizedString("settings.data.statistics-alert.ok", comment: ""), style: .destructive) { action in
            PomodoroDataProvider.sharedInstance.removeAllRecords()
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.preferredAction = cancelAction
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func setDefaultSettings(indexPath: IndexPath) {
        let alertController = UIAlertController(title: NSLocalizedString("settings.data.settings-alert.header", comment: ""), message: NSLocalizedString("settings.data.settings-alert.body", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("settings.data.settings-alert.cancel", comment: ""), style: .cancel) { action in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        let okAction = UIAlertAction(title: NSLocalizedString("settings.data.settings-alert.ok", comment: ""), style: .destructive) { action in
            SettingsValues.deleteSettings()
            self.tableView.reloadData()
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.preferredAction = cancelAction
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSoundsList" {
            let soundsViewController = segue.destination as! SoundsViewController
            let indexPath = tableView.indexPathForSelectedRow!
            soundsViewController.reloadIndexPath = indexPath
            soundsViewController.getValue = choicesArray[indexPath.row].getValue
            soundsViewController.saveValue = choicesArray[indexPath.row].saveValue
            
            switch indexPath.row {
            case 0:
                soundsViewController.currentActivity = SettingsValues.pomodoroWorkName
            case 1:
                soundsViewController.currentActivity = SettingsValues.pomodoroShortBreakName
            case 2:
                soundsViewController.currentActivity = SettingsValues.pomodoroLongBreakName
            default: break
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
