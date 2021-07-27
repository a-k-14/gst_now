import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'custom_widgets.dart';
import 'gst_calculator_brain.dart';

/*
NOTE:
1. Initial Value - 12 digits incl decimal separator and 2 digits after decimal
1. GST Rate - 8 digits incl decimal separator and 2 digits after decimal
TODO: decimals precision - how many and option to set by user
1. keyboard type in iOS and number validations in iOS
2. Suffix %
3. default rate
4. edit rates and change the order
*/

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of application.

  final String title = 'GST Now';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
          // This is the theme of application.
          // primarySwatch: Colors.blueGrey,
          ),
      // home: Test(),
      home: Home(title: title),
    );
  }
}

class Home extends StatelessWidget {
  final String title; // To be used in App Bar

  Home({this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // To enable tap anywhere to dismiss keyboard
      // If we wrap this around body of Scaffold, it does not dismiss keyboard when we tap on some places
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(title, style: TextStyle(color: Colors.black)),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: GSTCalculatorPage(),
      ),
    );
  }
}

class GSTCalculatorPage extends StatefulWidget {
  @override
  _GSTCalculatorPageState createState() => _GSTCalculatorPageState();
}

class _GSTCalculatorPageState extends State<GSTCalculatorPage> {
  // We use TEC instead of onChange as it's the way to clear the TF by click of a button
  static TextEditingController initialValueController = TextEditingController();
  // To set the value in GST Rate text field on click of GST Rate Button
  static TextEditingController gstRateController = TextEditingController();

  // Instance of GST Calculator Brain to perform calculations and get results
  static GSTCalculatorBrain _gstCalculatorBrain = GSTCalculatorBrain(
    initialValue: initialValueController,
    gstRate: gstRateController,
  );

