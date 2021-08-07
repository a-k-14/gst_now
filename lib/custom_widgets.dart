import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gst_calc/gst_calculator_brain.dart';
import 'constants.dart';
// This file stores the custom widgets

// To create the GST Rate Buttons
class GSTRateButton extends StatelessWidget {
  // The list of rates to be displayed as buttons
  final List<String> gstRatesList;
  // To set the GST rate value into the respective TextField
  final Function onTap;

  GSTRateButton({required this.gstRatesList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Contains the SCS with GST Rate Buttons
      padding: EdgeInsets.all(kPadding - 4),
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Color.fromARGB(22, 118, 118, 128),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (String gstRate in gstRatesList)
              Container(
                // Width & height given to keep all boxes consistent
                width: 65,
                height: 40,
                // Space between the buttons
                margin: EdgeInsets.only(right: 6),
                child: ElevatedButton(
                  child:
                      Text('$gstRate%', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    // Button color
                    primary: Colors.white,
                    // Splash color
                    onPrimary: Colors.grey[350],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    onTap(gstRate);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// GST Operator Tab to create Add/Less GST and CGST&SGST/IGST selectors
class GSTOperatorTab extends StatefulWidget {
  // The operator values like Add/Less GST or CGST&SGST/IGST
  final List<String> operatorValues;
  // The function to send the gstOperator value to GST Calculator Brain
  final Function f;

  GSTOperatorTab({required this.operatorValues, required this.f});

  @override
  _GSTOperatorTabState createState() => _GSTOperatorTabState();
}

class _GSTOperatorTabState extends State<GSTOperatorTab> {
  int? segmentedControlGroupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container is to enforce width
      width: MediaQuery.of(context).size.width * 0.93,
      // Edited const double _kMinSegmentedControlHeight = 40.0;
      // default - 28.0 in the default files
      child: CupertinoSlidingSegmentedControl(
        groupValue: segmentedControlGroupValue,
        // thumbColor: Color(0x9f1388ef),
        // padding: EdgeInsets.all(0),
        // We are using children directly here instead of creating a variable as
        // we get the error The instance member ‘{0}’ can’t be accessed in an initializer
        children: {
          0: Text(widget.operatorValues[0]),
          1: Text(widget.operatorValues[1]),
        },
        // i is the value of myTab{int}
        onValueChanged: (dynamic i) {
          setState(() {
            segmentedControlGroupValue = i;
          });
          widget.f(segmentedControlGroupValue);
        },
      ),
    );
  }
}

// To display calculations summary and breakup
// We use Widget instead of a class extending stateless widget as we get error of:
// The instance member 'f' can't be accessed in an initializer
Widget gstSummary(GSTCalculatorBrain _gstCalculatorBrain) {
  String netAmount = _gstCalculatorBrain.netAmount;
  String gstRate = _gstCalculatorBrain.rate;
  String gstAmount = _gstCalculatorBrain.gstAmount;
  String totalAmount = _gstCalculatorBrain.totalAmount;
  // String gstOperator = _gstCalculatorBrain.gstOperator();
  String csgstRate = _gstCalculatorBrain.csgstRate;
  String igstRate = _gstCalculatorBrain.igstRate;
  String csgstAmount = _gstCalculatorBrain.csgstAmount;
  String igstAmount = _gstCalculatorBrain.igstAmount;
  String gstBreakupOperator = _gstCalculatorBrain.gstBreakupOperator();

  // To display Net Amount, GST Amount, Total Amount as titles and their values as values
  // color is taken as a parameter as the rows have alternating colors
  // borderRadius is taken as a parameter as the corner radius is different for 1st & 3rd rows
  // padding is taken as a parameter as GST Amount (middle row has different padding
  // We use SCS to scroll long length numbers
  Widget customSummaryRow(
      {required Widget title,
      required Widget value,
      required Color color,
      required BorderRadius borderRadius,
      required EdgeInsetsGeometry padding}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          // Word occupy 2/3rd space
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

  // The summary widget to be displayed
  return Container(
    margin: EdgeInsets.all(kPadding),
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
                horizontal: kPadding + 2, vertical: kPadding + 4)),
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
                      : csgstSummary),
            ),
            // To fill the empty space with background color
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
              // overflow: TextOverflow.ellipsis,
              // maxLines: 1,
              style: TextStyle(
                fontSize: kTextSize,
                color: kAccentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            color: kGSTSummaryRowBackground1,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(kGSTSummaryBorderRadius),
              bottomRight: Radius.circular(kGSTSummaryBorderRadius),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: kPadding + 2, vertical: kPadding + 4)),
      ],
    ),
  );
}

// To show GST Tip table on expansion
// We use stateful widget for the Expansion Panel List to work
class GSTTip extends StatefulWidget {
  @override
  _GSTTipState createState() => _GSTTipState();
}

class _GSTTipState extends State<GSTTip> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (i, isExpanded) {
        setState(() {
          _isExpanded = !isExpanded;
        });
      },
      elevation: 0,
      children: [
        ExpansionPanel(
          headerBuilder: (_, isExpanded) {
            return Container(
              padding: EdgeInsets.only(left: kPadding),
              alignment: Alignment.centerLeft,
              child: Text(
                "When to use CGST&SGST vs IGST?",
                style: TextStyle(color: Colors.grey),
              ),
            );
          },
          body: gstTipTable(),
          isExpanded: _isExpanded,
          canTapOnHeader: true,
        )
      ],
    );
  }

  // To build the Tip table
  Widget gstTipTable() {
    // To build the rows of the Tip table
    Widget customTipRow({
      required String title,
      required String tip,
      required Color color,
      required BorderRadius borderRadius,
    }) {
      // Custom Tip Row to be returned
      return Container(
        padding: EdgeInsets.all(kPadding - 2),
        decoration: BoxDecoration(
          border: Border.all(color: kGSTSummaryRowBackground1),
          // We take border radius as a parameter as the border corners are different for 1st & 2nd rows
          borderRadius: borderRadius,
          color: color,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: kGSTSummaryBreakupTextStyle,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                tip,
                style: TextStyle(
                  color: Colors.grey,
                  wordSpacing: 1,
                ),
              ),
            )
          ],
        ),
      );
    }

    // The Tip table returned by the gstTipTable widget
    // and used inside the Expansion Panel
    // We use outer widget as column to avoid the border created by the container around text
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: kPadding),
          child: Column(
            children: [
              customTipRow(
                title: 'CGST&SGST\n(Intra-State)',
                tip: csgstTip,
                color: kGSTSummaryRowBackground1,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(kBorderRadius),
                  topRight: Radius.circular(kBorderRadius),
                ),
              ),
              customTipRow(
                title: 'IGST\n(Inter-State)',
                tip: igstTip,
                color: kGSTSummaryRowBackground2,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(kBorderRadius),
                  bottomRight: Radius.circular(kBorderRadius),
                ),
              ),
            ],
          ),
        ),
        // This is placed with the tip table so that it will not stick out in the home screen
        Text(
          '\n\n\nMade with Flutter 💙 | ar 🤗\n\n',
          textAlign: TextAlign.center,
          style: kGSTSummaryBreakupTextStyle,
        ),
      ],
    );
  }
}
