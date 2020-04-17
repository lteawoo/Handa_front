import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Config {
  const Config({
    Map<String, dynamic> configMap,
  }) : _configMap = configMap;
  final Map<String, dynamic> _configMap;

  String get(String key)  {
    if(_configMap == null) {
      return null;
    }
    return _configMap[key];
  }
}

class ConfigLoader {
  Future<Config> init() async {
    final String data = await rootBundle.loadString('assets/config.json');
    debugPrint(data);
    Config config = new Config(configMap: json.decode(data));

    return config;
  }
}