  @override
  void initState() {
    initialValueController.addListener(() {
      // We call setState so that everytime initial value changes, controller will trigger changes like calling compute method
      setState(() {
        // To get updated results everytime initialValue changes
        _gstCalculatorBrain.compute();
      });
    });
    // This is used to make sure the controller works like onChanged method of TextField
    gstRateController.addListener(() {
      setState(() {
        // To get updated results everytime gstRate changes
        _gstCalculatorBrain.compute();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // To ensure we discard any resources used by the controller object
    initialValueController.dispose();
    gstRateController.dispose();
    super.dispose();
  }

  // To set the gstRate into its TextField on click of GST Rate buttons
  // r is the rate of the respective GST Rate button
  gstRateSetter(double r) {
    // We use offset to avoid cursor moving to the beginning of the TextField
    gstRateController.value = TextEditingValue(
      text: r.toString(),
      selection: TextSelection.fromPosition(
        TextPosition(offset: r.toString().length),
      ),
    );
  }

  // To trigger gstOperator changes: 0 - Add GST / 1 - Less GST
  void updateGSTOperator(var v) {
    setState(() {
      _gstCalculatorBrain.gstOperatorSetter(v);
      // To get updated results everytime gstOperator changes
      _gstCalculatorBrain.compute();
    });
  }

  // To trigger gstBreakupOperator changes: 0 - CGST&SGST / 1 - IGST
  void updateGSTBreakupOperator(var v) {
    setState(() {
      _gstCalculatorBrain.gstBreakupOperatorSetter(v);
      // To get updated results everytime gstOperator changes
      _gstCalculatorBrain.compute();
    });
  }

  @override
  // This method is rerun every time setState is called
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // SCS is added to avoid overflow error when keyboard is shown
      padding: EdgeInsets.all(kPadding),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 10, 10, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius - 4),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  // offset: Offset(0, 2),
                  blurRadius: kBorderRadius,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      // To ensure Initial Value and GST Rate take same width
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        'Initial Value',
                        style: TextStyle(
                          fontSize: kTextSize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: initialValueController,
                        // TODO: We use numberWithOptions as iOS may not provide decimal with just number
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        cursorHeight: 22,
                        cursorColor: kAccentColor,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(kRegexpValue),
                          ),
                          // To limit the number of digits
                          // We can use 'maxLength' & 'counterText' alternatively
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          hintText: 'Enter Value...',
                          hintStyle: TextStyle(
                            fontSize: kTextSize - 1,
                            color: kGrey300,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kGrey350,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kAccentColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kSizedBoxHeight + 5),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        'GST Rate',
                        style: TextStyle(fontSize: kTextSize),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        // To set the value on click of GST Rate Button
                        controller: gstRateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(kRegexpValue),
                          ),
                          // To limit the number of digits
                          LengthLimitingTextInputFormatter(9),
                        ],
                        cursorHeight: 22,
                        cursorColor: kAccentColor,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          hintText: 'Enter Rate...',
                          hintStyle: TextStyle(
                            fontSize: kTextSize - 1,
                            color: kGrey300,
                          ),
                          suffix: Text(
                            '%',
                            style: TextStyle(color: kAccentColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kGrey350,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kAccentColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
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
                        GSTRateButton(
                          rate: '1%',
                          onTap: () {
                            return gstRateSetter(1);
                          },
                        ),
                        GSTRateButton(
                          rate: '3%',
                          onTap: () => gstRateSetter(3),
                        ),
                        GSTRateButton(
                          rate: '5%',
                          onTap: () => gstRateSetter(5),
                        ),
                        GSTRateButton(
                          rate: '12%',
                          onTap: () => gstRateSetter(12),
                        ),
                        GSTRateButton(
                          rate: '18%',
                          onTap: () => gstRateSetter(18),
                        ),
                        GSTRateButton(
                          rate: '28%',
                          onTap: () => gstRateSetter(28),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: kAccentColor,
                    ),
                    onPressed: () {
                      setState(() {
                        initialValueController.clear();
                        gstRateController.clear();
                      });
                    },
                    child: Text('Clear All'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: kSizedBoxHeight),
          GSTOperatorTab(
            operatorValues: ['+ Add GST', '- Less GST'],
            f: updateGSTOperator,
          ),
          SizedBox(height: kSizedBoxHeight - 5),
          gstSummary(),
          SizedBox(height: kSizedBoxHeight - 5),
          GSTOperatorTab(
            operatorValues: ['CGST & SGST', 'IGST'],
            f: updateGSTBreakupOperator,
          ),
        ],
      ),
    );
  }

  Widget gstSummary() {
    String netAmount = _gstCalculatorBrain.netAmount;
    String gstRate = _gstCalculatorBrain.rate + '%';
    String gstAmount = _gstCalculatorBrain.gstAmount;
    String totalAmount = _gstCalculatorBrain.grossAmount;
    // String gstOperator = _gstCalculatorBrain.gstOperator();
    String csgstRate = _gstCalculatorBrain.csgstRate;
    String igstRate = _gstCalculatorBrain.igstRate;
    String csgstAmount = _gstCalculatorBrain.csgstAmount;
    String igstAmount = _gstCalculatorBrain.igstAmount;
    String gstBreakupOperator = _gstCalculatorBrain.gstBreakupOperator();

    Widget rowDisplay({Widget title, Widget value, Color color}) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
        ),
        child: Row(
          children: [
            Expanded(child: title, flex: 2),
            Expanded(child: value, flex: 1),
          ],
        ),
      );
    }

    Widget csgstSummary = Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
      alignment: Alignment.centerLeft,
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey[200]),
      // ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CGST @ $csgstRate% = $csgstAmount',
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          Container(
              height: 0, color: Colors.grey[100], padding: EdgeInsets.all(8)),
          Text(
            'SGST @ $csgstRate% = $csgstAmount',
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );

    Widget igstSummary = Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
      alignment: Alignment.centerLeft,
      child: Text(
        'IGST @ $igstRate% = $igstAmount',
        style: TextStyle(
            fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    );

    return Container(
      margin: EdgeInsets.all(10),
      // height: 225,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius - 2),
        border: Border.all(
          color: Color(0x1A8690B1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowDisplay(
            title: Text(
              'Net Amount',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            value: Text(
              netAmount,
              style: TextStyle(fontSize: 16),
            ),
            color: Color(0x1A8690B1),
          ),
          // Container(height: 2, color: Color(0x248690B1)),
          Container(
            color: Color(0x58690B1),
            padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                      'GST @ $gstRate',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    flex: 2),
                Expanded(
                    child: Text(
                      gstAmount,
                      style: TextStyle(fontSize: 16),
                    ),
                    flex: 1),
              ],
            ),
          ),
          Container(
            height: 40,
            color: Color(0x58690B1),
            child: gstBreakupOperator == 'IGST' ? igstSummary : csgstSummary,
          ),
          rowDisplay(
            title: Text('Total Amount',
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            value: Text(
              totalAmount,
              style: TextStyle(
                fontSize: 16,
                color: kAccentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            color: Color(0x1A8690B1),
          ),
        ],
      ),
    );
  }
}
