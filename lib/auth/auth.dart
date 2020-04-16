import 'package:flutter/cupertino.dart';

class Auth {
  Future<bool> signUp(Member member) {

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