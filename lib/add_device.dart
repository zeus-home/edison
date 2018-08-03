import 'dart:async';

import 'package:flutter/material.dart';

import 'package:edison/device_configuration_screen.dart';
import 'package:edison/hercules_module.dart';
import 'package:edison/wifi_manager.dart';

class AddDevice extends StatefulWidget {
  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  WifiManager _wifiManager;
  StreamSubscription _wifiSubscription;

  List<String> _devices;
  int retryCount;

  void initState() {
    super.initState();
    retryCount = 5;
    _devices = List();
    _wifiManager = WifiManager();
    _wifiSubscription =
        WifiManager.stream.receiveBroadcastStream().listen(onData);
    Timer.periodic(Duration(seconds: 2), (Timer t) {
      print("searching...");
      if (retryCount != 0) {
        _demandScan();
        setState(() {
          retryCount = retryCount - 1;
        });
      } else {
        t.cancel();
      }
    });
  }

  void _demandScan() {
    _wifiManager.demandScan();
  }

  void onData(dynamic networkList) {
    List<String> wifiNetworks = List.from(networkList);
    List<String> devices =
        HerculesModule.detectHerculesModules(wifiNetworks.toSet().toList());
    List<String> masterList = _devices;
    masterList.addAll(devices);
    setState(() {
      _devices = masterList.toSet().toList();
    });
  }

  void _configure(String deviceNetwork) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) {
        return DeviceConfigurationScreen(deviceNetwork);
      },
    ));
  }

  @override
  void dispose() {
    super.dispose();
    if (_wifiSubscription != null) {
      _wifiSubscription.cancel();
      _wifiSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Add Hercules Device"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          retryCount != 0
              ? Container(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              : Container(),
          Expanded(
            child: Container(
              child: (retryCount != 0 || _devices.isNotEmpty)
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(_devices[index]),
                          onTap: () {
                            _configure(_devices[index]);
                          },
                        );
                      },
                      itemCount: _devices.length,
                    )
                  : Container(child: Text("No device could be found")),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
