import 'package:flutter/material.dart';
import 'package:handa/sign_in.dart';
import 'package:handa/sign_up.dart';
import 'package:handa/todo.dart';

import 'config.dart';


//void main() => runApp(MyApp());
void main() => runApp(Test());

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      home: Scaffold(
        body: Column(
          children: <Widget>[
            FlatButton(
              child: Text('Press'),
              onPressed: (() {
                //ConfigLoader.get('server_address');
                ConfigLoader loadder = ConfigLoader();
                loadder.load();
              }),
            )
          ],
        )
      )
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<TodoItem> list = [];
    debugPrint('run..');
    return MaterialApp(
      title: 'Handa',
      initialRoute: '/sign_in',
      routes: {
        '/home': (BuildContext context) => Todo(),
        '/sign_in': (BuildContext context) => SignIn(),
        '/sign_up': (BuildContext context) => SignUp(),
      }
    );
  }
}