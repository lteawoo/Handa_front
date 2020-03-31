import 'package:flutter/material.dart';
import 'package:handa/sign_in.dart';
import 'package:handa/sign_up.dart';
import 'package:handa/todo.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<TodoItem> list = [];

    return MaterialApp(
      title: 'Handa',
      initialRoute: '/sign_in',
      routes: {
        '/home': (BuildContext context) => TodoItemListWidget(items: list),
        '/sign_in': (BuildContext context) => SignIn(),
        '/sign_up': (BuildContext context) => SignUp(),
      }
    );
  }
}