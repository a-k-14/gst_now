import 'dart:io'; // To create a PDF file at the path
import 'package:gst_calc/gst_calculation_item.dart';
import 'package:path_provider/path_provider.dart'; // To get the document stored path
import 'package:pdf/pdf.dart'; // To create PDF
import 'package:pdf/widgets.dart' as pw; // To use widgets to create PDF
import 'package:open_file/open_file.dart'; // To open the PDF file in the platform native viewer

// Function to create a PDF
// We moved it to a new dart file to reduce clutter in gst_summary.dart where this is called
void createPDF(List<GSTCalcItem> gstCalcItemsList, Totals totals) async {
  // We create a PDF object to create PDF
  final pdfGSTDataTable = pw.Document(author: 'GST Now/ar');

  // To generate the GST Amount & CGST & SGST/IGST amount displays
  pw.Widget gstAmount(int index) {
    return pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('${gstCalcItemsList[index].gstAmount}'),
          pw.SizedBox(height: 5),
          gstCalcItemsList[index].gstBreakupOperator == 'IGST'
              ? pw.Text(
                  'IGST: ${gstCalcItemsList[index].gstAmount}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                )
              : pw.Column(
                  children: [
                    pw.Text(
                      'CGST: ${gstCalcItemsList[index].csgstAmount}',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      'SGST: ${gstCalcItemsList[index].csgstAmount}',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
        ]);
  }

  // To return the GST DataTable to be displayed in the invoice
  // Since the data property takes only a list of Strings, we have edited table.dart file as follows
  // At rows 341 & 364, we made the child property as cell instead of Text widget
  pw.Widget gstDataTable() {
    final tableRows = List.generate(
      gstCalcItemsList.length,
      (index) {
        return [
          pw.Text('${index + 1}'),
          pw.Text('${gstCalcItemsList[index].details}'),
          pw.Text('${gstCalcItemsList[index].netAmount}'),
          pw.Text('${gstCalcItemsList[index].gstRate}%'),
          gstAmount(index),
          pw.Text('${gstCalcItemsList[index].totalAmount}'),
        ];
      },
    );

    tableRows.add([
      pw.Text(''),
      pw.Text(
        'Total',
        style: pw.TextStyle(
            color: PdfColor.fromInt(0xff0050ab),
            fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        '${totals.tAmountString(1)}',
        style: pw.TextStyle(
            color: PdfColor.fromInt(0xff0050ab),
            fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(''),
      // gstAmount
      pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            totals.tAmountString(2),
            style: pw.TextStyle(
                color: PdfColor.fromInt(0xff0050ab),
                fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          // To check for CGST&SGST/IGST and display accordingly
          pw.Column(
            children: [
              pw.Text(
                'CGST: ${totals.tAmountString(3)}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                'SGST: ${totals.tAmountString(3)}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                'IGST: ${totals.tAmountString(4)}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ],
      ),
      pw.Text(
        '${totals.tAmountString(5)}',
        style: pw.TextStyle(
            color: PdfColor.fromInt(0xff0050ab),
            fontWeight: pw.FontWeight.bold),
      ),
    ]);

    return pw.Table.fromTextArray(
      // Column headers of the table
      headers: ['No.', 'Details', 'Net Amount', 'Rate ', 'GST Amount', 'Total'],
      // Rows of the table
      data: tableRows,
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(
          color: PdfColors.grey200,
          width: 1,
        ),
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      headerHeight: 30,
      // To ensure all columns are properly displayed when there is long details
      columnWidths: {
        // 0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(1),
        // 3: pw.FlexColumnWidth(1),
        4: pw.FlexColumnWidth(1),
        5: pw.FlexColumnWidth(1),
      },
      headerAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      // To ensure proper alignment of No., text & number columns
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  /* pw.Widget test() {
    final data = List.generate(gstCalcItemsList.length, (index) {
      return pw.TableRow(children: [
        pw.Expanded(
          flex: 1,
          child: pw.Text('${index + 1}'),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text('${gstCalcItemsList[index].details}'),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text('${gstCalcItemsList[index].netAmount}'),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text('${gstCalcItemsList[index].gstRate}'),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text('${gstCalcItemsList[index].gstAmount}'),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text('${gstCalcItemsList[index].totalAmount}'),
        ),
      ]);
    });

    final headers = [
      'No.',
      'Details',
      'Net Amount',
      'Rate',
      'GST Amount',
      'Total Amount'
    ];
    data.insert(
      0,
      pw.TableRow(
        children: List.generate(
          headers.length,
          (index) {
            return pw.Container(
              alignment: pw.Alignment.center,
              padding: pw.EdgeInsets.all(5),
              constraints: pw.BoxConstraints(minHeight: 0),
              child: pw.Text(
                '${headers[index]}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            );
            //   pw.Container(
            //   padding: pw.EdgeInsets.all(8),
            //   alignment: pw.Alignment.center,
            //   child: pw.Text('${headers[index]}',
            //       style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            // );
          },
        ),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(8),
        ),
      ),
    );
    return pw.Table(children: data);
  }*/

  // Adding data to the PDF
  pdfGSTDataTable.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(64),
      build: (pw.Context context) {
        return [
          pw.Header(
            level: 0,
            child: pw.Text(
              'GST Calculation',
              style: pw.TextStyle(color: PdfColor.fromInt(0xff0050ab)),
            ),
          ),
          gstDataTable(),
          // test(),
        ];
      },
    ),
  );

  // To get the current directory where the file will be saved
  var documentDirectory = await getApplicationDocumentsDirectory();

  File pdfFile = File('${documentDirectory.path}/test.pdf');

  // Writing the data into the PDF file
  await pdfFile.writeAsBytes(await pdfGSTDataTable.save());

  // Opening the PDF file
  await OpenFile.open(pdfFile.path);
}
