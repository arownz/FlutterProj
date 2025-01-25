import 'package:flutter/material.dart';
import 'nbi_verification_screen.dart';
import 'jobseeker_registration_screen.dart';
import 'nbi_header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: SingleChildScrollView(
        child: Column(
          children: [
            NbiHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    'NBI CLEARANCE eSERVICES',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      side: BorderSide(color: Colors.yellow, width: 2),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NbiVerificationScreen()),
                    ),
                    child: Text(
                      'NBI CLEARANCE ONLINE VERIFICATION',
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'GOOD NEWS! You can now check NBI Clearance authenticity and validity',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      side: BorderSide(color: Colors.yellow, width: 2),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobseekerRegistrationScreen()),
                    ),
                    child: Text(
                      'FIRST TIME JOBSEEKERS',
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'In Compliance with Republic Act No. 112621, also known as the "First Time Jobseekers Assistance Act"',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
