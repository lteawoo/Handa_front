import 'package:flutter/material.dart';
import 'package:handa/sign_in.dart';
import 'package:handa/sign_up.dart';
import 'package:handa/todo.dart';
import 'package:provider/provider.dart';

import 'auth/auth.dart';
import 'config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(StarterApp());
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (_) => ConfigLoader().init()),
      ],
      child: TestApp(),
    );
  }
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _config = Provider.of<Config>(context);

    return MaterialApp(
        title: 'Test',
        home: _config == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
            body: Column(
              children: <Widget>[
                FlatButton(
                  child: Text('Press'),
                  onPressed: (() {
                    debugPrint(_config.get('server_address'));
                  }),
                )
              ],
            )
        )
    );
  }
}

class StarterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (_) => ConfigLoader().init()),
      ],
      child: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = Provider.of<Config>(context);

    return config == null
        ? Center(child: CircularProgressIndicator())
        : MaterialApp(
          title: 'Handa',
          initialRoute: '/sign_in',
          routes: {
            '/home': (BuildContext context) => Todo(
              config: config,
            ),
            '/sign_in': (BuildContext context) => AuthProvider(
              auth: Auth(config: config),
              child: SignIn(),
            ),
            '/sign_up': (BuildContext context) => AuthProvider(
              auth: Auth(config: config),
              child: SignUp(),
            ),
          }
    );
  }
}