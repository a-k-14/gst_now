import 'dart:io'; // To create a PDF file at the path
import 'package:path_provider/path_provider.dart'; // To get the document stored path
import 'package:pdf/pdf.dart'; // To create PDF
import 'package:pdf/widgets.dart' as pw; // To use widgets to create PDF
import 'package:native_pdf_view/native_pdf_view.dart' as po;
import 'package:open_file/open_file.dart';

void createPDF() async {
  // We create a PDF object to create PDF
  final pdf = pw.Document(author: 'GST Now');

// Function to write data to PDF document

  pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Text('Hi'),
          ),
        ];
      }));

  var documentDirectory = await getApplicationDocumentsDirectory();

  String documentPath = documentDirectory.path;
  print('path is - $documentPath');

  File file = File('$documentPath/test.pdf');

  await file.writeAsBytes(await pdf.save());

  // po.PdfController pdfController =
  //     po.PdfController(document: po.PdfDocument.openAsset(file.path));
  //
  // po.PdfView(
  //   controller: pdfController,
  // );

  // Share.shareFiles([file.path]);
  await OpenFile.open(file.path);
}
