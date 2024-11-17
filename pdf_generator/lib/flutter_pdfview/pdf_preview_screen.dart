import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String path;

  const PdfPreviewScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        
      ),
      body: kIsWeb
          ? _buildWebPdfViewer()
          : PDFView(
              filePath: path,
            ),
    );
  }

  Widget _buildWebPdfViewer() {
    return Center(
      child: ElevatedButton(
        child: const Text('Open PDF'),
        onPressed: () {
          // Open the PDF in a new tab
          // ignore: undefined_prefixed_name
          // js.context.callMethod('open', [path, '_blank']);
        },
      ),
    );
  }
}
