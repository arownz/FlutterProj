import 'package:flutter/material.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Task Title')),
            TextField(
                decoration: InputDecoration(labelText: 'Task Description')),
            ElevatedButton(
              child: Text('Add Task'),
              onPressed: () {
                // Implement add task logic here
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
