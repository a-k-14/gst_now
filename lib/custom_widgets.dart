import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// This file stores the custom widgets

// To create the GST Rate Buttons
class GSTRateButton extends StatelessWidget {
  // The rate to be displayed on the button
  final String rate;
  // To set the GST rate value into the respective TextField
  final Function onTap;

  GSTRateButton({this.rate, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Width & height given to keep all boxes consistent
      width: 65,
      height: 40,
      // Space between the buttons
      margin: EdgeInsets.only(right: 6),
      child: ElevatedButton(
        child: Text(
          rate,
          style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          // Button color
          primary: Colors.white,
          // Splash color
          onPrimary: Colors.grey[350],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onPressed: onTap,
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

  GSTOperatorTab({this.operatorValues, this.f});

  @override
  _GSTOperatorTabState createState() => _GSTOperatorTabState();
}

class _GSTOperatorTabState extends State<GSTOperatorTab> {
  int segmentedControlGroupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container is to enforce width
      width: MediaQuery.of(context).size.width * 0.93,
      // Edited const double _kMinSegmentedControlHeight = 40.0;
      // default - 28.0 in the default files
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlGroupValue,
          // padding: EdgeInsets.all(0),
          // We are using children directly here instead of creating a variable as
          // we get the error The instance member ‘{0}’ can’t be accessed in an initializer
          children: {
            0: Text(widget.operatorValues[0]),
            1: Text(widget.operatorValues[1]),
          },
          // i is the value of myTab{int}
          onValueChanged: (i) {
            setState(() {
              segmentedControlGroupValue = i;
            });
            widget.f(segmentedControlGroupValue);
          }),
    );
  }
}
