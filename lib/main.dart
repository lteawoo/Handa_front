import 'package:flutter/material.dart';
import 'package:handa/sign_in.dart';
import 'package:handa/todo.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<TodoItem> list = [];
    list.add(new TodoItem(
      no: 1,
      content: '딸기를 먹자',
      done: false,
    ));

    list.add(new TodoItem(
      no: 2,
      content: '바나나를 먹자',
      done: true,
    ));
    list.add(new TodoItem(
      no: 3,
      content: '바나나를 먹자',
      done: true,
    ));
    list.add(new TodoItem(
      no: 4,
      content: '바나나를 먹자',
      done: true,
    ));
    list.add(new TodoItem(
      no: 5,
      content: '바나나를 먹자',
      done: true,
    ));    list.add(new TodoItem(
      no: 6,
      content: '바나나를 먹자',
      done: true,
    ));

    debugPrint('list size: ' + list.length.toString());

    return MaterialApp(
      title: 'Handa',
      /*home: TodoItemListWidget()*/
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => SignIn(),
        '/todo': (BuildContext context) => TodoItemListWidget(items: list),
        //'/sign_up':
      }
    );
  }
}