import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:handa/config.dart';
import 'package:http/http.dart' as http;

import 'auth/auth.dart';

class TodoItem {
  int id;
  String content;
  bool done;
  double position;
  DateTime lastModifiedDate;

  TodoItem({
    this.id,
    this.content,
    this.done,
    this.position,
    this.lastModifiedDate,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      content: json['content'],
      done: json['done'],
      position: json['position'],
      lastModifiedDate: DateTime.parse(json['lastModifiedDate']),
    );
  }

  toString() => 'id: $id, content: $content, done: $done, position: $position, lastModifiedDate: $lastModifiedDate';
}

class Todo extends StatefulWidget {
  const Todo({
    this.config,
  });
  final Config config;

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final List<TodoItem> items = [];
  bool started = false;

  @override
  void initState() {
    debugPrint('init');
    super.initState();

    started = true;
    _swapList();
    _startTimer();
  }

  @override
  void dispose() {
    debugPrint('dispose');
    started = false;
    super.dispose();
  }

  void refreshTest() {
    final auth  = AuthProvider.of(context).auth;
    auth.refreshToken();
  }

  void _swapList() {
    Future<List<TodoItem>> f = _fetchItems();

    f.then((list) {
      debugPrint('swapList then');
      setState(() {
        items.clear();
        items.addAll(list);
      });
      return;
    });

    debugPrint('swapList after');
  }

  void _startTimer() {
    Timer.periodic(Duration(milliseconds: 10000), (timer) {
      debugPrint('started : $started');
      if(started) {
        _swapList();
      } else {
        timer.cancel();
      }
    });
  }

