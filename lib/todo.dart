import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class TodoItemListWidget extends StatefulWidget {
  @override
  _TodoItemListState createState() => _TodoItemListState();
}

class _TodoItemListState extends State<TodoItemListWidget> {
  final List<TodoItem> items = [];
  bool started = true;

  @override
  void initState() {
    debugPrint('init');
    super.initState();

    swapList();
    _startTimer();
  }


  @override
  void dispose() {
    super.dispose();
    started = false;
  }

  void swapList() {
    //todo progress widget 구현해야함
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
        swapList();
      } else {
        timer.cancel();
      }
    });
  }

  Future<String> _getAccessTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<List<TodoItem>> _fetchItems() async {
    String accessToken = await _getAccessTokenFromStorage();
    if(accessToken == null) {
      return null;
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

  Future<TodoItem> _fetchItem() async {
    String accessToken = await _getAccessTokenFromStorage();

    final response = await Future.delayed(Duration(milliseconds: 2000));

    return new TodoItem(id: 1, content: 'test');
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
    TodoItem newItem = new TodoItem.fromJson(json.decode(response.body));

    if(response.statusCode == 200) {
      setState(() {
        items.add(newItem);
      });
    }
  }

  void _deleteTodoItem(TodoItem todoItem) {
    setState(() {
     items.remove(todoItem);
    });
  }

  void _changePosition(TodoItem todoItem) async {
    String accessToken = await _getAccessTokenFromStorage();
    if(accessToken == null) {
      return;
    }

    final response = await http.post(
      'http://localhost:8080/api/item/modifyPosition/${todoItem.id}',
      headers: {
        'Authorization' : 'Bearer ' + accessToken,
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

  @override
  Widget build(BuildContext context) {
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
                    title: new Text('${item.content} : ${item.position}'),
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
                        child: Text('아이템목록'),
                        onPressed: () {
                          setState(() {
                            _fetchItems();
                          });
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
}