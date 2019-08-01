import 'package:flutter/material.dart';
import 'package:todoapp/ui/todo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do Application"),
        backgroundColor: Colors.black54,
      ),
      body: ToDoScreen(),
      
    );
  }
}