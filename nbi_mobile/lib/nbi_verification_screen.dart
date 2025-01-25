import 'package:flutter/material.dart';
import 'nbi_header.dart';

class NbiVerificationScreen extends StatefulWidget {
  const NbiVerificationScreen({super.key});

  @override
  _NbiVerificationScreenState createState() => _NbiVerificationScreenState();
}

class _NbiVerificationScreenState extends State<NbiVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  // Update dialog to show input
  void _showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('Verification Result'),
        content: Text('Reference Number: ${_controller.text}\n$message'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: Column(
        children: [
          NbiHeader(showBackButton: true),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter NBI Reference Number',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter reference number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.yellow, width: 2),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showValidationDialog('Verification successful');
                      }
                    },
                    child: Text(
                      'VERIFY',
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
