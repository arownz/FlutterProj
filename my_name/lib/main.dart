import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();

  // Alternatively, you can make the class private and expose a factory constructor or a static method:
  //
  // static MainApp create() {
  //   return MainApp();
  // }
}

class _MainAppState extends State<MainApp> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Submit'),
              ),
              Text('My Name is ${_controller.text}'),
            ],
          ),
        ),
      ),
    );
  }
}
