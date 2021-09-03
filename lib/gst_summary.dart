import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'gst_calculator_brain.dart';

// Moved this widget out of custom_widgets.dart as it has become lengthy

// To display calculation summary and breakup
// We use Widget instead of a class extending stateless widget as we get error of:
// The instance member 'f' can't be accessed in an initializer
// We take context for snackBar (share) to work
// We take wideScreen for adjusting the size of SnackBar on bigger screens
Widget gstSummary({
  required GSTCalculatorBrain gstCalculatorBrain,
  required BuildContext context,
  required bool wideScreen,
  required Function addGSTCalcItem,
}) {
  String netAmount = gstCalculatorBrain.netAmount;
  String gstRate = gstCalculatorBrain.rate;
  String gstAmount = gstCalculatorBrain.gstAmount;
  String totalAmount = gstCalculatorBrain.totalAmount;
  // String gstOperator = _gstCalculatorBrain.gstOperator();
  String csgstRate = gstCalculatorBrain.csgstRate;
  String igstRate = gstCalculatorBrain.igstRate;
  String csgstAmount = gstCalculatorBrain.csgstAmount;
  String igstAmount = gstCalculatorBrain.igstAmount;
  String gstBreakupOperator = gstCalculatorBrain.gstBreakupOperator();

  // To display Net Amount, GST Amount, Total Amount as titles and their values as values
  // color is taken as a parameter as the rows have alternating colors
  // borderRadius is taken as a parameter as the corner radius is different for 1st & 3rd rows
  // padding is taken as a parameter as GST Amount (middle row has different padding
  // We use SCS to scroll long length values
  Widget customSummaryRow({
    required Widget title,
    required Widget value,
    required Color color,
    required BorderRadius borderRadius,
    required EdgeInsetsGeometry padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          // Title to occupy 2/3rd space
          Expanded(child: title, flex: 2),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: value,
            ),
          ),
        ],
      ),
    );
  }

  Widget csgstSummary = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'CGST @ $csgstRate% = $csgstAmount',
        style: kGSTSummaryBreakupTextStyle,
      ),
      Container(
        margin: EdgeInsets.only(top: 3, bottom: 3),
        color: kGSTSummaryRowBackground1,
        height: 1,
        width: 90,
      ),
      Text(
        'SGST @ $csgstRate% = $csgstAmount',
        style: kGSTSummaryBreakupTextStyle,
      ),
    ],
  );

  Widget igstSummary = Text(
    'IGST @ $igstRate% = $igstAmount',
    style: kGSTSummaryBreakupTextStyle,
  );

  // To show Snack Bar on click of Add to List & Share buttons if BaseAmount || GSTRate are empty
  void showSnackBar() {
    // We show the text based on which filed Base Amount & GST Rate is empty
    String snackBarText = '';
    if (netAmount.isEmpty & gstRate.isEmpty) {
      snackBarText = 'Please enter Base Amount & GST Rate';
    } else if (netAmount.isEmpty) {
      snackBarText = 'Please enter Base Amount';
    } else if (gstRate.isEmpty) {
      snackBarText = 'Please enter GST Rate';
    }
    SnackBar snackBar = SnackBar(
      elevation: 0,
      width: MediaQuery.of(context).size.width * (wideScreen ? 0.70 : 0.98),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius)),
      content: Text(snackBarText),
      action: SnackBarAction(
        label: 'Ok',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // The GST summary widget to be displayed
  return Container(
    margin: EdgeInsets.only(left: kPadding, top: kPadding, right: kPadding),
    child: Column(
      children: [
        customSummaryRow(
          title: Text(
            'Net Amount',
            style: kGSTSummaryRowTextStyle1,
          ),
          value: Text(
            netAmount,
            style: kGSTSummaryRowTextStyle2,
          ),
          color: kGSTSummaryRowBackground1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(kGSTSummaryBorderRadius),
            topRight: Radius.circular(kGSTSummaryBorderRadius),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: kPadding + 2, vertical: kPadding + 4),
        ),
        customSummaryRow(
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              'GST @ $gstRate%',
              style: kGSTSummaryRowTextStyle1,
            ),
          ),
          value: Text(
            gstAmount,
            style: kGSTSummaryRowTextStyle2,
          ),
          color: kGSTSummaryRowBackground2,
          borderRadius: BorderRadius.only(),
          // This row has a different padding to accommodate the CGST&SGST section
          padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
        ),
        // We use row and empty 2nd container to get color next to CGST&SGST
        Row(
          children: [
            Container(
              height: 55,
              width: 200,
              padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
              color: kGSTSummaryRowBackground2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:
                    gstBreakupOperator == 'IGST' ? igstSummary : csgstSummary,
              ),
            ),
            // To fill the empty space below GST Rate value and right to GST breakup with background color
            Expanded(
              child: Container(
                color: kGSTSummaryRowBackground2,
                height: 55,
              ),
            ),
          ],
        ),
        customSummaryRow(
          title: Text(
            'Total Amount',
            style: kGSTSummaryRowTextStyle1,
          ),
          value: Text(
            totalAmount,
            style: TextStyle(
              fontSize: kTextSize,
              color: kMainColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          color: kGSTSummaryRowBackground1,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(kGSTSummaryBorderRadius),
            bottomRight: Radius.circular(kGSTSummaryBorderRadius),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: kPadding + 2, vertical: kPadding + 4),
        ),
        // To provide 'Add to List' & 'Share' options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                primary: kMainColor,
              ),
              onPressed: () {
                // To stop empty row addition
                if (netAmount.isEmpty || gstRate.isEmpty) {
                  showSnackBar();
                } else {
                  GSTCalcItem data = GSTCalcItem(
                      netAmount: netAmount,
                      gstRate: gstRate,
                      gstAmount: gstAmount,
                      gstBreakupOperator: gstBreakupOperator,
                      csgstRate: csgstRate,
                      csgstAmount: csgstAmount,
                      totalAmount: totalAmount);
                  addGSTCalcItem(data);
                  SnackBar snackBar = SnackBar(
                    content: Container(
                      child: Text('Added', textAlign: TextAlign.center),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey[700],
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    behavior: SnackBarBehavior.floating,
                    width: 100,
                    elevation: 0,
                    duration: Duration(milliseconds: 500),
                    // padding: EdgeInsets.all(0),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: Text('Add to List'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: kMainColor,
              ),
              onPressed: () {
                String gstBreakup = gstBreakupOperator == 'IGST'
                    ? 'IGST @ $igstRate% = $igstAmount'
                    : 'CGST @ $csgstRate% = $csgstAmount\nCGST @ $csgstRate% = $csgstAmount';
                String calculationResult = 'Net Amount = $netAmount\n'
                    'GST @ $gstRate% = $gstAmount\n'
                    'Total Amount = $totalAmount\n'
                    '----------\n'
                    '$gstBreakup\n\n'
                    'via GST Now, download👉: https://curiobeing.github.io/GSTNow.app/';
                // To stop empty sharing
                if (netAmount.isEmpty || gstRate.isEmpty) {
                  showSnackBar();
                } else {
                  share(shareData: calculationResult);
                }
              },
              child: Text('Share'),
            ),
          ],
        ),
      ],
    ),
  );
}

