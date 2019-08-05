import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:todoapp/model/todo_item.dart';
import 'package:todoapp/util/database_client.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  var db = new DatabaseHelper();

  final List<ToDoItem> _itemList = <ToDoItem>[];

  @override
  void initState() {
    super.initState();

    _readToDoList();
  }

  void _handleSubmitted(String text) async {
    _textEditingController.clear();

    ToDoItem toDoItem = new ToDoItem(text, DateTime.now().toIso8601String());
    int savedItemId = await db.saveItem(toDoItem);

    ToDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });

    print("Item Saved of id: $savedItemId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: false,
                itemCount: _itemList.length,
                itemBuilder: (_, int index) {
                  return Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: _itemList[index],
                      onLongPress: () => debugPrint("Updating"),
                      trailing: Listener(
                        key: Key(_itemList[index].itemName),
                        child: Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                        ),
                        onPointerDown: (pointerEvent) =>
                            // pass object which is get from going to list and passing it through the index
                            _deleteToDo(_itemList[index].id, index),
                      ),
                    ),
                  );
                }),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: "Add Item",
          backgroundColor: Colors.deepOrangeAccent,
          child: ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialog),
    );
  }

  void _showFormDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Task",
              hintText: "Add a task",
              icon: Icon(Icons.note_add),
            ),
          )),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _handleSubmitted(_textEditingController.text);
            _textEditingController.clear();
            Navigator.pop(context);
          },
          child: Text("Add"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readToDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      // map is used as we are received these objects from list
      // ToDoItem toDoItem = ToDoItem.fromMap(item);
      setState(() {
        _itemList.add(ToDoItem.map(item));
      });
      // print("DB Items: ${toDoItem.itemName}");
    });
  }

  _deleteToDo(int id, int index) async {
    debugPrint("Deleted successfully");

    await db.deleteItem(id);

    setState(() {
      _itemList.removeAt(index);
    });
  }
}
