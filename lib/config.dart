import 'dart:convert';

import 'package:flutter/services.dart';

class ConfigItem {
  String key;
  String value;

  ConfigItem({
    this.key,
    this.value,
  });

  factory ConfigItem.fromJson(Map<String, dynamic> json) {
    return ConfigItem(
      key: json['key'],
      value: json['value'],
    );
  }
}

class ConfigLoader {
  static Future<Map<String, dynamic>> load() async {
    final String data = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> parsed = json.decode(data);

    return parsed;
  }

  static Future<String> get(String key) async {
    final String data = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> parsed = json.decode(data);

    return parsed[key];
  }
}