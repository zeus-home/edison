import 'dart:async';

import 'package:flutter/services.dart';

class WifiManager {
  static const stream = const EventChannel('com.zeus.edison/wifistream');
  static const method = const MethodChannel('com.zeus.edison/wifichannel');

  static final WifiManager _wifiManager = WifiManager._internal();

  factory WifiManager() {
    return _wifiManager;
  }

  WifiManager._internal();

  Future<Null> demandScan() async {
    try {
      method.invokeMethod('startWifiScan');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<String> getCurrentSSID() async {
    try {
      return await method.invokeMethod('getCurrentNetwork');
    } on PlatformException catch (e) {
      print(e.message);
      return "null";
    }
  }

  Future<bool> connectToNetwork({String ssid, String psk="IrisConfig"}) async {    
    try {
      String currentNetwork = await getCurrentSSID();
      if (!currentNetwork.startsWith("[Hercules]")) {
        bool success = await method.invokeMethod('addDeviceSSID', {"ssid": ssid, "psk": psk});
        return success;
      } else {
        print("Already Connected to Hercules module.");
        return false;
      }
    } on PlatformException catch (e) {
      print(e.message);
      return false;
    }
  }
}
