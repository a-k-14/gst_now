import 'dart:io'; // To create a PDF file at the path
import 'constants.dart';
import 'package:path_provider/path_provider.dart'; // To get the document stored path
import 'package:pdf/pdf.dart'; // To create PDF
import 'package:pdf/widgets.dart' as pw; // To use widgets to create PDF
import 'package:open_file/open_file.dart'; // To open the PDF file in the platform native viewer
import 'gst_calculation_item.dart';

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
      pw.TextStyle totalTextStyle = pw.TextStyle(
          color: mainColor, fontWeight: pw.FontWeight.bold, fontSize: 11);
      pw.TextStyle rowTextStyle = pw.TextStyle(fontSize: 11);

      // To generate the GST Amount & CGST & SGST/IGST amount displays
      pw.Widget gstAmount(int index) {
        return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('${gstCalcItemsList[index].gstAmount}',
                  style: rowTextStyle),
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
            pw.Text('${index + 1}', style: rowTextStyle),

            /// We added Expanded here as we were getting the below error though the rows do not need 20 pages
            // This widget created more than 20 pages. This may be an issue in the widget or the document
            // Probably that the columns are going beyond 1 page
            pw.Expanded(
              child: pw.Container(
                constraints: pw.BoxConstraints(
                  maxWidth: 150,
                ),
                child: pw.Text('${gstCalcItemsList[index].details}',
                    style: rowTextStyle),
              ),
            ),
            pw.Expanded(
              child: pw.Text('${gstCalcItemsList[index].netAmount}',
                  style: rowTextStyle),
            ),
            pw.Text('${gstCalcItemsList[index].gstRate}%', style: rowTextStyle),
            pw.Expanded(
              child: gstAmount(index),
            ),
            pw.Expanded(
              child: pw.Text('${gstCalcItemsList[index].totalAmount}',
                  style: rowTextStyle),
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

    //---------------------------------------------------------------
    _myPageTheme(PdfPageFormat format) {
      return pw.PageTheme(
        margin: pw.EdgeInsets.all(0),
        pageFormat: format.applyMargin(
            left: 0 * PdfPageFormat.cm,
            top: 0 * PdfPageFormat.cm,
            right: 0,
            bottom: 0.5 * PdfPageFormat.cm),
        theme: pw.ThemeData(
//      base: pw.Font.ttf(await rootBundle.load('assets/fonts/nexa_bold.otf')),
//      bold:
//          pw.Font.ttf(await rootBundle.load('assets/fonts/raleway_medium.ttf')),
            ),
        buildBackground: (pw.Context context) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.CustomPaint(
              // size: PdfPoint(format.width, format.height),
              painter: (PdfGraphics canvas, PdfPoint size) {
                context.canvas
                  // ..setColor(PdfColors.lightBlue)
                  // ..moveTo(0, size.y)
                  // ..lineTo(0, size.y - 230)
                  // ..lineTo(60, size.y)
                  // ..fillPath()
                  ..setColor(PdfColors.grey300)
                  ..moveTo(0, size.y)
                  ..lineTo(0, size.y - 100)
                  ..lineTo(100, size.y)
                  ..fillPath()
                  ..setColor(PdfColors.grey100)
                  ..moveTo(30, size.y)
                  ..lineTo(110, size.y - 50)
                  ..lineTo(150, size.y)
                  ..fillPath();
                // ..moveTo(size.x, 0)
                // ..lineTo(size.x, 230)
                // ..lineTo(size.x - 60, 0)
                // ..fillPath()
                // ..setColor(PdfColors.blue)
                // ..moveTo(size.x, 0)
                // ..lineTo(size.x, 100)
                // ..lineTo(size.x - 100, 0)
                // ..fillPath()
                // ..setColor(PdfColors.lightBlue)
                // ..moveTo(size.x - 30, 0)
                // ..lineTo(size.x - 110, 50)
                // ..lineTo(size.x - 150, 0)
                // ..fillPath();
              },
            ),
          );
        },
      );
    }

    //----------------------------------------------

    // Adding data to the PDF
    pdfGSTDataTable.addPage(
      pw.MultiPage(
        // maxPages: 1,
        // pageFormat: PdfPageFormat.a4,
        // margin: pw.EdgeInsets.all(0),
        pageTheme: _myPageTheme(PdfPageFormat.a4),
        header: (context) {
          return pw.Container(
            margin: pw.EdgeInsets.fromLTRB(52, 80, 52, 0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Proforma GST calculation',
                  style: pw.TextStyle(
                    color: mainColor,
                  ),
                ),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 1),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Container(
              margin: pw.EdgeInsets.symmetric(horizontal: 52, vertical: 5),
              child: gstDataTable(),
            ),
            // test(),
          ];
        },

        footer: (context) {
          return pw.Container(
            color: mainColor,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // We have divider here so that column expands full width
                // We can use pw.CrossAxisAlignment.stretch, but we need data to align in center
                pw.Divider(color: mainColor),
                pw.Text(
                  'via GST Now - The simplest GST calculator app with CGST, SGST & IGST breakup',
                  style: pw.TextStyle(
                    color: PdfColors.blueGrey300,
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.UrlLink(
                      child: pw.Text(
                        'Available here for Android',
                        style: pw.TextStyle(
                          decoration: pw.TextDecoration.underline,
                          color: PdfColors.blueGrey300,
                          // fontSize: 10,
                        ),
                      ),
                      destination: '$kPlayStoreURL',
                    ),
                    pw.SizedBox(width: 20),
                    pw.UrlLink(
                      child: pw.Text(
                        'Available here for iOS & macOS',
                        style: pw.TextStyle(
                          decoration: pw.TextDecoration.underline,
                          color: PdfColors.blueGrey300,
                          // fontSize: 10,
                        ),
                      ),
                      destination: '$kAppStoreURL',
                    ),
                  ],
                ),
                pw.Divider(color: mainColor),
              ],
            ),
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
