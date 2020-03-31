import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoItem {
  int no;
  String content;
  bool done;

  TodoItem({
    this.no,
    this.content,
    this.done,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      no: json['no'],
      content: json['content'],
      done: json['done'],
    );
  }
}

class Member {
  String email;
  String password;

  Member({
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() =>
      {
        'email': {
          'value': email,
        },
        'password': {
          'value': password,
        },
      };
}

class TodoItemListWidget extends StatefulWidget {
  final List<TodoItem> items;
  const TodoItemListWidget({
    this.items,
  });

  @override
  _TodoItemListState createState() => _TodoItemListState();
}

class _TodoItemListState extends State<TodoItemListWidget> {
  void _addTodoItem(TodoItem todoItem) {
    setState(() {
      widget.items.add(todoItem);
    });
  }

  void _deleteTodoItem(TodoItem todoItem) {
    setState(() {
      widget.items.remove(todoItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handa'),
      ),
      body: Center(
        child: ReorderableListView(
            children: [
              for (final item in widget.items)
                Card(
                  key: UniqueKey(),
                  child: StatefulBuilder(builder: (context, setState) {
                    return new CheckboxListTile(
                        title: new Text(item.content),
                        value: item.done,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool val) {
                          setState(() {
                            item.done = val;
                          });
                        },
                        secondary: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              debugPrint("delete");
                              _deleteTodoItem(item);
                            });
                          },
                        )
                    );
                  }),
                )
            ],
            onReorder: (oldIndex, newIndex) {
              setState(() {
                TodoItem item = widget.items[oldIndex];
                widget.items.removeAt(oldIndex);
                widget.items.insert(newIndex > oldIndex ? newIndex - 1: newIndex, item);
              });
            }
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _showModalBottomSheet(context);
          },
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    submit(String where) {
      final String input = _controller.text.trim();
      debugPrint('$where, request submit, you typed $input');

      if(input == '') {
        debugPrint('$where, you typed blank pass');
        return;
      }

      _addTodoItem(new TodoItem(content: input, done: false));
      debugPrint('submitted, you typed $input');
    }

    showModalBottomSheet<void>(
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 3,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '무엇을 할건가요?',
                      border: InputBorder.none,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      /*FlatButton(
                        child: Text('회원가입'),
                        onPressed: () {
                          fetchItem();
                        },
                      ),*/
                      FlatButton(
                        child: Text('accesstoken'),
                        onPressed: () {
                          getAccessToken();
                        },
                      ),
                      FlatButton(
                        child: Text('checktoken'),
                        onPressed: () {
                          checkToken();
                        },
                      ),
                      FlatButton(
                        child: Text('아이템목록'),
                        onPressed: () {
                          fetchItems();
                        },
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton.icon(
                            textColor: Theme.of(context).primaryColor,//Theme.of(context).textTheme.button.color,
                            icon: const Icon(Icons.add, size: 18),
                            label: Text('등록'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
        );
      },
    ).whenComplete(() {
      submit('close');
    });
  }

  Future<Member> signin() async {
    String username = 'test@taeu.kr';
    String password = '123415';
    String header = base64Encode(utf8.encode('$username:$password'));

    Member member = new Member(email: username, password: password);
    debugPrint(member.toJson().toString());
    debugPrint('json : ' + jsonEncode(member));
    final response = await http.post(
      'http://localhost:8080/member/signin',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(member),
    ).catchError((error) {
      throw error;
    });
    debugPrint(response.body);
    Map<String, String> temp = response.headers;
    for(String s in temp.keys) {
      debugPrint(s + ": " + temp[s]);
    }
  }

  void getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = 'test@taeu.kr';
    String password = '12345';
    String uri = "http://localhost:8080/oauth/token?grant_type=password&username=$username&password=$password";
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
      debugPrint(error.toString());
      throw error;
    });

    debugPrint(response.body);
    Map responseMap = jsonDecode(response.body);
    prefs.setString('access_token', responseMap['access_token']);
  }

  void checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('access_token');
    String clientId = "taeu_client";
    String clientPw = "taeu_secret";
    String authorization = "Basic " + base64Encode(utf8.encode('$clientId:$clientPw'));
    String uri = 'http://localhost:8080/oauth/check_token?token=$token';

    final response = await http.post(
      uri,
      headers: {
        'Authorization': authorization,
      },
    ).catchError((error) {
      debugPrint(error.toString());
      throw error;
    });

    debugPrint(response.body);
  }

  Future<List<TodoItem>> fetchItems() async {
    final response = await http.post(
      'http://localhost:8080/api/list',
    ).catchError((error) {
      throw error;
    });

    debugPrint(response.body);
  }
}