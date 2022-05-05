package com.brandonlehr.geofencing

class Reminder (
    var _id: String = "",
    var _lat: Double = 0.0,
    var _lng: Double = 0.0,
    var _radius: Int = 0,
    var _name: String = "",
    var _active: Boolean = false,
    var _message: String = "",
    var _snoozeTill: Double = 0.0,
    var _snoozeLength: Int = 0
    ) {
    var id: String = _id
    var lat: Double = _lat
    var lng: Double = _lng
    var radius: Int = _radius
    var name: String = _name
    var active: Boolean = _active
    var message: String = _message
    var snoozeTill: Double = _snoozeTill
    var snoozeLength: Int = _snoozeLength

    constructor(args: Map<String, Any>) : this() {
        this.id = args["id"] as String
        this.lat = args["lat"] as Double
        this.lng = args["lng"] as Double
        this.radius = args["radius"] as Int
        this.name = args["name"] as String
        this.active = args["active"] as Boolean
        this.message = args["message"] as String
        this.snoozeTill = args["snoozeTill"] as Double
        this.snoozeLength = args["snoozeLength"] as Int
    }

    fun toMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        map["id"] = this.id
        map["lat"] = this.lat
        map["lng"] = this.lng
        map["radius"] = this.radius
        map["name"] = this.name
        map["active"] = this.active
        map["message"] = this.message
        map["snoozeTill"] = this.snoozeTill
        map["snoozeLength"] = this.snoozeLength
        return map
    }


}