import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_generator/flutter_pdfview/pdf_preview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final pdf = pw.Document();

  MyApp({super.key});

  void writeOnPdf() {
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Header(
              level: 0,
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    pw.Text('GeeksforGeeks', textScaleFactor: 2),
                  ])),
          pw.Header(level: 1, text: 'What is Lorem Ipsum?'),
          pw.Paragraph(text: '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod 
tempor incididunt ut labore et dolore magna aliqua. Nunc mi ipsum faucibus 
vitae aliquet nec. Nibh cras pulvinar mattis nunc sed blandit libero 
volutpat. Vitae elementum curabitur vitae nunc sed velit. Nibh tellus 
molestie nunc non blandit massa. Bibendum enim facilisis gravida neque. 
Arcu cursus euismod quis viverra nibh cras pulvinar mattis. Enim diam 
vulputate ut pharetra sit. Tellus pellentesque eu tincidunt tortor 
aliquam nulla facilisi cras fermentum.
'''),
          pw.Paragraph(text: '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod 
tempor incididunt ut labore et dolore magna aliqua. Nunc mi ipsum faucibus 
vitae aliquet nec. Nibh cras pulvinar mattis nunc sed blandit libero 
volutpat. Vitae elementum curabitur vitae nunc sed velit. Nibh tellus 
molestie nunc non blandit massa. Bibendum enim facilisis gravida neque. 
Arcu cursus euismod quis viverra nibh cras pulvinar mattis. Enim diam 
vulputate ut pharetra sit. Tellus pellentesque eu tincidunt tortor 
aliquam nulla facilisi cras fermentum.
'''),
          pw.Header(level: 1, text: 'This is Header'),
          pw.Paragraph(text: '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod 
tempor incididunt ut labore et dolore magna aliqua. Nunc mi ipsum faucibus 
vitae aliquet nec. Nibh cras pulvinar mattis nunc sed blandit libero 
volutpat. Vitae elementum curabitur vitae nunc sed velit. Nibh tellus 
molestie nunc non blandit massa. Bibendum enim facilisis gravida neque. 
Arcu cursus euismod quis viverra nibh cras pulvinar mattis. Enim diam 
vulputate ut pharetra sit. Tellus pellentesque eu tincidunt tortor 
aliquam nulla facilisi cras fermentum.
'''),
          pw.Paragraph(text: '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod 
tempor incididunt ut labore et dolore magna aliqua. Nunc mi ipsum faucibus 
vitae aliquet nec. Nibh cras pulvinar mattis nunc sed blandit libero 
volutpat. Vitae elementum curabitur vitae nunc sed velit. Nibh tellus 
molestie nunc non blandit massa. Bibendum enim facilisis gravida neque. 
Arcu cursus euismod quis viverra nibh cras pulvinar mattis. Enim diam 
vulputate ut pharetra sit. Tellus pellentesque eu tincidunt tortor 
aliquam nulla facilisi cras fermentum.
'''),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
          pw.TableHelper.fromTextArray(
              context: context,
              data: const <List<String>>[
                <String>['Year', 'Sample'],
                <String>['SN0', 'GFG1'],
                <String>['SN1', 'GFG2'],
                <String>['SN2', 'GFG3'],
                <String>['SN3', 'GFG4'],
              ]),
        ];
      },
    ));
  }

  Future<void> savePdf() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String documentPath = documentDirectory.path;
    File file = File('$documentPath/example.pdf');

    Uint8List pdfData = await pdf.save();

    await file.writeAsBytes(pdfData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GeeksforGeeks"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                child: const Text(
                  'Preview PDF',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                onPressed: () async {
                  writeOnPdf();
                  await savePdf();

                  Directory documentDirectory =
                      await getApplicationDocumentsDirectory();

                  String documentPath = documentDirectory.path;

                  String fullPath = "$documentPath/example.pdf";
                  print(fullPath);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PdfPreviewScreen(
                                path: fullPath,
                              )));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
