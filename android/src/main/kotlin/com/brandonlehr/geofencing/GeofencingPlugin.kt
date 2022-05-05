package com.brandonlehr.geofencing

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.LocationServices

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** GeofencingPlugin */
class GeofencingPlugin : ActivityAware, FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var mContext: Context? = null
    private var mActivity: Activity? = null
    private var mGeofencingClient: GeofencingClient? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mContext = flutterPluginBinding.applicationContext
        mGeofencingClient = LocationServices.getGeofencingClient(mContext!!)
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "geofencing")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "enableLocationServices") {
//            SwiftGeofencingPlugin.geoFencing.enableLocationServices()
            result.success("true")
        } else if (call.method == "handleRegisterRegionsByLocation") {
            // send appEnabled and list reminders -> returns count of active regions
            val args: Map<String, Any> = call.arguments as Map<String, Any>
            val appEnabled = args["appEnabled"] as Boolean

            var reminds = args["reminders"] as List<Map<String, Any>>
            val reminders = convertListMapToListReminders(reminds)

//            var activeRegions = SwiftGeofencingPlugin.geoFencing.handleRegisterRegionsByLocation(reminders: reminders, appEnabled: appEnabled)
//            result.success(activeRegions.count)
        } else if (call.method == "reminderForEnter") {
            val args: Map<String, Any> = call.arguments as Map<String, Any>
            val reminder = Reminder(args)
//            SwiftGeofencingPlugin.geoFencing.handleEnterRegion(reminder: reminder)
            result.success(true)
        } else if (call.method == "reminderForExit") {
            val args: Map<String, Any> = call.arguments as Map<String, Any>
            val reminder = Reminder(args)
//            SwiftGeofencingPlugin.geoFencing.handleExitRegion(reminder: reminder)
            result.success(true)
        } else if (call.method == "reminderForDisable") {
            val args: Map<String, Any> = call.arguments as Map<String, Any>
            val reminder = Reminder(args)
//            SwiftGeofencingPlugin.geoFencing.disableReminder(reminder: reminder)
            result.success(true)

        } else if (call.method == "getNumberOfActiveRegions") {
//            let regions = SwiftGeofencingPlugin.geoFencing.getActiveRegions();
//            result.success(regions.count);
        } else if (call.method == "stopUpdatingLocationForApp") {
//            SwiftGeofencingPlugin.geoFencing.stopUpdatingLocationForApp();
            result.success(true)
        } else
            if (call.method == "getPlatformVersion") {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            } else {
                result.notImplemented()
            }
    }

    fun convertListMapToListReminders(maps: List<Map<String, Any>>): List<Reminder> {
        var reminders: List<Reminder> = maps.map { t -> Reminder(t) }
        return reminders
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mContext = null
        mGeofencingClient = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        mActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        mActivity = null
    }
}
