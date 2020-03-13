import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<TodoItemWidget> list = [];

    list.add(new TodoItemWidget(
      id: 1,
      content: '딸기를 먹자',
      done: false,
    ));

    list.add(new TodoItemWidget(
      id: 2,
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
      )
    );
  }
}

class TodoItemWidget extends StatefulWidget {
  final int id;
  String content;
  bool done;

  TodoItemWidget({
    Key key,
    this.id,
    this.content,
    this.done
  }): super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItemWidget> {
  @override
  Widget build(BuildContext context) {
    Card card = new Card(
        child: new Container(
            padding: new EdgeInsets.all(5.0),
            child: new Column(
              children: <Widget>[
                new CheckboxListTile(
                  value: widget.done,
                  title: new Text(widget.content),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool val) {
                    setState(() {
                      widget.done = val;
                    });
                  },
                )
              ],
            )
        )
    );

    return new LongPressDraggable(
      child: card,
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: card,
      ),
      feedback: Material(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          child: card,
        ),
      ),
    );
  }
}

class TodoItemListWidget extends StatefulWidget {
  final List<TodoItemWidget> items;
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
    return new ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        return widget.items[index];
      },
    );
  }
}