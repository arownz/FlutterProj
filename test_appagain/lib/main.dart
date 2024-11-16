import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_task_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaaS Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/tasks': (context) => const TaskListScreen(),
        '/add_task': (context) => const AddTaskScreen(),
      },
    );
  }
}

