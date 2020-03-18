import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class TodoItem {
  int no;
  String content;
  bool done;

  TodoItem({
    this.no,
    this.content,
    this.done,
  });
}

class MyApp extends StatelessWidget {
  void _showModalBottomSheet(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    submit() {
      final String input = _controller.text;
      debugPrint('submit, you typed $input');
    }

    /*
     * TODO TextField 이벤트 처리 1.입력 후 엔터, 2.입력 후 모달 닫음(드래그로 닫아도 해당됨), 3.입력 후 등록버튼 클릭
     * TODO 줄내림해야함. textfield가 아닌건가..
     */
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
                RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) {
                    if(event is RawKeyUpEvent) {
                      debugPrint(event.data.keyLabel);
                      if(event.logicalKey == LogicalKeyboardKey.enter) {
                        submit();
                      } else if (event.data is RawKeyEventDataWeb) {
                        final data = event.data as RawKeyEventDataWeb;
                        if (data.keyLabel == 'Enter') {
                          submit();
                        }
                      } else if (event.data is RawKeyEventDataAndroid) {
                        final data = event.data as RawKeyEventDataAndroid;
                        if (data.keyCode == 13) {
                          submit();
                        }
                      }
                    }
                  },
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 3,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '123',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (String value) async {
                      if(value == '') {
                        return;
                      }
                      debugPrint('you typed $value');
                      Navigator.pop(context);
                    },
        /*                  onChanged: (String value) async {
                              *//*for(int i in value.codeUnits) {
                                debugPrint('typed : ' + i.toString());
                              }*//*
                              if(value.contains('\n')) {
                                debugPrint('typed : enter');
        //                        Navigator.pop(context);
                              }
                          },*/
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
                            if(_controller.value.toString() == '') {
                              return;
                            }
                            debugPrint('you typed ${_controller.value.text}');
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
      if(_controller.value.toString() == '') {
        return;
      }
      debugPrint('when complete, you typed ${_controller.value.text}');
      debugPrint('닫힘');
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TodoItem> list = [];

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
      home: Scaffold(
        appBar: AppBar(
          title: Text('Handa'),
        ),
        body: Center(
          child: TodoItemListWidget(
            items: list,
          )
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _showModalBottomSheet(context);
            },
          ),
        ),
      )
    );
  }
}

class TodoItemCard extends StatelessWidget {
  final TodoItem todoItem;

  const TodoItemCard({
    Key key,
    this.todoItem
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
   return Card(
      key: key,
      child: StatefulBuilder(builder: (context, setState) {
        return new CheckboxListTile(
          title: new Text(todoItem.content),
          value: todoItem.done,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool val) {
            setState(() {
              todoItem.done = val;
            });
          },
        );
      }),
    );
  }
}

class TodoItemListWidget extends StatefulWidget {
  final List<TodoItem> items;
  const TodoItemListWidget({
    Key key,
    this.items,
  }) : super(key: key);

  @override
  _TodoItemListState createState() => _TodoItemListState();
}

class _TodoItemListState extends State<TodoItemListWidget> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: [
        for (final item in widget.items)
          TodoItemCard(key: UniqueKey(), todoItem: item)
      ],
      onReorder: (oldIndex, newIndex) {
        setState(() {
          debugPrint('oldIndex : ' + oldIndex.toString() + ' nexIndex : ' + newIndex.toString());
          TodoItem item = widget.items[oldIndex];
          for(TodoItem item in widget.items) {
            debugPrint(item.content);
          }
          widget.items.removeAt(oldIndex);
          widget.items.insert(newIndex > oldIndex ? newIndex - 1: newIndex, item);
        });
      }
    );
  }
}