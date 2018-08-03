import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HerculesConfig {
  HttpClient _client;

  static Uri _host = Uri.parse("http://192.168.1.1");

  HerculesConfig() {
    _client = HttpClient();
  }

  Future<Map> getCapabilities() async {
    print(_host.toString());
    var request = await _client.getUrl(_host);
    var response = await request.close();
    var text = await response.transform(utf8.decoder).join("");
    print(text);
    return Map();
  }

}

class HerculesCapabilities {

  HerculesCapabilities.fromString();
}