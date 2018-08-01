package com.zeus.edison;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends FlutterActivity {

  public static final String TAG = "MainActivity";
  public static final String STREAM = "com.zeus.edison/wifistream";
  public static final String CHANNEL = "com.zeus.edison/wifichannel";

  private WifiManager wifiManager;
  

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);

    new EventChannel(getFlutterView(), STREAM).setStreamHandler(
      new EventChannel.StreamHandler() {

        @Override
        public void onListen(Object args, final EventChannel.EventSink events) {
          Log.w(TAG, "adding listener");
          registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
              List<ScanResult> results = wifiManager.getScanResults();
              ArrayList<String> ssids = new ArrayList();
              int size = results.size();
              // Log.w(TAG, "Size: " + size);
              for(int i = 0; i < size; i++) {
                // Log.w("Wifi", results.get(i).SSID);
                ssids.add(results.get(i).SSID);
              }
              events.success(ssids);
            }
          }, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
        }

        @Override
        public void onCancel(Object args) {
          Log.w(TAG, "cancelling listener");
        }
      }
    );

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
          if(call.method.equals("startWifiScan")) {
            result.success(initiateScan());
          } else if(call.method.equals("addDeviceSSID")) {
            result.success(addSSID((String) call.argument("ssid"), (String) call.argument("psk")));
          } else if(call.method.equals("getCurrentNetwork")) {
            result.success(getCurrentNetwork());
          }
        }
      }
    );
  }

  private boolean initiateScan() {
    try {
      wifiManager.startScan();
      return true;
    } catch(Exception ex) {
      return false;
    }
  }

  private String getCurrentNetwork() {
    try {
      WifiInfo wifiInfo = wifiManager.getConnectionInfo();
      return wifiInfo.getSSID();
    } catch(Exception ex) {
      return "";
    }
  }

  private boolean addSSID(String ssid, String psk) {
    WifiConfiguration networkConf = new WifiConfiguration();
    networkConf.SSID = "\""+ssid+"\"";
    networkConf.preSharedKey = "\""+psk+"\"";
    networkConf.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
    try {
      int networkId = wifiManager.addNetwork(networkConf);
      wifiManager.disconnect();
      wifiManager.enableNetwork(networkId, true);
      wifiManager.reconnect();
      return true;
    } catch(Exception e) {
      return false;
    }
  }
}
