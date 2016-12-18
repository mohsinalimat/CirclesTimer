import UIKit
import AudioToolbox

class SoundsViewController: UITableViewController, UINavigationControllerDelegate {
    
    var currentActivity : String!
    var reloadIndexPath : IndexPath!
    
    var saveValue: ((String) -> Void)!
    var getValue: (() -> String)!
    
    fileprivate var currentIndex = 0
    fileprivate var soundsList = [String]()
    fileprivate var currentSystemSoundID : SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        self.navigationItem.title = currentActivity
        tableView.register(UINib.init(nibName: "SoundsTableViewCell", bundle: nil), forCellReuseIdentifier: SettingsCellTypes.sounds.reuseIdentifier)
        
        let resourceURL = Bundle.main.resourceURL!
        let fileManager = FileManager()
        do {
            let URLs = try fileManager.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions())
            URLs.filter({ $0.pathExtension == "aiff" }).forEach({
                let name = $0.lastPathComponent
                soundsList.append(name.substring(to: name.characters.index(name.endIndex, offsetBy: -5)))
            })
        } catch { }
        currentIndex = soundsList.index(where: { $0 == getValue() })!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if currentSystemSoundID != 0 {
            AudioServicesDisposeSystemSoundID(currentSystemSoundID)
            currentSystemSoundID = 0
        }
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? soundsList.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellTypes.sounds.reuseIdentifier, for: indexPath) as! SoundsTableViewCell

        cell.title.text = soundsList[indexPath.row]
        cell.isSelected = indexPath.row == currentIndex

        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentSystemSoundID != 0 {
            AudioServicesDisposeSystemSoundID(currentSystemSoundID)
            currentSystemSoundID = 0
        }
        
        tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))?.isSelected = false
        currentIndex = indexPath.row
        tableView.cellForRow(at: IndexPath(row: currentIndex, section: 0))?.isSelected = true
        saveValue(soundsList[currentIndex])

        let url = Bundle.main.url(forResource: soundsList[currentIndex], withExtension: "aiff")!
        AudioServicesCreateSystemSoundID(url as CFURL, &currentSystemSoundID)
        AudioServicesPlayAlertSound(currentSystemSoundID)
    }
    
    // MARK: - Other
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let settingsController = viewController as? SettingsViewController {
            settingsController.tableView.reloadRows(at: [reloadIndexPath], with: .none)
        }
    }
}
