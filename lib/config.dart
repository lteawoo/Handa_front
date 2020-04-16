import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  Future<List<ConfigItem>> load() async {
    final String data = await rootBundle.loadString('assets/config.json');
    final parsed = json.decode(data).cast<Map<String, dynamic>>();
/*    final List<ConfigItem> list = parsed.map<ConfigItem>((json) {
          debugPrint(json);
          return ConfigItem.fromJson(json);
        }).toList();*/

    return null;
  }
/*  static Future<String> get(String name) async {
    List<ConfigItem> list = await load();

    return "";
  }*/
}