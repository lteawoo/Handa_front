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
  //int order;

  TodoItem({
    this.no,
    this.content,
    this.done,
    //this.order,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      no: json['no'],
      content: json['content'],
      done: json['done'],
      //order: json['order']
    );
  }
}

class TodoItemListWidget extends StatefulWidget {
  @override
  _TodoItemListState createState() => _TodoItemListState();
}

class _TodoItemListState extends State<TodoItemListWidget> {
  final List<TodoItem> items = [];

  @override
  void initState() {
    debugPrint('init');
    super.initState();
    _fetchItems();
  }

  Future<String> _getAccessTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void _fetchItems() async {
    String accessToken = await _getAccessTokenFromStorage();
    if(accessToken == null) {
      return;
    }
    debugPrint('token : ' + accessToken);

    final response = await http.get(
      'http://localhost:8080/api/item/list',
      headers: {
        'Authorization' : 'Bearer ' + accessToken,
        'Accept': "application/json;charset=UTF-8",
      },
    ).catchError((error) {
      debugPrint(error);
      throw error;
    });
    debugPrint(response.statusCode.toString());

    if(response.statusCode == 200) {
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      List<TodoItem> list = parsed.map<TodoItem>((json) => TodoItem.fromJson(json)).toList();
      setState(() {
        items.addAll(list);
      });
    } else {
      Map responseMap = jsonDecode(response.body);
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(response.statusCode.toString() + ', ' + responseMap['error'] + ': ' + responseMap['error_description']),
      ));
      return null;
    }

    /*list.add(new TodoItem(
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

    setState(() =>items.addAll(list));*/
  }


  Future<TodoItem> _fetchItem() async {
    String accessToken = await _getAccessTokenFromStorage();

    final response = await Future.delayed(Duration(milliseconds: 2000));

    return new TodoItem(no: 1, content: 'test');
  }

  void _addTodoItem(TodoItem todoItem) async {
    String accessToken = await _getAccessTokenFromStorage();
    if(accessToken == null) {
      return;
    }
    final response = await http.post(
      'http://localhost:8080/api/item/write',
      headers: {
        'Authorization' : 'Bearer ' + accessToken,
        'Content-Type': "application/json;charset=UTF-8",
        'Accept': "application/json;charset=UTF-8",
      },
      body: json.encode({
        'content': todoItem.content,
      }),
    ).catchError((error) {
      throw error;
    });

    debugPrint(response.body);
    if(response.statusCode == 200) {
      setState(() {
        items.add(todoItem);
      });
    }
  }

  void _deleteTodoItem(TodoItem todoItem) {
    setState(() {
     items.remove(todoItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('items : ${items.length}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Handa'),
      ),
      body: ReorderableListView(
        children: [
          for (final item in items)
            Card(
              key: UniqueKey(),
              child: StatefulBuilder(builder: (context, setState) {
                return new CheckboxListTile(
                    title: new Text(item.content),
                    value: item.done != null ? item.done : false,
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
            TodoItem item = items[oldIndex];
            items.removeAt(oldIndex);
            items.insert(newIndex > oldIndex ? newIndex - 1: newIndex, item);
          });
        }
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
                          //fetchItems();
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
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String token = prefs.getString('access_token');
    String token = await _getAccessTokenFromStorage();
    if (token == null || token.isEmpty) {
      debugPrint('token is null');
      return;
    }
    String clientId = "taeu_client";
    String clientPw = "taeu_secret";
    String authorization = "Basic " +
        base64Encode(utf8.encode('$clientId:$clientPw'));
    String uri = 'http://localhost:8080/oauth/check_token?token=$token';
    debugPrint(authorization + ', ' + uri);

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

}