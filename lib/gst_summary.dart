// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pdfGeneration.dart';
import 'constants.dart';
import 'gst_calculation_item.dart';
import 'gst_calculator_brain.dart';

// Moved this widget out of custom_widgets.dart as it has become lengthy

// To display calculation summary and breakup
// We use Widget instead of a class extending stateless widget as we get error of:
// The instance member 'f' can't be accessed in an initializer
// We take context for snackBar (share) to work
// We take wideScreen for adjusting the size of SnackBar on bigger screens
// We take addGSTCalcItem to add the current GST calculation to the gstCalcItem List to be used in GST DataTable
// We take totals to be used in displaying Total row in GST DataTable
// We take detailsController to capture description entered
Widget gstSummary({
  required GSTCalculatorBrain gstCalculatorBrain,
  required BuildContext context,
  required bool wideScreen,
  required Function addGSTCalcItem,
  required Totals totals,
  required TextEditingController detailsController,
  required Function f,
}) {
  String baseAmount = gstCalculatorBrain.baseAmount;
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

  // To show Snack Bar on click of Add to List & Share buttons if Amount || GSTRate are empty
  void showSnackBar() {
    // We show the text based on which field Amount & GST Rate is empty
    String snackBarText = '';
    if (baseAmount.isEmpty & gstRate.isEmpty) {
      snackBarText = 'Please enter Amount & GST Rate';
    } else if (baseAmount.isEmpty) {
      snackBarText = 'Please enter Amount';
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
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // The GST summary widget to be displayed
  return Column(
    children: [
      Container(
        margin:
            EdgeInsets.only(left: kPadding, top: kPadding - 6, right: kPadding),
        child: Column(
          children: [
            customSummaryRow(
              title: Text(
                'Base Amount',
                style: kGSTSummaryRowTextStyle1,
              ),
              value: Text(
                baseAmount,
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
                    child: gstBreakupOperator == 'IGST'
                        ? igstSummary
                        : csgstSummary,
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
          ],
        ),
      ),
      Container(
        height: 58,
        padding:
            EdgeInsets.only(top: kPadding + 3, left: kPadding, right: kPadding),
        child: TextField(
          controller: detailsController,
          textCapitalization: TextCapitalization.sentences,
          cursorHeight: 22,
          cursorColor: kMainColor,
          decoration: InputDecoration(
            // Dense only if large screen (width > 600)
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            labelText: 'Description',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                // TODO: Cannot use Colors.grey[350] or Colors.grey.shade350
                color: Color(0xffD6D6D6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kMainColor),
            ),
            suffixIcon: detailsController.text.isEmpty
                ? Text('')
                : IconButton(
                    splashRadius: 20,
                    icon: Icon(Icons.clear_rounded, size: 18),
                    color: kMainColor,
                    onPressed: () {
                      detailsController.clear();
                    },
                  ),
          ),
        ),
      ),
      // To provide 'Add to List' & 'Share' options
      Padding(
        padding: EdgeInsets.symmetric(horizontal: kPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: kTextButtonContainerMargin,
              height: kTextButtonContainerHeight,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: kMainColor),
                onPressed: () {
                  // To stop empty row addition
                  if (baseAmount.isEmpty || gstRate.isEmpty) {
                    showSnackBar();
                  } else {
                    GSTCalcItem data = GSTCalcItem(
                        details: detailsController.text,
                        baseAmount: baseAmount,
                        gstRate: gstRate,
                        gstAmount: gstAmount,
                        gstBreakupOperator: gstBreakupOperator,
                        csgstRate: csgstRate,
                        csgstAmount: csgstAmount,
                        igstAmount: igstAmount,
                        totalAmount: totalAmount);
                    addGSTCalcItem(data);
                    // To make the totals to be used in Total row of GST DataTable
                    totals.addToTotals(data);
                    // To show 'Added' SnackBar after adding the row to the list/GST DataTable
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
                      duration: Duration(milliseconds: 800),
                      // padding: EdgeInsets.all(0),
                    );
                    // We added .closed.then... to avoid showing SnackBar multiple times when we click 'Add to List' button multiple times very quickly
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBar)
                        .closed
                        .then((value) =>
                            ScaffoldMessenger.of(context).clearSnackBars());
                  }
                  FocusScope.of(context).unfocus();
                },
                child: Text('Add to List'),
              ),
            ),
            Container(
              margin: kTextButtonContainerMargin,
              height: kTextButtonContainerHeight,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: kMainColor),
                onPressed: () {
                  String gstBreakup = gstBreakupOperator == 'IGST'
                      ? 'IGST @ $igstRate% = $igstAmount'
                      : 'CGST @ $csgstRate% = $csgstAmount\nCGST @ $csgstRate% = $csgstAmount';
                  // We created a details string so as to avoid an empty 1st line if details is empty
                  String details = detailsController.text.isEmpty
                      ? ''
                      : '${detailsController.text}\n';
                  String calculationResult = '$details'
                      'Net Amount = $baseAmount\n'
                      'GST @ $gstRate% = $gstAmount\n'
                      'Total Amount = $totalAmount\n'
                      '----------\n'
                      '$gstBreakup\n\n'
                      'via GST Now, download👉: https://curiobeing.github.io/GSTNow.app/';
                  // To stop empty sharing
                  if (baseAmount.isEmpty || gstRate.isEmpty) {
                    showSnackBar();
                  } else {
                    share(shareData: calculationResult);
                  }
                },
                child: Text('Share'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// We made GSTDataTable into stateful widget from normal widget for the checkboxes to work
class GSTDataTable extends StatefulWidget {
  // List of GST Calc Items used to generate rows for GST DataTable
  final List<GSTCalcItem> gstCalcItemsList;
  // Function to remove the rows from GST DataTable on click of 'Clear List' button
  final Function clearList;
  // Function to remove the selected rows from GST DataTable on click of 'Clear Selected' button
  final Function removeSelectedRows;
  // To update the Details of a row
  final Function updateDetails;
  // To get the totals to be displayed in the Total row of GST DataTable
  final Totals totals;

  GSTDataTable({
    required this.gstCalcItemsList,
    required this.clearList,
    required this.removeSelectedRows,
    required this.updateDetails,
    required this.totals,
  });

  @override
  _GSTDataTableState createState() => _GSTDataTableState(
        gstCalcItemsList: gstCalcItemsList,
        clearList: clearList,
        removeSelectedRows: removeSelectedRows,
        updateDetails: updateDetails,
        // contextForUpdateDetails: contextForUpdateDetails,
        // widescreen: widescreen,
        totals: totals,
      );
}

class _GSTDataTableState extends State<GSTDataTable> {
  // List of GST Calc Items used to generate rows for GST DataTable
  final List<GSTCalcItem> gstCalcItemsList;
  // Function to remove the rows from GST DataTable on click of 'Clear List' button
  final Function clearList;
  // Function to remove the selected rows from GST DataTable on click of 'Clear Selected' button
  final Function removeSelectedRows;
  // To update the Details of a row
  final Function updateDetails;
  // To get the totals to be displayed in the Total row of GST DataTable
  final Totals totals;

  _GSTDataTableState({
    required this.gstCalcItemsList,
    required this.clearList,
    required this.removeSelectedRows,
    required this.updateDetails,
    required this.totals,
  });

  // To set the scroll bar visibility
  final ScrollController scrollController = ScrollController();

  // To store the selected rows of GST DataTable that will be removed by click of 'Clear Selected' button
  List<GSTCalcItem> selectedRows = [];

  // Method to return the rows for GST Table
  List<DataRow> rowsGenerator() {
    // We use List.generate instead of .map to get index value to be displayed in No. column
    // We can also use .asMap() instead of List.generate. But that is more complicated
    List<DataRow> rowsList = List<DataRow>.generate(
        gstCalcItemsList.length,
        (index) => DataRow(
              // To show the tick mark in check box indicating the row is selected
              // If the current row is in selectedRows then box will be checked
              // The current row will be added selectedRows using onSelectChanged Function
              selected: selectedRows.contains(gstCalcItemsList[index]),
              onSelectChanged: (isSelected) {
                setState(() {
                  // To add the current row to selectedRows list
                  if (isSelected != null && isSelected) {
                    selectedRows.add(gstCalcItemsList[index]);
                  } else {
                    // To remove the current row to selectedRows list
                    selectedRows.remove(gstCalcItemsList[index]);
                  }
                });
              },
              cells: [
                DataCell(Text('${index + 1}')), // as index starts from 0
                DataCell(
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width >
                                  wideScreenWidth
                              ? 150
                              : 80),
                      child: Text(
                        gstCalcItemsList[index].details ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // User taps on the details of particular row, a dialog is shown where user can edit the details, and the new details is sent to updateDetails method to update it in the row
                    onTap: () {
                  // To pass the TEC into AlertDialog shown
                  TextEditingController newDetailsController =
                      TextEditingController();
                  // To show the already entered text in the AlertDialog
                  newDetailsController.text =
                      gstCalcItemsList[index].details ?? '';
                  showDialog(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return SingleChildScrollView(
                        // TODO: Why this and details column width based on wideScreen does not work
                        // So we use MediaQuery here directly. Defining it in the start of class also doesn't work?
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width >
                                    wideScreenWidth
                                ? 0
                                : 100),
                        child: AlertDialog(
                          title: Text('Edit Details'),
                          content: TextField(
                            controller: newDetailsController,
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: kMainColor,
                            cursorHeight: 22,
                            autofocus: true,
                            maxLines: 2,
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.all(0),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kMainColor)),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(kBorderRadius)),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  newDetailsController.clear();
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: kMainColor),
                                child: Text('Clear')),
                            TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor: kMainColor),
                              child: Text('Done'),
                              onPressed: () {
                                // To update the new details in the row
                                updateDetails(index, newDetailsController.text);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
                DataCell(Text(gstCalcItemsList[index].baseAmount ?? '')),
                DataCell(Text('${gstCalcItemsList[index].gstRate ?? ''}%')),
                DataCell(
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(gstCalcItemsList[index].gstAmount ?? ''),
                        SizedBox(height: 4),
                        // To check for CGST&SGST/IGST and display accordingly
                        gstCalcItemsList[index].gstBreakupOperator == 'IGST'
                            ? Text(
                                'IGST: ${gstCalcItemsList[index].gstAmount ?? ''}',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              )
                            : Column(
                                children: [
                                  Text(
                                    'CGST: ${gstCalcItemsList[index].csgstAmount ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                  Text(
                                    'SGST: ${gstCalcItemsList[index].csgstAmount ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(gstCalcItemsList[index].totalAmount ?? '')),
              ],
            ));

    // Here we insert the Total Row at the starting of the rows list
    // We use the Total class and get the totals
    // 1 - tNetAmount
    // 2 - tGSTAmount
    // 3 - tCSGSTAmount
    // 4 - tIGSTAmount
    // 5 - tTotalAmount
    rowsList.insert(
        0,
        DataRow(color: MaterialStateProperty.all(Color(0x1AC1C1C1)), cells: [
          DataCell(Text('')),
          DataCell(Text(
            'Total',
            style: TextStyle(color: kMainColor, fontWeight: FontWeight.w500),
          )),
          DataCell(Text(
            totals.tAmountString(1),
            style: TextStyle(color: kMainColor, fontWeight: FontWeight.w500),
          )),
          DataCell(Text('')),
          DataCell(
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    totals.tAmountString(2),
                    style: TextStyle(
                        color: kMainColor, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  // To check for CGST&SGST/IGST and display accordingly
                  Column(
                    children: [
                      Text(
                        'CGST: ${totals.tAmountString(3)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        'SGST: ${totals.tAmountString(3)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        'IGST: ${totals.tAmountString(4)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DataCell(Text(
            totals.tAmountString(5),
            style: TextStyle(color: kMainColor, fontWeight: FontWeight.w500),
          )),
        ]));

    return rowsList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: kSizedBoxHeight * 2),
        Divider(height: 20, thickness: 2, color: Colors.grey[200]),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: kPadding * 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'List - ${gstCalcItemsList.length} items',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              // This button is to clear list & clear selected items from the list
              // It does 2 jobs - if selectedRows is empty then it clears list, else it clears selected items
              TextButton(
                style: TextButton.styleFrom(foregroundColor: kMainColor),
                onPressed: () {
                  if (selectedRows.isEmpty) {
                    // To clear the list and reset the totals to 0
                    clearList();
                    totals.reset();
                  } else {
                    // To remove the selected rows from the GST DataTable
                    // We get this function from gst_calculatorPage.dart
                    removeSelectedRows(selectedRows);
                    // We clear the selectedRows here as it still has the rows selected after executing the above clearSelectedRows(selectedRows) Function
                    selectedRows.clear();
                    // We first reset the totals and then do the totalling once again
                    // If we don't reset here, the totals will be double as we will be adding to the existing total amounts that we receive from the gstSummary widget on click of Add to List button
                    totals.reset();
                    // We take the new gstCalcItemsList, i.e. the list with selectedRows removed
                    // We repeat the addToTotals button for each element of gstCalcItemsList
                    gstCalcItemsList.forEach((element) {
                      totals.addToTotals(element);
                    });
                  }
                },
                child: Text(selectedRows.isEmpty
                    ? 'Clear List'
                    : 'Clear Selected (${selectedRows.length})'),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 430,
            //MediaQuery.of(context).size.height * 0.5,
            minHeight: 0,
          ),
          child: Container(
            margin: EdgeInsets.only(
              left: kPadding,
              right: kPadding * 1.5,
              // bottom: kPadding,
              // top: kPadding - 4,
            ),
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
              controller: scrollController,
              radius: Radius.circular(kBorderRadius - 2),
              // isAlwaysShown: true,
              child: SingleChildScrollView(
                // This padding to avoid scroll bar shown over text when scrolling horizontally
                // padding: EdgeInsets.only(right: kPadding - 4),
                controller: scrollController,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowHeight: 58, // default is 48
                    columnSpacing: 20, // default is 56
                    headingRowHeight: 42, // default is 56
                    headingRowColor:
                        MaterialStateProperty.all(Color(0x1AC1C1C1)),
                    showCheckboxColumn: true,
                    horizontalMargin: 20,
                    columns: [
                      DataColumn(label: Text('No.')),
                      DataColumn(label: Text('Details')),
                      DataColumn(label: Text('Base Amount')),
                      DataColumn(label: Text('Rate')),
                      DataColumn(
                        label: Text('GST Amount'),
                      ),
                      DataColumn(label: Text('Total Amount'), numeric: true),
                    ],
                    // We are using .asMap here so that we will get index of list item to be used as 'No'
                    rows: rowsGenerator(),
                  ),
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // We generate PDF by calling createPDF function and if there is any error in generating PDf we show SnackBar
            createPDF(gstCalcItemsList, totals).then((value) {
              if (value) {
                print(value);
              } else {
                print(value);
                // To show SnackBar on error
                SnackBar snackBar = SnackBar(
                  elevation: 0,
                  width: MediaQuery.of(context).size.width > wideScreenWidth
                      ? MediaQuery.of(context).size.width * 0.70
                      : MediaQuery.of(context).size.width * 0.98,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius)),
                  content: Text('Error creating PDF. Please try again.'),
                  action: SnackBarAction(
                    label: 'Ok',
                    onPressed: () {},
                  ),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            });
          },
          style: TextButton.styleFrom(foregroundColor: kMainColor),
          child: Text('Share List'),
        ),
      ],
    );
  }
}
