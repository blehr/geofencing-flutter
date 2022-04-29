import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Geofencing extends ChangeNotifier {
  final MethodChannel _channel = const MethodChannel('geofencing');

  static Geofencing? _instance;

  Geofencing._internal() {
    _channel.setMethodCallHandler(myMethodCallHandler);
    _instance = this;
  }

  factory Geofencing(Function idForEnterCB, Function idForExitCB,
          Function idForSnoozeCB, Function idForDismissCb) =>
      _instance ?? Geofencing._internal();

  Map<String, double>? lastLoc;

  Map<String, double>? get lastLocation => lastLoc;

  String idForEnter = "";
  String idForExit = "";
  String idForSnooze = "";
  String idForDismiss = "";

  late Function idForEnterCB;
  late Function idForExitCB;
  late Function idForSnoozeCB;
  late Function idForDismissCB;

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

  Future<int> handleRegisterRegionsByLocation(
      List<Map<String, dynamic>> reminders, bool appEnabled) async {
    Map<String, dynamic> send = <String, dynamic>{};
    send["reminders"] = reminders;
    send["appEnabled"] = appEnabled;

    final int activeRegions =
        await _channel.invokeMethod("handleRegisterRegionsByLocation", send);
    return activeRegions;
  }

  Future<String> reminderForEnterRegion(Map<String, dynamic> reminder) async {
    final String status =
        await _channel.invokeMethod("reminderForEnter", reminder);
    return status;
  }

  Future<String> reminderForExitRegion(Map<String, dynamic> reminder) async {
    final String status =
        await _channel.invokeMethod("reminderForExit", reminder);
    return status;
  }

  Future<String> reminderForDisable(Map<String, dynamic> reminder) async {
    final String status =
        await _channel.invokeMethod("reminderForDisable", reminder);
    return status;
  }

  Future<String> reminderForSnooze(Map<String, dynamic> reminder) async {
    final String status =
        await _channel.invokeMethod("reminderForSnooze", reminder);
    return status;
  }

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
          notifyListeners();
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
        break;
      case "idForEnter":
        String id = call.arguments["id"];
        // send id to app - get reminder - call reminderForEnterRegion with reminderMap
        idForEnter = id;
        notifyListeners();
        break;
      case "idForExit":
        String id = call.arguments["id"];
        // send id to app - get reminder - call reminderForExitRegion with reminderMap
        idForExit = id;
        notifyListeners();
        break;
      case "idForSnooze":
        String id = call.arguments["id"];
        // send id to app - get reminder - snooze reminder
        idForSnooze = id;
        notifyListeners();
        break;
      case "idForDisable":
        String id = call.arguments["id"];
        // send id to app - get reminder - set reminder to active = false - send reminder to reminderForDisable
        idForDismiss = id;
        notifyListeners();
        break;
    }
  }
}
