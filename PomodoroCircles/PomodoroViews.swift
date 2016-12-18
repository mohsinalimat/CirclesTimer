import UIKit

@IBDesignable
class PomodoroSwicth: UISwitch {
    
    @IBInspectable var customColor: UIColor? {
        didSet {
            if let color = customColor {
                onTintColor = color.withAlphaComponent(0.5)
                tintColor = color.withAlphaComponent(0.5)
            } else {
                onTintColor = customColor
                tintColor = customColor
            }
            thumbTintColor = customColor
        }
    }
}

@IBDesignable
class PomodoroSlider: UISlider {
    
    @IBInspectable var customColor: UIColor? {
        didSet {
            if let color = customColor {
                maximumTrackTintColor = color.withAlphaComponent(0.5)
            } else {
                maximumTrackTintColor = customColor
            }
            minimumTrackTintColor = customColor
            thumbTintColor = customColor
        }
    }
}
