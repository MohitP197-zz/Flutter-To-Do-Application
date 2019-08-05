import 'package:flutter/material.dart';
import 'package:todoapp/model/todo_item.dart';
import 'package:todoapp/util/database_client.dart';
import 'package:todoapp/util/date_formatter.dart';

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

    ToDoItem toDoItem = new ToDoItem(text, dateFormatted());
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
                      onLongPress: () => _updateItem(_itemList[index], index),
                      trailing: Listener(
                          key: Key(_itemList[index].itemName),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                          ),
                          onPointerDown: (pointerEvent) {
                            // pass object which is get from going to list and passing it through the index
                            _deleteToDo(_itemList[index].id, index);
                            _deletedSuccessfullySnackBar(context);
                          }),
                    ),
                  );
                }),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          isExtended: true,
          tooltip: "Add Item",
          backgroundColor: Colors.deepOrangeAccent,
          icon: Icon(Icons.add),
          label: Text('New Task', textScaleFactor: 1.0),
          onPressed: _showFormDialog),
    );
  }

  void _deletedSuccessfullySnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Task deleted successfully"),
      duration: Duration(seconds: 3),
    ));
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
            _addedSuccessfullySnackBar();
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

  void _addedSuccessfullySnackBar() {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Task added successfully"),
      duration: Duration(seconds: 3),
    ));
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

  _updateItem(ToDoItem item, int index) {
    var alert = new AlertDialog(
      title: Text("Update Task"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autocorrect: true,
              decoration: InputDecoration(
                  labelText: "Task",
                  hintText: "Update the task",
                  icon: Icon(Icons.update)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () async {
            ToDoItem newItemUpdated = ToDoItem.fromMap({
              "itemName": _textEditingController.text,
              "dateCreated": dateFormatted(),
              "id": item.id
            });

            _handleUpdated(index, item); //redrawing the screen
            await db.updateItem(newItemUpdated); //updating the task
            setState(() {
              _readToDoList(); //redrawing the screen with all items saved in the db
            });
            _textEditingController.clear();
            Navigator.pop(context);
            _updatedSuccessfullySnackBar();
          },
          child: Text("Update"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _updatedSuccessfullySnackBar() {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Task updated successfully"),
      duration: Duration(seconds: 3),
    ));
  }

  void _handleUpdated(int index, ToDoItem item) {
    setState(() {
      _itemList.removeWhere((element) {
        _itemList[index].itemName == item.itemName;
      });
    });
  }
}
