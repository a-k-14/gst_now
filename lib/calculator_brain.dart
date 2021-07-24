import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*
 <Role> get data - format dat - calc result - return formatted data and formatted result
 To get the initial value as and gst rate as
 To return '' if initial value is empty, else return formatted initial value
 To return '' if gst rate is empty, else return formatted gst rate
 To return result if initial value & gst rate are not empty, else return 0
 <Process>
 Get the initialValue and gstRate as TEC

*/

class GSTCalculatorBrain {
  // TODO: should I use final here
  // Here, either we can create instance properties and store values in them and then pass to instance methods
  // Or we can directly pass the values to instance methods to get the results
  // final TextEditingController initialValue;
  final gstRate;
  int currentGSTOperator;

  GSTCalculatorBrain({
    this.currentGSTOperator,
    // this.initialValue,
    this.gstRate,
  });

  void gstOperatorSet(int i) {
    this.currentGSTOperator = i;
    print('GST op in CB= $currentGSTOperator');
  }

  String gstOperator() {
    return currentGSTOperator == 0 ? 'Add GST' : 'Less GST';
  }

  // To ensure commas
  // var f = NumberFormat.currency(decimalDigits: 2, name: '', locale: 'en_IN');
  var f = NumberFormat('#,##,##0.00', 'en_IN');

  // To return the formatted initial value
  String formatInitialValue(String s) {
    // bool isInitialValueEmpty = initialValue.text.isEmpty;

    // return isInitialValueEmpty ? '' : f.format(double.parse(initialValue.text));
    print(s);
    return s.isEmpty ? '' : f.format(double.tryParse(s));
  }

  String formatGSTRate() {
    // print('From CB, GST Rate= ${gstRate.text}');
    bool i = double.tryParse(gstRate.text) == null;
    print("GST Rate is empty? $i");

    bool isGSTRateEmpty = gstRate.text.isEmpty;
    // format takes only double as input
    return i ? '' : f.format(double.parse(gstRate.text)) + '%';
  }

  String result() {
    var result =
        // initialValue.text.isEmpty ||
        gstRate.text.isEmpty ? 0 : double.parse(gstRate.text);

    return f.format(result);
  }
}
