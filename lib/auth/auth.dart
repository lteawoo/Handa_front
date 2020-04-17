import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:handa/auth/sign_up_request.dart';
import 'package:handa/sign_up.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class Auth {
  const Auth({
    this.config,
  });
  final Config config;

  Future<bool> signUp(SignUpRequest req) async {
    String uri = config.get('server_address') + "/member/signup";
    String body = json.encode(req);
    debugPrint(body);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': "application/json;charset=UTF-8",
        'Accept': "application/json;charset=UTF-8",
      },
      body: body,
    ).catchError((error) {
      debugPrint(error.toString());
      throw error;
    });
    Map responseMap = jsonDecode(response.body);
    debugPrint(response.statusCode.toString());

    if(response.statusCode == 200) {
     return true;
    } else {
      //_errorMsgKey.currentState.setErrorMsg(response.statusCode.toString() + ', ' + responseMap['error'] + ': ' + responseMap['error_description']);
      debugPrint(responseMap.toString());
      return false;
    }
  }
}

class AuthProvider extends InheritedWidget {
  const AuthProvider({
    Key key,
    Widget child,
    this.auth
  }): super(key: key, child: child);
  final Auth auth;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AuthProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
  }
}