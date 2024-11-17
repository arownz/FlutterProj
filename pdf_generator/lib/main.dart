import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf_generator/path_provider/path_provider.dart';
import 'package:pdf_generator/pdf/pdf.dart';
import 'package:pdf_generator/pdf/widgets.dart' as pw;
import 'package:pdf_generator/flutter_pdfview/pdf_preview_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
