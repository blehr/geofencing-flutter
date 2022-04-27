import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Geofencing {
  final MethodChannel _channel = const MethodChannel('geofencing');

  static Geofencing? _instance;

  Geofencing._internal() {
    _channel.setMethodCallHandler(myMethodCallHandler);
    _instance = this;
  }

  factory Geofencing() => _instance ?? Geofencing._internal();

  Map<String, double>? lastLoc;

  Map<String, double>? get lastLocation => lastLoc;

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> enableLocationServices() async {
    final String status = await _channel.invokeMethod("enableLocationServices");
    return status;
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
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
        break;
      case "idForEnter":
        int id = call.arguments["id"];
        // send id to app - get reminder - call reminderForEnterRegion with reminderMap
        break;
      case "idForExit":
        int id = call.arguments["id"];
        // send id to app - get reminder - call reminderForExitRegion with reminderMap
        break;
      case "idForSnooze":
        int id = call.arguments["id"];
        // send id to app - get reminder - snooze reminder
        break;
      case "idForDisable":
        int id = call.arguments["id"];
        // send id to app - get reminder - set reminder to active = false - send reminder to reminderForDisable
        break;
    }
  }
}