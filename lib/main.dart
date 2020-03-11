import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handa',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Handa'),
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <TodoItem>[
              TodoItem(
                id:1,
                content:'딸기 먹자',
                done:false,
              ),
              TodoItem(
                id:2,
                content:'바나나 먹자',
                done:true,
              ),
            ],
          ),
        ),
      )
    );
  }
}

/*
class TodoItem extends StatelessWidget {
  const TodoItem({
    Key key,
    this.id,
    this.content,
    this.done,
  }) : super(key: key);

  final int id;
  final String content;
  final bool done;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!done);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
            children: <Widget>[
              Checkbox(
                value: done,
                onChanged: (bool newValue) {
                  onChanged(newValue);
                },
              ),
              Expanded(child: Text(
                  content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                  ))
              ),
            ]
        ),
      ),
    );
  }
}*/

class TodoItemWidget extends StatefulWidget {
  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItemWidget> {
  _TodoItemState({
    this.id,
    this.content,
    this.done,
  });
  final int id;
  String content;
  bool done;

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Container(
        padding: new EdgeInsets.all(5.0),
        child: new Column(
          children: <Widget>[
            new CheckboxListTile(
              value: this.done,
              title: new Text(this.content),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool val) {
                setState(() {
                  this.done = val;
                });
              },
            )
          ],
        )
      )
    )
  }
}

class TodoItemListWidget extends StatefulWidget {
  TodoItemListWidget({Key key}) : super(key: key);

  @override
  _TodoItemListState createState() => _TodoItemListState();
}

class _TodoItemListState extends State<TodoItemListWidget> {
  List<_TodoItemState> items = new List<_TodoItemState>();

  @override
  void initState() {
    setState(() {
      items.add(new TodoItem(id: 1, content: '딸기를 먹자', done: false));
      items.add(new TodoItem(id: 2, content: '사과를 먹자', done: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return
      },
    );
  }
}

class TodoItem {
  TodoItem({
    this.id,
    this.content,
    this.done
  });
  int id;
  String content;
  bool done;
}