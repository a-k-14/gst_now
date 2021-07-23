import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*
* To get the initial value as and gst rate as
* To return '' if initial value is empty, else return formatted initial value
* To return '' if gst rate is empty, else return formatted gst rate
* To return result if initial value & gst rate are not empty, else return 0
*/

class GSTCalculatorBrain {
  final double initialValue;
  final TextEditingController gstRate;

  GSTCalculatorBrain({this.initialValue, this.gstRate});

  // To ensure commas
  // var f = NumberFormat.currency(decimalDigits: 2, name: '', locale: 'en_IN');
  var f = NumberFormat('#,##,###.00', 'en_IN');

  // To return the formatted initial value
  String formatInitialValue() {
    print('From CB, IV= $initialValue');
    // We set starting value of initial value variable as 0
    // So to check if it is empty, we have to replace the first 0
    // TODO: Is this optimal way to verify if empty
    bool isInitialValueEmpty =
        initialValue.toStringAsFixed(0).replaceFirst('0', '').isEmpty;
    // return isInitialValueEmpty ? '' : f.format(initialValue);

    return initialValue.toString();
  }

  String formatGSTRate() {
    print('From CB, GST Rate= ${gstRate.text}');
    bool isGSTRateEmpty = gstRate.text.isEmpty;
    // format takes only double as input
    return isGSTRateEmpty ? '' : f.format(double.parse(gstRate.text)) + '%';
  }

  String result() {
    var result =
        gstRate.text.isEmpty ? 0 : initialValue * double.parse(gstRate.text);

    return f.format(result);
  }
}
