import UIKit
import Flutter
import UserNotifications
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, UIResponder, UIApplicationDelegate,  UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var geoFencing = GeoFencing()
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
      UNUserNotificationCenter.current().delegate = self
      
      locationManager = CLLocationManager()
      locationManager?.delegate = self
      
      UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            print(identifier)
            geoFencing.handleEnterRegion(reminderId: String(identifier)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
             print(identifier)
            geoFencing.handleExitRegion(reminderId: String(identifier)!)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.identifier)
        
        var reminderId = 0
        
        let userInfo = response.notification.request.content.userInfo
        if let remindId = userInfo["reminderId"] {
            reminderId = remindId as! String
        }
        
        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            geoFencing.snoozeReminder(reminderId: reminderId)
            break
            
        case "DISABLE_ACTION":
            geoFencing.disableReminder(reminderId: reminderId)
            break
            
        default:
//            if reminderId != 0 {
//                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewController = mainStoryboard.instantiateInitialViewController()
//                self.window = UIWindow(frame: UIScreen.main.bounds)
//                self.window?.rootViewController = initialViewController
//
//                let detailVC = mainStoryboard.instantiateViewController(withIdentifier: "REMINDER_DETAIL") as! ReminderDetailViewController
//                detailVC.reminderId = reminderId
//
//                self.window?.makeKeyAndVisible()
//
//                guard let tabController = self.window?.rootViewController as? UITabBarController else  {
//                    print("NOPE")
//                    completionHandler()
//                    return
//                }
//
//                tabController.selectedIndex = 0
//
//                let navVC = tabController.selectedViewController as! UINavigationController
//
//                navVC.pushViewController(detailVC, animated: true)
//            }
            
            break
        }
        
        completionHandler()
        
    }

}
