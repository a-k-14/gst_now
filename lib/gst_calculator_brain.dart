import 'package:intl/intl.dart';

/*
 <Role> get data - calc result - return formatted data and formatted result
 <Process>
 Get the baseValueText & gstRate as strings
 Get the gstOperator value via method call. Initial value is 0 - Add GST
 A. Either baseValueText || gstRateText is empty -
  if gstOperator == 0 - Add GST case, then netAmount = baseValue, rate = gstRate, grossAmount = ''
  else gstOperator == 1 - Less GST case, them netAmount = '', rate = gstRate, grossAmount = initialValue
 B. Or it means baseValue & gstRate are not empty -
  if gstOperator == 0 - Add GST case, then netAmount = baseValue, rate = gstRate, grossAmount = baseValue( 1 + gstRate/100)
  if gstOperator == 1 - Less GST case, then rate = gstRate, grossAmount = baseValue, rate = gstRate, netAmount = baseValue( 1 - gstRate / (100 + gstRate) )
*/

class GSTCalculatorBrain {
  // TODO: should I use final here
  String baseAmountText = '';

  /// <GST Rate Text>
  String gstRateText = '';

  // GSTCalculatorBrain({required this.initialValue, required this.gstRate});

  /// <To store the current GST Operator Value: 0 - Add GST / 1- Less GST for calculating the result>
  // Default set to 0 - Add GST
  // TODO: Option for user to set default value in settings
  int gstOperatorValue = 0;

  /// <To store the current GST Breakup Operator Value: 0 - CGST&SGST / 1- IGST for calculating the result>
  // Default set to 0 - CGST&SGST
  // TODO: Option for user to set default value in settings
  int gstBreakupOperatorValue = 0;

  // To set the gstOperatorValue to 0 - Add GST or 1 - Less GST
  void gstOperatorSetter(int i) {
    gstOperatorValue = i;
  }

  // To set the gstBreakupOperatorValue to 0 - Add GST or 1 - Less GST
  void gstBreakupOperatorSetter(int i) {
    gstBreakupOperatorValue = i;
  }

  // Result values to be returned
  String netAmount = '';

  /// <GST Rate to be returned>
  String rate = '';

  /// <Total GST Amount to be returned>
  String gstAmount = '';
  String totalAmount = '';

  // gstAmount breakup
  String csgstAmount = '';
  String igstAmount = '';

  // rate breakup
  String csgstRate = '';
  // String sgstRate = '';
  String igstRate = '';

  // We create following 2 double variables to store the results temporarily for other calculations
  // As we store the above results in String format
  /// <Temporary storage for GST Rate as we use it at multiple places in double format>
  double _rateDouble = 0;

  /// <Temporary storage for GST Amount as we use it at multiple places in double format>
  double _gstAmountDouble = 0;

  // To ensure commas
  // static NumberFormat f = NumberFormat.currency(decimalDigits: 2, name: '', locale: 'en_IN');
  static NumberFormat f = NumberFormat('#,##,###.##', 'en_IN');

  // format method of intl package requires number as input
  // Since some return values in the compute method are strings, we use this method
  // so that we can avoid using double.parse on such strings multiple times in compute method
  static String formatter(String s) {
    // Convert the input string into number as required by the format method
    // We use double.parse to retain the decimal values
    double d = double.parse(s);

    // Return formatted value as a string
    return f.format(d);
  }
  // We use f.format if we have a double, else we use formatter method as above if we have a String

  // The method where all the calculations happen
  void compute() {
    // We convert the TECs to text and store temporarily to avoid doing this conversion multiple times
    // String initialValueText = initialValue.text;
    // String gstRateText = gstRate.text;

    // A
    if (baseAmountText.isEmpty || gstRateText.isEmpty) {
      // As the rate value is not dependent on gstOperator (Add/Less GST),
      // we set its value here instead of twice in the following if and then in else statements
      // We store GST Rate as a number to use for calculating CGST&SGST/IGST rates & amounts
      _rateDouble = gstRateText.isEmpty ? 0 : double.parse(gstRateText);
      // Then we set the rate value using the above rateDouble
      // we check for _rateDouble is equal to 0 to avoid showing 0 when GST Rate entered is empty
      rate = _rateDouble == 0 ? '' : f.format(_rateDouble);

      if (gstOperatorValue == 0) {
        // Add GST case
        netAmount = baseAmountText.isEmpty ? '' : formatter(baseAmountText);

        totalAmount = '';
      } else {
        // Less GST case
        netAmount = '';

        totalAmount = baseAmountText.isEmpty ? '' : formatter(baseAmountText);
      }

      // We are setting _gstAmountDouble as 0 because, when the B executes and we clear all, then the _gstAmountDouble value will be earlier calculated value and this results in CGST, IGST amount variables having last step results as their value are based on _gstAmountDouble. So to clear them we set this as 0
      _gstAmountDouble = 0;

      // As either initialValue or gstRate will be empty we cannot calculate the gstAmount
      gstAmount = '';
    }
    // B
    else {
      // As the rate value is not dependent on gstOperator (Add/Less GST),
      // we set its value here instead of twice in the following if and then in else
      // We do not check for isEmpty here as in A, because this statement will be executed only when
      // both initialValue and gstRate are not empty
      _rateDouble = double.parse(gstRateText);
      rate = f.format(_rateDouble);

      if (gstOperatorValue == 0) {
        // Add GST case
        netAmount = formatter(baseAmountText);

        // We store GST Amount as a number to use for calculating CGST&SGST/IGST
        _gstAmountDouble = double.parse(baseAmountText) * _rateDouble / 100;
        // The we set the gstAmount value using the double above
        gstAmount = f.format(_gstAmountDouble);

        totalAmount = f.format(double.parse(baseAmountText) + _gstAmountDouble);
      } else {
        // Less GST case
        totalAmount = formatter(baseAmountText);

        _gstAmountDouble =
            double.parse(baseAmountText) * (_rateDouble / (_rateDouble + 100));

        gstAmount = f.format(_gstAmountDouble);

        netAmount = f.format(double.parse(baseAmountText) - _gstAmountDouble);
      }
    }
    // Here we set the CGST&SGST/IGST rates and amounts
    if (_rateDouble == 0) {
      csgstRate = '';
      // sgstRate = '';
      igstRate = '';

      csgstAmount = '';
      // sgstAmount = '';
      igstAmount = '';
    } else {
      if (gstBreakupOperatorValue == 0) {
        // CGST&SGST case
        csgstRate = f.format(_rateDouble / 2);
        // sgstRate = cgstRate;
        igstRate = '';

        // We check this condition to avoid showing 0 when _gstAmountDouble is 0/empty
        csgstAmount =
            _gstAmountDouble == 0 ? '' : f.format(_gstAmountDouble / 2);
        igstAmount = '';
      } else {
        // IGST Case
        csgstRate = '';
        // sgstRate = '';
        igstRate = f.format(_rateDouble);

        csgstAmount = '';
        // We check this condition to avoid showing 0 when _gstAmountDouble is 0/empty
        igstAmount = _gstAmountDouble == 0 ? '' : f.format(_gstAmountDouble);
      }
    }
  }

/*  // To return the GST Operator - Add GST for 0 and Less GST for 1
  String gstOperator() {
    return gstOperatorValue == 0 ? 'Add GST' : 'Less GST';
  }*/

  // To return the GST Operator - Add GST for 0 and Less GST for 1
  String gstBreakupOperator() {
    return gstBreakupOperatorValue == 0 ? 'CGST & SGST' : 'IGST';
  }
}