  Future<List<TodoItem>> _fetchItems() async {
    final auth = AuthProvider.of(context).auth;
    String accessToken = await auth.getAccessTokenFromStorage();
    if(accessToken == null) {
      return null;
    }
    debugPrint('token : ' + accessToken);
    dynamic response = null;
    try {
      response = await http.get(
        widget.config.get('server_address') + '/api/item/list',
        headers: {
          'Authorization' : 'Bearer ' + accessToken,
          'Accept': "application/json;charset=UTF-8",
        },
      );
      debugPrint(response.headers.toString());
      debugPrint(response.statusCode.toString());
    } catch(e) {
      debugPrint(e.toString());
    }

    if(response.statusCode == 200) {
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      List<TodoItem> list = parsed.map<TodoItem>((json) {
        debugPrint(json.toString());
        return TodoItem.fromJson(json);
      }).toList();
      return list;
    } else {
      Map responseMap = jsonDecode(response.body);
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(response.statusCode.toString() + ', ' + responseMap['error'] + ': ' + responseMap['error_description']),
      ));
      return null;
    }
  }

  void _addTodoItem(TodoItem todoItem) async {
    final auth = AuthProvider.of(context).auth;
    String accessToken = await auth.getAccessTokenFromStorage();
    if(accessToken == null) {
      return;
    }
    final response = await http.post(
      widget.config.get('server_address') + '/api/item/write',
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

    if(response.statusCode == 200) {
      debugPrint(response.body);
      TodoItem newItem = new TodoItem.fromJson(json.decode(response.body));

      setState(() {
        items.add(newItem);
      });
    }
  }
  void _removeTodoItem(TodoItem todoItem) async {
    debugPrint("delete");
    final auth = AuthProvider.of(context).auth;
    String accessToken = await auth.getAccessTokenFromStorage();
    if(accessToken == null) {
      return;
    }
    final response = await http.delete(
      widget.config.get('server_address') + '/api/item/delete/${todoItem.id}',
      headers: {
        'Authorization' : 'Bearer ' + accessToken,
        'Accept': "application/json;charset=UTF-8",
      },
    ).catchError((error) {
      throw error;
    });

    if(response.statusCode == 200) {
      setState(() {
        items.remove(todoItem);
      });
    }
  }

  Future<TodoItem> _doneTodoItem(TodoItem todoItem, bool val) async {
    debugPrint("done");
    final auth = AuthProvider.of(context).auth;
    String accessToken = await auth.getAccessTokenFromStorage();
    if(accessToken == null) {
      return null;
    }
    final response = await http.post(
      widget.config.get('server_address') + '/api/item/modifyDone/${todoItem.id}',
      headers: {
        'Authorization' : 'Bearer ' + accessToken,
        'Content-Type': "application/json;charset=UTF-8",
        'Accept': "application/json;charset=UTF-8",
      },
      body: json.encode({
        'done': val,
      }),
    ).catchError((error) {
      throw error;
    });

    if(response.statusCode == 200) {
      debugPrint(response.body);
      return new TodoItem.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  void _changePosition(TodoItem todoItem) async {
    final auth = AuthProvider.of(context).auth;
    String accessToken = await auth.getAccessTokenFromStorage();
    if (accessToken == null) {
      return;
    }

    final response = await http.post(
      widget.config.get('server_address') + '/api/item/modifyPosition/${todoItem.id}',
      headers: {
        'Authorization': 'Bearer ' + accessToken,
        'Content-Type': "application/json;charset=UTF-8",
        'Accept': "application/json;charset=UTF-8",
      },
      body: json.encode({
        'position': todoItem.position,
      }),
    ).catchError((error) {
      throw error;
    });

    debugPrint(response.body);
  }

  void onReorder(int oldIndex, int newIndex) {
    debugPrint('oldIdx : $oldIndex newIndex : $newIndex');
    debugPrint('old($oldIndex): ${items[oldIndex].content}-${items[oldIndex].position}');
    if(newIndex > oldIndex) {
      debugPrint('new-1($newIndex): ${items[newIndex-1].content}-${items[newIndex-1].position}');
    } else {
      debugPrint('new($newIndex): ${items[newIndex].content}-${items[newIndex].position}');
    }

    double position = 0.0;
    double a, b = 0.0;
    if(newIndex == 0) { //1.맨 앞으로
      a = 0.0;
      b = items[newIndex].position;
    } else if(newIndex == items.length) { //2.맨 뒤로
      if(items[oldIndex].position == items[newIndex-1].position) { //맨뒤에서 맨뒤로 옮길 시 무시
        return null;
      }
      a = items[newIndex-1].position;
      b = (a/1000 + 1).floorToDouble() * 1000;
    } else { //3.사이로
      a = items[newIndex-1].position;
      b = items[newIndex].position;
    }
    debugPrint('a: $a, b: $b');
    position = a - (a - b) / 2;
    debugPrint(position.toString());

    TodoItem item = items[oldIndex];

    setState(() {
      item.position = position;
      items.removeAt(oldIndex);
      items.insert(newIndex > oldIndex ? newIndex - 1: newIndex, item);
    });

    _changePosition(item);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              Expanded(
                child: TodoItemList(
                  items: items,
                  onDeletePressed: _removeTodoItem,
                  onCheckBoxPressed: _doneTodoItem,
                  onReorder: onReorder,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _showInputModalBottomSheet(context);
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).primaryColor,
            shape: const CircularNotchedRectangle(),
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
              child: Row(
                children: [
                  IconButton(
                      tooltip: '메뉴',
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _showMenuModalBottomSheet(context);
                      }
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }

  void _showMenuModalBottomSheet(BuildContext context) {
    final auth = AuthProvider.of(context).auth;

    showModalBottomSheet<void>(
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                enabled: true,
                title: Text('SIGN OUT'),
                onTap:(() {
                  auth.removeAccessTokenFromStorage().then((bool) {
                    if(bool) {
                      Navigator.pushNamedAndRemoveUntil(context, '/sign_in', (Route<dynamic> route) => false);
                    }
                  });
                }),
              ),
              ListTile(
                enabled: true,
                title: Text('refreshToken'),
                onTap:(() {
                  refreshTest();
                }),
              ),
            ],
          )
        );
      },
    );
  }

  void _showInputModalBottomSheet(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController();

    submit(String where) {
      final String input = _textEditingController.text.trim();

      if(input == '') {
        return;
      }

      _addTodoItem(new TodoItem(content: input, done: false));
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
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: '무엇을 할건가요?',
                      border: InputBorder.none,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
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
}
class TodoItemList extends StatelessWidget {
  final List<TodoItem> items;
  final Function onDeletePressed;
  final Function onCheckBoxPressed;
  final ReorderCallback onReorder;

  const TodoItemList({
    Key key,
    @required this.items,
    @required this.onDeletePressed,
    @required this.onCheckBoxPressed,
    @required this.onReorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
        children: [
          for (final item in items)
            Container(
              key: UniqueKey(),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                        color: Colors.black26,
                        width: 1.0,
                      )
                  )
              ),
              child: StatefulBuilder(builder: (context, setState) {
                return new CheckboxListTile(
                    title: new Text('${item.content}'),
                    value: item.done != null ? item.done : false,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool val) {
                      Future<TodoItem> f = onCheckBoxPressed(item, val);
                      f.then((changedItem) {
                        setState(() {
                          item.done = changedItem.done;
                        });
                      });
                    },
                    secondary: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        onDeletePressed(item);
                      },
                    )
                );
              }),
            )
        ],
        onReorder: onReorder,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(width: 30);
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                      child: SizedBox(
                          height: 80
                      )
                  ),
                  spacing,
                  Text(
                      'Handa',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ],
              ),
            ]
        )
    );
  }
}