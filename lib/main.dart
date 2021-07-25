import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calculator_brain.dart';

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

  final String title = 'GST Calc';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        // This is the theme of application.
        primarySwatch: Colors.blue,
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
        appBar: AppBar(
          title: Text(title),
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
  double padding = 10; // Overall padding and padding in between the widgets
  double textSize = 20;
  double borderRadius = 8;

  String regexpValue = r'(^(\d{1,})\.?(\d{0,2}))';

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
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Initial Value',
                  style: TextStyle(
                    fontSize: textSize,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  // We wrap TextField in expanded as TF needs bounded width
                  // and row provides unbounded width
                  child: TextField(
                    keyboardType:
                        // TODO: We use numberWithOptions as iOS may not provide decimal with just number
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      // To allow decimal point only once and up to 2 decimal places
                      // To deny space
                      FilteringTextInputFormatter.allow(
                        RegExp(regexpValue),
                      ),
                      // To limit the number of digits
                      // We can use 'maxLength' & 'counterText' alternatively
                      LengthLimitingTextInputFormatter(12),
                    ],
                    controller: initialValueController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              //  GST Rate segment
              margin: EdgeInsets.only(top: padding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'GST Rate',
                        style: TextStyle(fontSize: textSize),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          // To set the value on click of GST Rate Button
                          controller: gstRateController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            // To allow decimal point only once and up to 2 decimal places
                            // To deny space
                            FilteringTextInputFormatter.allow(
                              RegExp(regexpValue),
                            ),
                            // To limit the number of digits
                            LengthLimitingTextInputFormatter(9),
                          ],
                          decoration: InputDecoration(
                            suffix: Text('%'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    // Contains the SCS with GST Rate Buttons
                    padding: EdgeInsets.all(padding - 3.5),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(30, 118, 118, 128),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    child: SingleChildScrollView(
                      // padding: EdgeInsets.all(padding - 6),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // SizedBox(width: 8),
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
                ],
              ),
            ),
            SizedBox(height: 10),
            GSTOperatorTab(
              operatorValues: ['+ Add GST', '- Less GST'],
              f: updateGSTOperator,
            ),
            gstSummary(),
            GSTOperatorTab(
              operatorValues: ['CGST & SGST', 'IGST'],
              f: updateGSTBreakupOperator,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    initialValueController.clear();
                    gstRateController.clear();
                  });
                },
                child: Text('AC')),
          ],
        ),
      ),
    );
  }

  Widget gstSummary() {
    String netAmount = _gstCalculatorBrain.netAmount;
    String rate = _gstCalculatorBrain.rate + '%';
    String gstAmount = _gstCalculatorBrain.gstAmount;
    String grossAmount = _gstCalculatorBrain.grossAmount;
    String gstOperator = _gstCalculatorBrain.gstOperator();
    String csgstRate = _gstCalculatorBrain.csgstRate;
    String igstRate = _gstCalculatorBrain.igstRate;
    String csgstAmount = _gstCalculatorBrain.csgstAmount;
    String igstAmount = _gstCalculatorBrain.igstAmount;
    String gstBreakupOperator = _gstCalculatorBrain.gstBreakupOperator();

    Widget a = Column(
      children: [
        Text('CGST Rate = $csgstRate%', style: TextStyle(fontSize: 30)),
        Text('SGST Rate = $csgstRate%', style: TextStyle(fontSize: 30)),
        Text('CGST Amount = $csgstAmount', style: TextStyle(fontSize: 30)),
        Text('SGST Amount = $csgstAmount', style: TextStyle(fontSize: 30)),
      ],
    );

    Widget b = Column(
      children: [
        Text('IGST Rate = $igstRate%', style: TextStyle(fontSize: 30)),
        Text('IGST Amount = $igstAmount', style: TextStyle(fontSize: 30)),
      ],
    );

    return Container(
      color: Colors.lightBlueAccent,
      child: Column(
        children: [
          Text(netAmount, style: TextStyle(fontSize: 30)),
          Text(rate, style: TextStyle(fontSize: 30)),
          Text(gstAmount, style: TextStyle(fontSize: 30)),
          Text(grossAmount, style: TextStyle(fontSize: 30)),
          Text(gstOperator, style: TextStyle(fontSize: 30)),
          Container(
            color: Colors.orangeAccent,
            child: gstBreakupOperator == 'IGST' ? b : a,
          ),
          Text(gstBreakupOperator, style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}

class GSTRateButton extends StatelessWidget {
  // To create GST Rate buttons

  // The rate to be displayed on the button
  final String rate;
  // To set the GST rate value into the respective TextField
  final Function onTap;

  GSTRateButton({this.rate, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Width & height given to keep all boxes consistent
      width: 70,
      height: 45,
      margin: EdgeInsets.only(right: 6),
      child: ElevatedButton(
        child: Text(
          rate,
          style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.grey[350],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}

// GST Operator Tab
class GSTOperatorTab extends StatefulWidget {
  // The operator values like Add/Less GST or CGST&SGST/IGST
  final List<String> operatorValues;
  // The function to send the gstOperator value to GST Calculator Brain
  final Function f;

  GSTOperatorTab({this.operatorValues, this.f});

  @override
  _GSTOperatorTabState createState() => _GSTOperatorTabState('a');
}

class _GSTOperatorTabState extends State<GSTOperatorTab> {
  final String s;
  int segmentedControlGroupValue = 0;

  _GSTOperatorTabState(this.s);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container is to enforce width
      width: MediaQuery.of(context).size.width * 0.9,
      // Edited const double _kMinSegmentedControlHeight = 50.0;
      // default - 28.0 in the default files
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlGroupValue,
          // padding: EdgeInsets.all(4),
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
