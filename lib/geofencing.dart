import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Geofencing extends ChangeNotifier {
  final MethodChannel _channel = const MethodChannel('geofencing');

  static final Geofencing _instance = Geofencing._internal();

  Geofencing._internal() {
    _channel.setMethodCallHandler(myMethodCallHandler);
  }

  factory Geofencing(Function getReminderById) {
    _instance.getReminderById = getReminderById;
    return _instance;
  }

  Map<String, double>? lastLoc;

  Map<String, double>? get lastLocation => lastLoc;

  late Function getReminderById;

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> enableLocationServices() async {
    final String status = await _channel.invokeMethod("enableLocationServices");
    return status;
  }

  Future<bool> stopUpdatingLocationForApp() async {
    final bool status =
        await _channel.invokeMethod("stopUpdatingLocationForApp");
    return status;
  }

  Future<int> getNumberOfActiveRegions() async {
    final int result = await _channel.invokeMethod("getNumberOfActiveRegions");
    return result;
  }

  Future<int> handleRegisterRegionsByLocation(
      List<Map<String, dynamic>> reminders, bool appEnabled) async {
    Map<String, dynamic> send = <String, dynamic>{};
    send["reminders"] = reminders;
    send["appEnabled"] = appEnabled;

    final int activeRegions =
        await _channel.invokeMethod("handleRegisterRegionsByLocation", send);
    return activeRegions;
  }

  Future<bool> reminderForEnterRegion(Map<String, dynamic> reminder) async {
    final bool status =
        await _channel.invokeMethod("reminderForEnter", reminder);
    return status;
  }

  Future<bool> reminderForExitRegion(Map<String, dynamic> reminder) async {
    final bool status =
        await _channel.invokeMethod("reminderForExit", reminder);
    return status;
  }

  Future<bool> reminderForDisable(Map<String, dynamic> reminder) async {
    final bool status =
        await _channel.invokeMethod("reminderForDisable", reminder);
    return status;
  }

  // Future<bool> reminderForSnooze(Map<String, dynamic> reminder) async {
  //   final bool status =
  //       await _channel.invokeMethod("reminderForSnooze", reminder);
  //   return status;
  // }

  Future<dynamic> myMethodCallHandler(MethodCall call) async {
    if (kDebugMode) {
      print(call.method);
    }
    switch (call.method) {
      case "locationUpdate":
        try {
          Map<String, double> args = <String, double>{};
          args["lat"] = call.arguments["lat"];
          args["lng"] = call.arguments["lng"];
          lastLoc = args;
          print(args);
          notifyListeners();
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
        break;
      case "idForEnter":
        String id = call.arguments["id"];
        print("idForEnter $id");
        // send id to app - get reminder - call reminderForEnterRegion with reminderMap
        var reminder = getReminderById(id, "ENTER");
        print(reminder);
        reminderForEnterRegion(reminder);
        break;
      case "idForExit":
        String id = call.arguments["id"];
        print("idForExit $id");
        // send id to app - get reminder - call reminderForExitRegion with reminderMap
        var reminder = getReminderById(id, "EXIT");
        print(reminder);
        reminderForExitRegion(reminder);
        break;
      case "idForSnooze":
        String id = call.arguments["id"];
        // send id to app - get reminder - snooze reminder
        var reminder = getReminderById(id, "SNOOZE");
        // reminderForSnooze(reminder);
        break;
      case "idForDisable":
        String id = call.arguments["id"];
        // send id to app - get reminder - set reminder to active = false - send reminder to reminderForDisable
        var reminder = getReminderById(id, "DISABLE");
        reminderForDisable(reminder);
        break;
    }
  }
}