// This is the GST Calculation Item class to create and store elements for GST Table row creation
class GSTCalcItem {
  // We make these nullable so that when this class instantiated in gst_calculatorPage, we need not pass empty values and an empty row is built
  String? netAmount;
  String? gstRate;
  String? gstAmount;
  String? gstBreakupOperator;
  // We are not getting igstRate & igstAmount as these will be same as gstRate & gstAmount
  String? csgstRate;
  String? csgstAmount;
  String? totalAmount;
  GSTCalcItem({
    required this.netAmount,
    required this.gstRate,
    required this.gstAmount,
    required this.gstBreakupOperator,
    required this.csgstRate,
    required this.csgstAmount,
    required this.totalAmount,
  });
  List<GSTCalcItem> gstCalcList = [];
  void updateGSTCalcList(GSTCalcItem data) {
    gstCalcList.add(data);
  }

  void clearGSTCalcList() {
    gstCalcList.clear();
  }
}

Widget gstTable(List<GSTCalcItem> myList, Function f) {
  // To set the scroll bar visibility
  final ScrollController scrollController = ScrollController();
  // This list holds the GST Calculation Items to create the rows of GST Table
  List<GSTCalcItem> myList1 = myList.isEmpty ? [] : myList;

  List<DataRow> testRows = myList1.isEmpty
      ? []
      : myList1
          .asMap()
          .map((i, gstCalcItem) => MapEntry(
              // TODO: if we use wrap MapEntry with {}, we get errorThe argument type 'List<dynamic>' can't be assigned to the parameter type 'List<DataRow>'
              // So we use =>
              i,
              DataRow(
                onSelectChanged: (bool) {},
                cells: [
                  DataCell(Text('${i + 1}')),
                  DataCell(Text(gstCalcItem.netAmount ?? '')),
                  DataCell(Text(gstCalcItem.gstRate ?? '')),
                  DataCell(
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(gstCalcItem.gstAmount ?? ''),
                          SizedBox(height: 4),
                          // To check for CGST&SGST/IGST and display accordingly
                          gstCalcItem.gstBreakupOperator == 'IGST'
                              ? Text(
                                  'IGST: ${gstCalcItem.gstAmount ?? ''}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                )
                              : Column(
                                  children: [
                                    Text(
                                      'CGST: ${gstCalcItem.csgstAmount ?? ''}',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    Text(
                                      'SGST: ${gstCalcItem.csgstAmount ?? ''}',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(gstCalcItem.totalAmount ?? '')),
                ],
              )))
          .values
          .toList();

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(height: kSizedBoxHeight),
      Divider(),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: kPadding * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'List - ${myList1.length} items',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: kMainColor,
              ),
              onPressed: () {
                f();
              },
              child: Text('Clear List'),
            ),
          ],
        ),
      ),
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 400,
          //MediaQuery.of(context).size.height * 0.5,
          minHeight: 0,
        ),
        child: Container(
          margin: EdgeInsets.only(
              left: kPadding,
              right: kPadding * 1.5,
              bottom: kPadding,
              top: kPadding - 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kBorderRadius - 2),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                // offset: Offset(0, 2),
                blurRadius: kBorderRadius,
                // spreadRadius: 2,
              ),
            ],
          ),
          child: Scrollbar(
            // controller: scrollController,
            radius: Radius.circular(kBorderRadius - 2),
            // isAlwaysShown: true,
            child: SingleChildScrollView(
              // This padding to avoid scroll bar shown over text when scrolling horizontally
              // padding: EdgeInsets.only(right: kPadding - 4),
              // controller: scrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowHeight: 52, // default is 48
                  columnSpacing: 20, // default is 56
                  headingRowHeight: 48, // default is 56
                  headingRowColor: MaterialStateProperty.all(Color(0x1AC1C1C1)),
                  showCheckboxColumn: true,
                  columns: [
                    DataColumn(label: Text('No.')),
                    DataColumn(label: Text('Net Amount')),
                    DataColumn(label: Text('GST Rate')),
                    DataColumn(
                      label: Text('GST Amount'),
                    ),
                    DataColumn(label: Text('Total Amount'), numeric: true),
                  ],
                  // We are using .asMap here so that we will get index of list item to be used as 'No'
                  rows: testRows,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
