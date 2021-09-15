import 'package:intl/intl.dart';

// This is the GST Calculation Item class to create and store elements for GST Table row creation
class GSTCalcItem {
  // We make these nullable so that when this class instantiated in gst_calculatorPage, we need not pass empty values and an empty row is built
  String? netAmount;
  String? gstRate;
  String? gstAmount;
  String? gstBreakupOperator;
  String? csgstRate;
  String? csgstAmount;
  // We are not getting igstRate as this will be same as gstRate & gstAmount
  // But we use igstAmount as we need it to calculate the totals
  String? igstAmount;
  String? totalAmount;
  GSTCalcItem({
    required this.netAmount,
    required this.gstRate,
    required this.gstAmount,
    required this.gstBreakupOperator,
    required this.csgstRate,
    required this.csgstAmount,
    required this.igstAmount,
    required this.totalAmount,
  });

  // This list stores the GST Calculation items on click of 'Add to List' button
  // The items inside this list are used to build the DataRows for the GST DataTable
  List<GSTCalcItem> gstCalcList = [];

  // To add the GST Calculation item to the gstCalcList on click of 'Add to List' button
  void updateGSTCalcList(GSTCalcItem data) {
    gstCalcList.add(data);
  }

  // To clear the gstCalcList on click of 'Clear List' button
  void clearGSTCalcList() {
    gstCalcList.clear();
  }
}

// This class is to store the total amount and used to display in the total row of GST DataTable
class Totals {
  double tNetAmount = 0;
  double tGSTAmount = 0;
  double tCSGSTAmount = 0;
  double tIGSTAmount = 0;
  double tTotalAmount = 0;

  // To ensure commas
  static NumberFormat f = NumberFormat('#,##,###.##', 'en_IN');

  // To replace the commas in Strings and then
  // To convert the string to number
  // To avoid using double.parse & replaceAll many times
  double stringToDouble(String s) {
    // If the gstBreakupOperatorValue is CGST & SGST, then igstAmount value we get from GST Calculator brain using data.igstAmount in addToTotals() method will be ''.
    // '' is considered as Invalid Double for double.parse method
    // So to avoid this Invalid Double error for data.csgstAmount & data.igstAmount, we use the following if condition
    if (s == '') {
      s = '0';
    }
    return double.parse(s.replaceAll(',', ''));
  }

  void addToTotals(GSTCalcItem data) {
    tNetAmount += stringToDouble(data.netAmount ?? '0');
    tGSTAmount += stringToDouble(data.gstAmount ?? '0');
    tCSGSTAmount += stringToDouble(data.csgstAmount ?? '0');
    tIGSTAmount += stringToDouble(data.igstAmount ?? '0');
    tTotalAmount += stringToDouble(data.totalAmount ?? '0');
  }

  // To reset the totals on click of Clear List button
  void reset() {
    tNetAmount = 0;
    tGSTAmount = 0;
    tCSGSTAmount = 0;
    tIGSTAmount = 0;
    tTotalAmount = 0;
  }

  // To return the total amounts with commas
  // 1 - tNetAmount
  // 2 - tGSTAmount
  // 3 - tCSGSTAmount
  // 4 - tIGSTAmount
  // 5 - tTotalAmount
  String tAmountString(int i) {
    // If we do not assign 0, we get 'The non-nullable local variable 'valueToBeFormatted' must be assigned before it can be used.'
    double valueToBeFormatted = 0;
    if (i == 1) {
      valueToBeFormatted = tNetAmount;
    } else if (i == 2) {
      valueToBeFormatted = tGSTAmount;
    } else if (i == 3) {
      valueToBeFormatted = tCSGSTAmount;
    } else if (i == 4) {
      valueToBeFormatted = tIGSTAmount;
    } else if (i == 5) {
      valueToBeFormatted = tTotalAmount;
    }

    // We check if valueToBeFormatted == 0 to avoid showing 0 in the Total row when the totals are 0
    return valueToBeFormatted == 0 ? '' : f.format(valueToBeFormatted);
  }
}
