import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: ListView.builder(
        itemCount: 10, // Replace with actual task count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Task ${index + 1}'),
            trailing: Checkbox(value: false, onChanged: (bool? value) {}),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
      ),
    );
  }
}
