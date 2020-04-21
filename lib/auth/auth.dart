import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:handa/auth/sign_in_request.dart';
import 'package:handa/auth/sign_up_request.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      return error;
    });

    return response;
  }

  Future<Response> signIn(SignInRequest req) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = req.email;
    String password = req.password;
    String uri = config.get('server_address') + "/oauth/token?grant_type=password&username=$username&password=$password";
    String clientId = "taeu_client";
    String clientPw = "taeu_secret";
    String authorization = "Basic " + base64Encode(utf8.encode('$clientId:$clientPw'));
    debugPrint(authorization);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': authorization,
      },
    ).catchError((error) {
      debugPrint('error: ' + error.toString());

      return error;
    });

    Map responseMap = jsonDecode(response.body);

    debugPrint('status'+ response.statusCode.toString());

    if(response.statusCode == 200) {
      prefs.setString('access_token', responseMap['access_token']);
    }

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