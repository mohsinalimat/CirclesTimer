import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: {(granted, error) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        })
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        SettingsValues.registerDefaults()
        
        let settingsStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
        let settingsViewController = settingsStoryboard.instantiateViewController(withIdentifier: "SettingsViewControllerIdentifier")
        let controllers = [PomodoroViewController(), ChartsViewController(), settingsViewController]
        let titles = [NSLocalizedString("tabbar.timer", comment: ""), NSLocalizedString("tabbar.statistics", comment: ""), NSLocalizedString("tabbar.settings", comment: "")]
        let imageNames = ["Pomodoro", "Charts", "Settings"]
        
        for (index, controller) in controllers.enumerated() {
            controller.tabBarItem.title = titles[index]
            let unselectedImage = UIImage(named: imageNames[index])!
            let selectedImage = UIImage(named: "\(imageNames[index])Filled")!
            controller.tabBarItem.image = unselectedImage.withRenderingMode(.alwaysOriginal)
            controller.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        }
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = controllers
        
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.tintColor = Utils.selectedTabBarItemColor
        tabBarController.tabBar.barTintColor = Utils.tabBarColor
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Utils.unselectedTabBarItemColor], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Utils.selectedTabBarItemColor], for: .selected)

        window?.backgroundColor = Utils.maskColor
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
    }
    
    // MARK: - CoreData initialization
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "PomodoroDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}
