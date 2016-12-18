import UIKit

class Utils {
    
    static let backgroundColor = UIColor(red: 2 / 255.0, green: 7 / 255.0, blue: 121 / 255.0, alpha: 1.0)
    static let gradientColors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor]
    static let maskColor = UIColor(red: 22 / 255.0, green: 24 / 255.0, blue: 81 / 255.0, alpha: 1.0)
    
    static let navigationBarColor = UIColor(red: 6 / 255.0, green: 9 / 255.0, blue: 66 / 255.0, alpha: 1.0)
    static let tabBarColor = UIColor(red: 91 / 255.0, green: 94 / 255.0, blue: 150 / 255.0, alpha: 1.0)
    static let selectedTabBarItemColor = UIColor.white
    static let unselectedTabBarItemColor = UIColor.white.withAlphaComponent(0.5)
    
    static let horizontalPickerViewCellFont = UIFont.systemFont(ofSize: 20)
    static let horizontalPickerViewCellBoldFont = UIFont.systemFont(ofSize: 20, weight: 2)
    static let horizontalPickerViewCellFontColor = UIColor.white
    
    static let soundsTableViewCellFont = UIFont.systemFont(ofSize: 15)
    static let soundsTableViewCellBoldFont = UIFont.systemFont(ofSize: 15, weight: 2)
    
    static let settingsTableViewFont = UIFont.systemFont(ofSize: 17)
    static let pomodoroSliderDefaultColor = UIColor.white
}
