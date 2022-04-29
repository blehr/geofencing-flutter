import Flutter
import UIKit
import CoreLocation

public class SwiftGeofencingPlugin: NSObject, FlutterPlugin, GeoFencingDelegate {
    func snoozeReminderFromId(id: String) {
        var send: [String: String] = [:]
        send["id"] = id
        SwiftGeofencingPlugin.sendIdForSnooze(args: send)
    }
    
    func disableReminderFromId(id: String) {
        var send: [String: String] = [:]
        send["id"] = id
        SwiftGeofencingPlugin.sendIdForDisable(args: send)
    }
    
    func getReminderForEnter(id: String) {
        var send: [String: String] = [:]
        send["id"] = id
        SwiftGeofencingPlugin.sendIdForEnter(args: send)
    }
    
    func getReminderForExit(id: String) {
        var send: [String: String] = [:]
        send["id"] = id
        SwiftGeofencingPlugin.sendIdForExit(args: send)
    }
    
    public static var geoFencing: GeoFencing = GeoFencing()
    static var channel: FlutterMethodChannel?
    static var instance: SwiftGeofencingPlugin?

    func locationDidUpdate(location: CLLocation) {
        var send : [String: Double] = [:]
        send["lat"] = location.coordinate.latitude
        send["lng"] = location.coordinate.longitude
        
        SwiftGeofencingPlugin.sendLocation(args: send)
    }
    
    public static func sendLocation(args: [String: Double]) {
        channel?.invokeMethod("locationUpdate", arguments: args)
    }
    public static func sendIdForEnter(args: [String: String]) {
        channel?.invokeMethod("idForEnter", arguments: args)
    }
    public static func sendIdForExit(args: [String: String]) {
        channel?.invokeMethod("idForExit", arguments: args)
    }
    public static func sendIdForSnooze(args: [String: String]) {
        channel?.invokeMethod("idForSnooze", arguments: args)
    }
    public static func sendIdForDisable(args: [String: String]) {
        channel?.invokeMethod("idForDisable", arguments: args)
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "geofencing", binaryMessenger: registrar.messenger())
        instance = SwiftGeofencingPlugin()
        registrar.addMethodCallDelegate(instance!, channel: channel!)
        geoFencing.delegate = instance
    }
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method.elementsEqual("enableLocationServices")) {
            SwiftGeofencingPlugin.geoFencing.enableLocationServices()
            result("true")
        } else if (call.method.elementsEqual("handleRegisterRegionsByLocation")) {
             // send appEnabled and list reminders -> returns count of active regions
            let args: [String: Any] = call.arguments as! [String : Any]
            let appEnabled = args["appEnabled"] as! Bool
            print("appEnabled  = \(appEnabled)")
            
            let reminds = args["reminders"] as! [[String: Any]]
            let reminders = convertListDictToArrayReminders(dictionaryReminders: reminds)
        
            let activeRegions = SwiftGeofencingPlugin.geoFencing.handleRegisterRegionsByLocation(reminders: reminders, appEnabled: appEnabled)
            result(activeRegions.count)
        } else if (call.method.elementsEqual("reminderForEnter")) {
             let args: [String: Any] = call.arguments as! [String : Any]
             let reminder = Reminder.init(fromDictionary: args)
            if #available(iOS 10.0, *) {
                SwiftGeofencingPlugin.geoFencing.handleEnterRegion(reminder: reminder)
            }
            result(true)
        } else if (call.method.elementsEqual("reminderForExit")) {
            let args: [String: Any] = call.arguments as! [String : Any]
            let reminder = Reminder.init(fromDictionary: args)
           if #available(iOS 10.0, *) {
               SwiftGeofencingPlugin.geoFencing.handleExitRegion(reminder: reminder)
           }
           result(true)
        }  else if (call.method.elementsEqual("reminderForDisable")) {
            let args: [String: Any] = call.arguments as! [String : Any]
            let reminder = Reminder.init(fromDictionary: args)
            SwiftGeofencingPlugin.geoFencing.disableReminder(reminder: reminder)
           result(true)
        } else if (call.method.elementsEqual("stopUpdatingLocationForApp")) {
            SwiftGeofencingPlugin.geoFencing.stopUpdatingLocationForApp();
            result(true)
        }
        
        
        
        
        result("iOS " + UIDevice.current.systemVersion)
    }


    func convertListDictToArrayReminders(dictionaryReminders: [[String: Any]]) -> [Reminder] {
        var reminders = [Reminder]()
        for r in dictionaryReminders {
            reminders.append(Reminder.init(fromDictionary: r))
        }
        return reminders
    }
    
    
}
