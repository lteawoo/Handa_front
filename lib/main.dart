import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContent();
      }
    );
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
          Card(
            key: ValueKey(item.no),
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
              );
            }),
          )
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

class _BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: <Widget>[
        ],
      )
    );
  }
}

/*class _TodoItemListState extends State<TodoItemListWidget> {
  @override
  Widget build(BuildContext context) {
    return new DragAndDropList<TodoItem>(
      widget.items,
      itemBuilder: (BuildContext context, item) {
        return Card(
          child: new Container(
            padding: new EdgeInsets.all(5.0),
            child: new Column(
              children: <Widget>[
                new CheckboxListTile(
                  title: new Text(item.content),
                  value: item.done,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool val) {
                    setState(() {
                      item.done = val;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
      onDragFinish: (before, after) {
        TodoItem item = widget.items[before];
        widget.items.removeAt(before);
        widget.items.insert(after, item);
      },
      canBeDraggedTo: (one, two) => true,
      dragElevation: 8.0,
    );
  }
}*/

/*
class _TodoItemListState extends State<TodoItemListWidget> with TickerProviderStateMixin {
  Widget buildRow(int index) {
    final TodoItem item = widget.items[index];

    Card card = new Card(
        child: new Container(
            padding: new EdgeInsets.all(5.0),
            child: new Column(
              children: <Widget>[
                new CheckboxListTile(
                  title: Column(
                    children: <Widget>[
                      new Text(item.content),
                      new Text(index.toString()),
                    ],
                  ),
                  value: item.done,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool val) {
                    setState(() {
                      item.done = val;
                    });
                  },
                )
              ],
            )
        )
    );

    Draggable draggable = new LongPressDraggable<TodoItem>(
      data: item,
      axis: Axis.vertical,
      maxSimultaneousDrags: 1,
      child: card,
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: card,
      ),
      feedback: Material(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery
                  .of(context)
                  .size
                  .width
          ),
          child: card,
        ),
        elevation: 4.0,
      ),
    );

    return DragTarget<TodoItem>(
      onWillAccept: (item) {
        debugPrint("onwillaccept, index " + index.toString() + " item " + item.content.toString() + " yes? " + (widget.items.indexOf(item) != index).toString());
        return widget.items.indexOf(item) != index;
      },
      onAccept: (item) {
        debugPrint("onAccept, index " + index.toString() + " item " + item.toString());
        setState(() {
          int currentIndex = widget.items.indexOf(item);

          debugPrint(currentIndex.toString());

          widget.items.remove(item);
          widget.items.insert(currentIndex > index ? index : index - 1, item);
        });
      },
      builder: (BuildContext buildContext, List<TodoItem> candidateData, List<dynamic> rejectedData) {
        return Column(
          children: <Widget>[
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              vsync: this,
              child: candidateData.isEmpty ? Container() : Opacity(
                opacity: 0.0,
                child: card,
              ),
            ),
            Container(
              child: candidateData.isEmpty ? draggable : card,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) => buildRow(index),
    );
  }
}*/

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