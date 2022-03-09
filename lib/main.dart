import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfustion_pdf/draggable.dart';
import 'package:syncfustion_pdf/helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Syncfustion flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String widgetName = "";
  void updateName(String name) {
    debugPrint("on accept");
    setState(() {
      widgetName = name;
    });
  }

  File? pdfFile;
  Future<void> createSimplePdfDocument() async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();
    // Add a PDF page and draw text.
    document.pages.add().graphics.drawString(
        'Hello World!', PdfStandardFont(PdfFontFamily.helvetica, 12),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: const Rect.fromLTWH(500, 500, 300, 20));
    //Save and dispose the document.
    final List<int> bytes = document.save();
    document.dispose();

    final file = await FileSaveHelper.writeFile(bytes, 'input.pdf');
    setState(() {
      pdfFile = file;
    });
  }

  Future createSimplePdfWithImage() async {
    final PdfDocument pdfDocument = PdfDocument();
    ByteData imageData = await rootBundle.load('assets/images/emc.png');
    final PdfBitmap image = PdfBitmap(imageData.buffer.asUint8List());
    pdfDocument.pages
        .add()
        .graphics
        .drawImage(image, const Rect.fromLTWH(0, 0, 500, 200));
    List<int> bytes = pdfDocument.save();
    final file = await FileSaveHelper.writeFile(bytes, 'ImageToPdf.pdf');
    setState(() {
      pdfFile = file;
    });
  }

  Future<void> modifyPdfWithImage(double left, double top) async {
    final PdfDocument pdfDocument = PdfDocument(
        inputBytes: await rootBundle
            .load('assets/PDFs/book.pdf')
            .then((value) => value.buffer.asUint8List()));

    PdfPage page = pdfDocument.pages[0];
    ByteData imageData = await rootBundle.load('assets/images/emc.png');
    final PdfBitmap image = PdfBitmap(imageData.buffer.asUint8List());

    page.graphics.drawImage(
        image, Rect.fromLTWH(left + (100 / 2), top + (100 / 2), 100, 100));
    List<int> bytes = pdfDocument.save();
    pdfDocument.dispose();
    final file = await FileSaveHelper.writeFile(bytes, 'output.pdf');
    setState(() {
      pdfFile = file;
    });
  }

  Future<void> modifyPdfWithSignature(double left, double top) async {
    //Create a new PDF document.
    PdfDocument document = PdfDocument(
      inputBytes: await rootBundle.load('assets/PDFs/book_signature.pdf').then(
        (value) {
          debugPrint(value.buffer.asUint8List().toString());
          return value.buffer.asUint8List();
        },
      ),
    );
    await Future.delayed(const Duration(milliseconds: 3000));
    debugPrint(document.form.fields.count.toString());
    //Get the signature field.
    if (document.form.fields.count > 0) {
      debugPrint(document.form.fields.count.toString());
      PdfSignatureField signatureField =
          document.form.fields[0] as PdfSignatureField;
      //Create signature field.
      signatureField.signature = PdfSignature(
        certificate: PdfCertificate(
          await rootBundle.load('assets/PFXs/localhost.pfx').then(
                (value) => value.buffer.asUint8List(),
              ),
          '123456',
        ),
      );

      document.form.fields.add(signatureField);

      List<int> bytes = document.save();
      document.dispose();
      final file = await FileSaveHelper.writeFile(bytes, 'output.pdf');
      setState(() {
        pdfFile = file;
      });
    }
  }
  // void readImageData() async {
  //   ByteData byteData = await rootBundle.load('assets/images/emc.png');
  //   debugPrint(byteData.buffer.);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Draggable<String>(
                  data: "Osama",
                  child: const Text(
                    'Drag',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  feedback: Container(
                    color: const Color.fromARGB(255, 226, 216, 216),
                    width: 100,
                    height: 100,
                  ),
                  childWhenDragging: const Text('child when dragging'),
                ),
                DragTarget<String>(
                  builder: (context, candidateData, rejectedData) => Container(
                    color: Colors.yellow,
                    width: 200,
                    height: 50,
                    child: Text(widgetName),
                  ),
                  onWillAccept: (value) => value == 'Osama',
                  onAccept: (val) => updateName(val),
                )
              ],
            ),
          ),
          Expanded(
            child: pdfFile != null
                ? SfPdfViewer.file(pdfFile!)
                : SfPdfViewer.asset('assets/PDFs/book.pdf'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
