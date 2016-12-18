import UIKit

enum SettingsCellTypes {
    case `switch`
    case slider
    case simple
    case choice
    case sounds
    
    var reuseIdentifier : String {
        get {
            switch self {
            case .switch:
                return "SwitchCellReuseIdentifier"
            case .slider:
                return "SliderCellReuseIdentifier"
            case .simple:
                return "SimpleCellReuseIdentifier"
            case .choice:
                return "ChoiceCellReuseIdentifier"
            case .sounds:
                return "SoundsCellReuseIdentifier"
            }
        }
    }
}

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trigger: PomodoroSwicth!
    @IBOutlet weak var title: UILabel!
    
    var saveValue: ((Bool) -> Void)!
    var getValue: (() -> Bool)!
    
    @IBAction func switchStateChanged(_ sender: UISwitch) {
        saveValue(sender.isOn)
    }
    
    func initSwitch() {
        trigger.isOn = getValue()
    }
}

class SliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var slider: PomodoroSlider!
    
    var saveValue: ((Int) -> Void)!
    var getValue: (() -> Int)!
    var ending: String = ""
    
    @IBAction func sliderValueChanged(_ sender: PomodoroSlider) {
        let result = Int(sender.value)
        saveValue(result)
        value.text = "\(result)\(ending)"
    }
    
    func initSlider() {
        let result = getValue()
        slider.value = Float(result)
        value.text = "\(result)\(ending)"
    }
}

class SimpleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
}

class ChoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryType = .disclosureIndicator
        tintColor = UIColor.white.withAlphaComponent(0.5)
        
        let image = UIImage(named: "DisclosureImage")
        let disclosureView = UIImageView(image: image)
        accessoryView = disclosureView
    }
    
    var saveValue: ((String) -> Void)!
    var getValue: (() -> String)!
    
    func valueChanged(_ result: String) {
        saveValue(result)
        value.text = result
    }
    
    func initCell() {
        value.text = getValue()
    }
}

class SoundsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                title.font = Utils.soundsTableViewCellBoldFont
                accessoryType = .checkmark
            } else {
                title.font = Utils.soundsTableViewCellFont
                accessoryType = .none
            }
        }
    }
}
