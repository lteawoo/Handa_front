import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:handa/auth/sign_up_request.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../config.dart';

class Auth {
  const Auth({
    this.config,
  });
  final Config config;

  Future<Response> signUp(SignUpRequest req) async {
    String uri = config.get('server_address') + "/member/signup";
    String body = json.encode(req);
    debugPrint(body);

    final Response response = await http.post(
      uri,
      headers: {
        'Content-Type': "application/json;charset=UTF-8",
        'Accept': "application/json;charset=UTF-8",
      },
      body: body,
    ).catchError((error) {
      debugPrint(error.toString());
      //throw error;
      return error;
    });

    return response;
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