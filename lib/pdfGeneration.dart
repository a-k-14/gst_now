import 'dart:io'; // To create a PDF file at the path
import 'package:gst_calc/constants.dart';
import 'package:gst_calc/gst_calculation_item.dart';
import 'package:path_provider/path_provider.dart'; // To get the document stored path
import 'package:pdf/pdf.dart'; // To create PDF
import 'package:pdf/widgets.dart' as pw; // To use widgets to create PDF
import 'package:open_file/open_file.dart'; // To open the PDF file in the platform native viewer

// Function to create a PDF
// We try creating a PDF and then return the result in the form of a bool to show an error(SnackBar) when bool is false
// We moved it to a new dart file to reduce clutter in gst_summary.dart where this is called
Future<bool> createPDF(
    List<GSTCalcItem> gstCalcItemsList, Totals totals) async {
  // The result to be returned
  bool result;
  // We create a PDF object to create PDF
  final pdfGSTDataTable = pw.Document(author: 'GST Now/ar');

  PdfColor mainColor = PdfColor.fromInt(0xff0050ab);

  // TODO: Is this try catch block position correct
  try {
    // To return the main GST DataTable to be displayed in the invoice
    // Since the data property takes only a list of Strings, we have edited table.dart file as follows
    /// At rows 341 & 364, we made the child property as cell instead of Text widget
    pw.Widget gstDataTable() {
      // Constants to be used in table for customizations
      pw.TextStyle gstAmountDetailsStyle =
          pw.TextStyle(fontSize: 9, color: PdfColors.grey700);
      pw.TextStyle totalTextStyle =
          pw.TextStyle(color: mainColor, fontWeight: pw.FontWeight.bold);

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
                      style: gstAmountDetailsStyle,
                    )
                  : pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'CGST: ${gstCalcItemsList[index].csgstAmount}',
                          style: gstAmountDetailsStyle,
                        ),
                        pw.Text(
                          'SGST: ${gstCalcItemsList[index].csgstAmount}',
                          style: gstAmountDetailsStyle,
                        ),
                      ],
                    ),
            ]);
      }

      // We store the list in a variable so that we can add the Total row next and then consider it in table for rows
      final tableRows = List.generate(
        gstCalcItemsList.length,
        (index) {
          return [
            pw.Text('${index + 1}'),

            /// We added Expanded here as we were getting the below error though the rows do not need 20 pages
            // This widget created more than 20 pages. This may be an issue in the widget or the document
            // Probably that the columns are going beyond 1 page
            pw.Expanded(
              child: pw.Container(
                constraints: pw.BoxConstraints(
                  maxWidth: 150,
                ),
                child: pw.Text('${gstCalcItemsList[index].details}'),
              ),
            ),
            pw.Expanded(
              child: pw.Text('${gstCalcItemsList[index].netAmount}'),
            ),
            pw.Text('${gstCalcItemsList[index].gstRate}%'),
            pw.Expanded(
              child: gstAmount(index),
            ),
            pw.Expanded(
              child: pw.Text('${gstCalcItemsList[index].totalAmount}'),
            ),
          ];
        },
      );

      // Adding Total row to the rows list generated above
      tableRows.add(
        [
          pw.Text(''),
          pw.Text(
            'Total',
            style: totalTextStyle,
          ),
          pw.Text(
            '${totals.tAmountString(1)}',
            style: totalTextStyle,
          ),
          pw.Text(''),
          // gstAmount
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                totals.tAmountString(2),
                style: totalTextStyle,
              ),
              pw.SizedBox(height: 5),
              // To check for CGST&SGST/IGST and display accordingly
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'CGST: ${totals.tAmountString(3)}',
                    style: gstAmountDetailsStyle,
                  ),
                  pw.Text(
                    'SGST: ${totals.tAmountString(3)}',
                    style: gstAmountDetailsStyle,
                  ),
                  pw.Text(
                    'IGST: ${totals.tAmountString(4)}',
                    style: gstAmountDetailsStyle,
                  ),
                ],
              ),
            ],
          ),
          pw.Text(
            '${totals.tAmountString(5)}',
            style: totalTextStyle,
          ),
        ],
      );

      return pw.Table.fromTextArray(
        // Column headers of the table
        headers: [
          'No.',
          'Details',
          'Net Amount',
          'Rate ',
          'GST Amount',
          'Total '
        ],
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
          borderRadius: pw.BorderRadius.circular(6),
        ),
        headerHeight: 30,
        // To ensure all columns are properly displayed when there is long details
        columnWidths: {
          // 0: pw.FlexColumnWidth(1),
          // 1: pw.FlexColumnWidth(3),
          // 2: pw.FlexColumnWidth(1),
          // // 3: pw.FlexColumnWidth(1),
          // 4: pw.FlexColumnWidth(2),
          // 5: pw.FlexColumnWidth(1),
          0: pw.IntrinsicColumnWidth(),
          1: pw.IntrinsicColumnWidth(),
          2: pw.IntrinsicColumnWidth(),
          4: pw.IntrinsicColumnWidth(),
          5: pw.IntrinsicColumnWidth(),
        },
        headerAlignments: {
          0: pw.Alignment.center,
          1: pw.Alignment.center,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
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
        // maxPages: 1,
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(56),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Proforma GST calculation',
                style: pw.TextStyle(color: mainColor),
              ),
              pw.Divider(color: PdfColors.blueGrey),
              pw.SizedBox(height: 10),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            gstDataTable(),
            // test(),
          ];
        },
        footer: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(color: PdfColors.blueGrey500),
              pw.Text(
                'via GST Now - The simplest GST calculator app with CGST, SGST & IGST breakup.',
                style: pw.TextStyle(
                  color: PdfColors.blueGrey500,
                  fontSize: 10,
                  // fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Available for Android on PlayStore, and iOS & macOS on AppStore.',
                style: pw.TextStyle(
                  color: PdfColors.blueGrey500,
                  fontSize: 10,
                  // fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    // To get the current directory where the file will be saved
    var documentDirectory = await getApplicationDocumentsDirectory();

    // Here we set the PDF file name as well
    File pdfFile =
        File('${documentDirectory.path}/GST Now-ar-${DateTime.now()}.pdf');

    // Writing the data into the PDF file
    // earlier this was
    // await pdfFile.writeAsBytes(await pdfGSTDataTable.save());
    pdfFile.writeAsBytesSync(await pdfGSTDataTable.save());

    // Opening the PDF file
    await OpenFile.open(pdfFile.path);
    result = true;
  } catch (e) {
    print(e);
    result = false;
  }
  return result;
}
