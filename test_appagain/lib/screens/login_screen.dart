import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Email')),
            TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            ElevatedButton(
              child: Text('Login'),
              onPressed: () {
                // Implement login logic here
                Navigator.pushReplacementNamed(context, '/tasks');
              },
            ),
          ],
        ),
      ),
    );
  }
}
