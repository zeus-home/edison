import 'dart:async';

import 'package:flutter/material.dart';

import 'package:edison/hercules_config.dart';
import 'package:edison/wifi_manager.dart';

class DeviceConfigurationScreen extends StatefulWidget {
  final String device;

  DeviceConfigurationScreen(this.device);

  @override
  _DeviceConfigurationScreenState createState() =>
      _DeviceConfigurationScreenState();
}

class _DeviceConfigurationScreenState extends State<DeviceConfigurationScreen> {
  bool _isConnecting = true;

  WifiManager _wifiManager;
  HerculesConfig _config;

  @override
  void initState() {
    super.initState();
    _wifiManager = WifiManager();
    _wifiManager.connectToNetwork(ssid: widget.device);
    _config = HerculesConfig();
    Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      print("checking...");
      if (await _wifiManager.getCurrentSSID() == "\"${widget.device}\"") {
        t.cancel();
        print("Connected...");
        setState(() {
          _isConnecting = false;
        });
        getCapabilities();
      }
    });
  }

  void getCapabilities() {
    print("Fetching...");
    _config.getCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Configure"),
      ),
      body: Column(
        children: [
          _DeviceTitle(widget.device),
          _isConnecting ? _EstablishingConnection() : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getCapabilities,
        child: Icon(Icons.explore),
      ),
    );
  }
}

class _EstablishingConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator();
  }
}

class _DeviceTitle extends StatelessWidget {
  final String device;

  _DeviceTitle(this.device);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Card(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                device,
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
