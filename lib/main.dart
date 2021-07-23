import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GST Calc',
      theme: ThemeData(
        // This is the theme of application.
        primarySwatch: Colors.blue,
      ),
      home: GSTHomePage(title: 'GST Calc'),
    );
  }
}

class GSTHomePage extends StatefulWidget {
  // This widget is the home page of application.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the MyApp widget) and
  // used by the build method of the State.
  // Fields in a Widget subclass are always marked "final".

  // Title on App Bar
  final String title;

  GSTHomePage({this.title});

  @override
  _GSTHomePageState createState() => _GSTHomePageState();
}

class _GSTHomePageState extends State<GSTHomePage> {
  double padding = 10; // Overall padding and padding in between the widgets
  double textSize = 20;
  double borderRadius = 8;

  // To set the value in GST Rate text field on click of GST Rate Button
  TextEditingController gstRateController = TextEditingController();

  double initialValue = 0;
  // To store the GST rate for calculations
  // double gstRate = 0;

  @override
  void initState() {
    // This is used to make sure the controller works like onChanged method of TextField
    gstRateController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // To ensure we discard any resources used by the controller object
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
    print('$r GST Rate Button clicked');
    print('controller value: ${gstRateController.text}');
    // setState(() {
    //   gstRate = double.parse(gstRateController.text);
    // });
  }

  @override
  // This method is rerun every time setState is called
  Widget build(BuildContext context) {
    return GestureDetector(
      // To enable tap anywhere to dismiss keyboard
      // If we wrap this around body of Scaffold, it does not dismiss keyboard when we tap on some places
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the GSTHomePage object that was created by
          // the App build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
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
                            RegExp(r'(^\d*\.?(\d{0,2}))'),
                          ),
                          // To limit the number of digits
                          // We can use 'maxLength' & 'counterText' alternatively
                          LengthLimitingTextInputFormatter(12),
                        ],
                        onChanged: (value) {
                          setState(() {
                            print(initialValue
                                .toStringAsFixed(0)
                                .replaceFirst('0', '')
                                .isEmpty);
                            print(initialValue
                                .toStringAsFixed(0)
                                .replaceFirst('0', ''));
                            if (value.isNotEmpty) {
                              initialValue = double.parse(value);
                            } else if (value.isEmpty) {
                              initialValue = 0;
                            }
                          });
                        },
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
                                  RegExp(r'(^\d*\.?(\d{0,2}))'),
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
                GSTOperatorTab(),
                gstSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget gstSummary() {
    // This check is to avoid 'Invalid Double' error when the filed is empty
    double rateDouble = gstRateController.text.isEmpty
        ? 0
        : double.parse(gstRateController.text);
    double result = initialValue * rateDouble;

    // Is this optimal
    bool b = initialValue.toStringAsFixed(0).replaceFirst('0', '').isEmpty;

    // To ensure commas
    // var f = NumberFormat.currency(decimalDigits: 2, name: '', locale: 'en_IN');
    var f = NumberFormat('#,##,###.00', 'en_IN');

    return Container(
      color: Colors.lightBlueAccent,
      child: Column(
        children: [
          Text(
            b ? '' : f.format(initialValue),
            style: TextStyle(fontSize: 30),
          ),
          // This is to make sure rate is displayed with decimals
          Text(
            f.format(rateDouble) + '%',
            style: TextStyle(fontSize: 30),
          ),
          Text(
            f.format(result),
            style: TextStyle(fontSize: 30),
          ),
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
      // We have edited const double _kMinSegmentedControlHeight = 45.0; // default - 28.0 in the default files
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlGroupValue,
          // padding: EdgeInsets.all(4),
          children: myTabs,
          // i is the value of myTab{int}
          onValueChanged: (i) {
            setState(() {
              segmentedControlGroupValue = i;
            });
          }),
    );
  }
}
