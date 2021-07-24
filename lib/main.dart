import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calculator_brain.dart';
import 'constants.dart';

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

  const Home({this.title});

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

  // To store the GST rate for calculations
  // double gstRate = 0;

  static GSTCalculatorBrain _gstCalculatorBrain = GSTCalculatorBrain(
    // initialValue: initialValueController,
    gstRate: gstRateController,
    currentGSTOperator: currentGSTOperator,
  );

  @override
  void initState() {
    print('init called');
    initialValueController.addListener(() {
      setState(() {});
    });
    // This is used to make sure the controller works like onChanged method of TextField
    gstRateController.addListener(() {
      setState(() {});
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

  gstRateSetter(double r) {
    /*
    To avoid calling setState in every GSTRateButton we use this
    r is the rate of the respective button
    Here we set the value of gstRateController when the GST Rate Button is clicked
    The controller in turn display the value inside the TextField
    We set this outside setState so that we can avoid rebuilds
    Also, this works outside setState
    We use TextEditingValue and offset to get around the issue that cursor will be at the
    beginning when we click the GST Rate Button and the set the value inside the
    GST Rate TextField
    */
    gstRateController.value = TextEditingValue(
      text: r.toString(),
      selection: TextSelection.fromPosition(
        TextPosition(offset: r.toString().length),
      ),
    );
  }

  static int currentGSTOperator;
  void test(var d) {
    setState(() {
      currentGSTOperator = d;
      _gstCalculatorBrain.currentGSTOperator = d;
      print(currentGSTOperator);
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
                    // maxLength: 10,
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
                      // counterText: '',
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
                // crossAxisAlignment: CrossAxisAlignment.start,
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
            GSTOperatorTab(f: test),
            gstSummary(),
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
    String fInitialValue =
        _gstCalculatorBrain.formatInitialValue(initialValueController.text);
    String fGSTRate = _gstCalculatorBrain.formatGSTRate();
    String result = _gstCalculatorBrain.result();
    String gstOperator = _gstCalculatorBrain.gstOperator();

    return Container(
      color: Colors.lightBlueAccent,
      child: Column(
        children: [
          Text(fInitialValue, style: TextStyle(fontSize: 30)),
          Text(fGSTRate, style: TextStyle(fontSize: 30)),
          Text(result, style: TextStyle(fontSize: 30)),
          Text(gstOperator, style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}

class GSTRateButton extends StatelessWidget {
  // To create GST Rate buttons
  final String rate; // The rate to be displayed on the button
  final Function onTap; // To set the GST rate value

  GSTRateButton({this.rate, this.onTap}); // Constructor for the GST Rate Button
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
          // onSurface: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // style: ButtonStyle(
        //   backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        // ),
        onPressed: onTap,
      ),
    );
  }
}

// GST Operator Tab
class GSTOperatorTab extends StatefulWidget {
  final Function f;

  const GSTOperatorTab({this.f});

  @override
  _GSTOperatorTabState createState() => _GSTOperatorTabState();
}

class _GSTOperatorTabState extends State<GSTOperatorTab> {
  int segmentedControlGroupValue = 0;
  final Map<int, Widget> myTabs = {
    0: Text("+ Add GST"),
    1: Text("- Less GST"),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container is to enforce width
      width: MediaQuery.of(context).size.width * 0.9,
      // Edited const double _kMinSegmentedControlHeight = 45.0; // default - 28.0 in the default files
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlGroupValue,
          // padding: EdgeInsets.all(4),
          children: myTabs,
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
