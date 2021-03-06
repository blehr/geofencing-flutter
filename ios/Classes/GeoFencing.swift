//
//  OnGoing.swift
//  remindmewhenimthere
//
//  Created by Brandon Lehr on 4/29/19.
//  Copyright © 2019 Brandon Lehr. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol GeoFencingDelegate {
    func locationDidUpdate(location: CLLocation)
    func getReminderForEnter(id: String)
    func getReminderForExit(id: String)
    func snoozeReminderFromId(id: String)
    func disableReminderFromId(id: String)
    func openToReminder(id: String)
}

public class GeoFencing : NSObject, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()
    var lastLocation: CLLocation?
    
    var delegate: GeoFencingDelegate?
    
    
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            stopUpdatingLocation()
            break
            
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            break
            
        case .authorizedAlways:
            locationManager.pausesLocationUpdatesAutomatically = false
            
            startReceivingLocationChanges()
            break
        default:
            break
        }
        if #available(iOS 10.0, *) {
            createActionsAndCategories()
            requestNotificationAccess()
        }
       
    }
    
    func stopUpdatingLocationForApp() {
        locationManager.stopUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            return
        }
        
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last!
        let delta = lastLocation?.timestamp.timeIntervalSinceNow
        if (delta ?? -121 > -120) {
            stopUpdatingLocation()
        }
        
       delegate?.locationDidUpdate(location: lastLocation!)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            manager.stopUpdatingLocation()
            return
        }
    }
    
    @available(iOS 10.0, *)
    func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("granted Notification access: \(granted)")
        }
    }
    
    
    @available(iOS 10.0, *)
    func createLocalNotificationTrigger(reminder: Reminder, trigger: String) {
         let content = UNMutableNotificationContent()
         content.title = "\(trigger)\(reminder.name)"
         content.body = reminder.message
         content.sound = UNNotificationSound.default
         content.userInfo = reminder.toDict()
         content.categoryIdentifier = "REMINDER_CATEGORY_ALL"
        
        
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
         let request = UNNotificationRequest(identifier: "\(reminder.id)", content: content, trigger: trigger)
        
         UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
     }
    
    
    
    @available(iOS 10.0, *)
    func createActionsAndCategories() {
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION",
                                                title: "Snooze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        
        let disableAction = UNNotificationAction(identifier: "DISABLE_ACTION",
                                                 title: "Disable",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        
        if #available(iOS 11.0, *) {
            let reminderCategoryAll =
                UNNotificationCategory(identifier: "REMINDER_CATEGORY_ALL",
                                       actions: [snoozeAction,disableAction],
                                       intentIdentifiers: [],
                                       hiddenPreviewsBodyPlaceholder: "",
                                       options: .customDismissAction)
            
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.setNotificationCategories([reminderCategoryAll])
        } else {
            // Fallback on earlier versions
        }
    }

    public func openToReminder(reminderId: String) {
        delegate?.openToReminder(id: reminderId)
    }
    
     public func snoozeReminder(reminderId: String) {
        // send id to app - all work below can be done there
         delegate?.snoozeReminderFromId(id: reminderId)
     }
    
    
     public func disableReminder(reminderId: String) {
         // send id to app - update reminder - send reminder to disable reminder
         delegate?.disableReminderFromId(id: reminderId)
     }
    
    func disableReminder(reminder: Reminder) {
        stopMonitoringReminderLocation(reminder: reminder)
    }
    
    func startMonitoringReminderLocation(reminder: Reminder) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                let center = CLLocationCoordinate2D(latitude: reminder.lat, longitude: reminder.lng)
                let region = CLCircularRegion(center: center,
                                              radius: CLLocationDistance(reminder.radius), identifier: "\(reminder.id)")
                
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
    func stopMonitoringReminderLocation(reminder: Reminder) {
        let center =  reminder.getLocation2D()
        let region = CLCircularRegion(center: center,
                                      radius: CLLocationDistance(reminder.radius), identifier: "\(reminder.id)")
        
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.stopMonitoring(for: region)
    }
    
    
    public func getActiveRegions() -> Set<CLRegion> {
        let activeRegions = locationManager.monitoredRegions
        print("ACTIVE REGIONS \(activeRegions)")
        return activeRegions;
    }
    
     public func handleEnterRegion(reminderId: String) {
         // send enter action and id to get reminder
         delegate?.getReminderForEnter(id: reminderId)
     }
    
    @available(iOS 10.0, *)
    func handleEnterRegion(reminder: Reminder) {
        let timestamp = Date().timeIntervalSince1970 * 1000
        if reminder.active == true && reminder.snoozeTill < timestamp {
            createLocalNotificationTrigger(reminder: reminder, trigger: "Entering ")
        }
    }
    
     public func handleExitRegion(reminderId: String) {
         // send exit action and id to get reminder
         delegate?.getReminderForExit(id: reminderId)
     }
    
    @available(iOS 10.0, *)
    func handleExitRegion(reminder: Reminder) {
        let timestamp = Date().timeIntervalSince1970 * 1000
        if reminder.active == true && reminder.snoozeTill < timestamp {
            createLocalNotificationTrigger(reminder: reminder, trigger: "Leaving ")
        }
    }
    
    func sortLocationsByDistance(reminders: [Reminder]) -> [Reminder] {
        var remindersArray = reminders
        if let location = lastLocation {
            remindersArray.sort(by: {
                (first, second) -> Bool in
                
                return first.getLocation().distance(from: location) < second.getLocation().distance(from: location)
            })
        }
        return remindersArray
    }
    
    func handleRegisterRegionsByLocation(reminders: [Reminder], appEnabled: Bool) -> Set<CLRegion> {
        let activeReminders = reminders.filter{$0.active == true}
        let inactiveReminders = reminders.filter{$0.active == false}
        let maxCount = 20
        let activeRegions = locationManager.monitoredRegions
        
        for ar in activeRegions {
            locationManager.stopMonitoring(for: ar)
        }
        
        if appEnabled == false {
            for r in reminders {
                stopMonitoringReminderLocation(reminder: r)
            }
        } else {
            for ir in inactiveReminders {
                stopMonitoringReminderLocation(reminder: ir)
            }
            
            if activeReminders.count > maxCount {
                let sortedArray = sortLocationsByDistance(reminders: activeReminders)
                
                let maxAllowedArray = sortedArray[..<maxCount]
                for mr in maxAllowedArray {
                    startMonitoringReminderLocation(reminder: mr)
                }
            } else {
                for ar in activeReminders {
                    startMonitoringReminderLocation(reminder: ar)
                }
            }
        }
        let active = locationManager.monitoredRegions
        return active
    }
    
    
    
}

