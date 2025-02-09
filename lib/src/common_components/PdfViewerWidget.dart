import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerWidget extends StatefulWidget {
  final List<int> pdfBytes;
  final double? height;
  final double? width;

  const PdfViewerWidget({
    super.key,
    required this.pdfBytes,
    this.height,
    this.width,
  });

  @override
  _PdfViewerWidgetState createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  late PdfControllerPinch pdfController;

  @override
  void initState() {
    super.initState();
    pdfController = PdfControllerPinch(
      document: PdfDocument.openData(Uint8List.fromList(widget.pdfBytes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Set desired height
      width: 600, // Set desired width
      decoration: BoxDecoration(border: Border.all(color: Colors.black)), child: PdfViewPinch(controller: pdfController),
    );
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }
}
