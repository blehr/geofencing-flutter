import Foundation
import CoreLocation


struct Reminder {
  var id: String = ""
  var lat: Double = 0
  var lng: Double = 0
  var radius: Int = 0
  var name: String = ""
  var active: Bool = false
  var message: String = ""
  var snoozeTill: Double = 0
  var snoozeLength: Int = 0

  init(fromDictionary r: [String: Any]) {
    id = r["id"] as! String
    lat = r["lat"] as! Double
    lng = r["lng"] as! Double
    radius = r["radius"] as! Int
    name = r[name] as! String
    active = r["active"] != nil ? r["active"] as! Bool : false
    message = r["message"] as! String
    snoozeTill = r["snoozeTill"] as! Double
    snoozeLength = r["snoozeLength"] as! Int
  }

  func toDict() -> [String: Any] {
        var dict = [String: Any]()
        dict["id"] = id
        dict["lat"] = lat
        dict["lng"] = lng
        dict["radius"] = radius
        dict["name"] = name
        dict["active"] = active
        dict["message"] = message
        dict["snoozeTill"] = snoozeTill
        dict["snoozeLength"] = snoozeLength

        return dict
    }

    func getLocation2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    func getLocation() -> CLLocation {
        return CLLocation(latitude: lat, longitude: lng)
    }

}