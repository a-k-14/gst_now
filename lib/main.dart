import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Transparent status bar in SystemChrome
import 'package:gst_calc/about.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'custom_widgets.dart';
import 'gst_calculator_brain.dart';

/*
NOTE:
1. Initial Value - 12 digits incl decimal separator and 2 digits after decimal
1. GST Rate - 8 digits incl decimal separator and 2 digits after decimal
TODO: decimals precision - how many and option to set by user
1. Base Value to Base Amount
2.
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
      home: Home(title: title),
    );
  }
}

class Home extends StatelessWidget {
  final String title; // To be used in App Bar

  Home({required this.title});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return GestureDetector(
      // To enable tap anywhere to dismiss keyboard
      // If we wrap this around body of Scaffold, it does not dismiss keyboard when we tap on some places
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      // Added SafeArea to avoid 'Clear All' going behind notch for iPhone
      // Only added for left & right as black bars were shown on top & bottom in portrait mode on iPhones
      // TODO: Need to check in android & iPhone with notch in portrait & landscape modes
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              title,
              style: TextStyle(
                color: kAppBarContentColor,
                //  0xffebf1ff
              ),
            ),
            elevation: 0,
            brightness: Brightness.dark,
            backgroundColor: Color(0xff0050ab),
            //   0xff0069e0 0xff328ce6 0xff0055ab
            actions: [
              IconButton(
                tooltip: 'Help & About',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: kAppBarContentColor,
                ),
              ),
              IconButton(
                tooltip: 'Share App',
                iconSize: 22,
                onPressed: () {
                  shareApp();
                },
                icon: Icon(
                  Icons.share_rounded,
                  color: kAppBarContentColor,
                ),
              ),
            ],
          ),
          body: GSTCalculatorPage(),
        ),
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
  // We used static keyword for TEC and instantiated them in calculator brain object
  // This way we get that a disposed TextEditingController was used
  // So we use setters in setState in initState
  final TextEditingController baseValueController = TextEditingController();
  // To set the value in GST Rate text field on click of GST Rate Button
  final TextEditingController gstRateController = TextEditingController();

  List<double> gstRatesList = [1, 3, 5, 12, 18, 28];
  // To set the sort icon color
  bool isGSTRatesListReverse = false;

  // To get the stored setting value for isGSTRatesListReverse and if null, then assign false to it
  void _loadIsReversedValue() async {
    // Instance of SharedPreference
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Get IsReversedValue and if null assign false to isGSTRatesListReverse
      isGSTRatesListReverse = (prefs.getBool('IsReversedValue') ?? false);
      // Order GST Rates based on isGSTRatesListReverse obtained above
      gstRatesList =
          isGSTRatesListReverse ? gstRatesList.reversed.toList() : gstRatesList;
    });
  }

  // Instance of GST Calculator Brain to perform calculations and get results
  static GSTCalculatorBrain _gstCalculatorBrain = GSTCalculatorBrain(
      // initialValue: initialValueController,
      // gstRate: gstRateController,
      );

  @override
  void initState() {
    baseValueController.addListener(() {
      // We call setState so that everytime initial value changes, controller will trigger changes like calling compute method
      setState(() {
        // To get updated results everytime initialValue changes
        _gstCalculatorBrain.baseAmountText = baseValueController.text;
        _gstCalculatorBrain.compute();
      });
    });
    // This is used to make sure the controller works like onChanged method of TextField
    gstRateController.addListener(() {
      setState(() {
        // To get updated results everytime gstRate changes
        _gstCalculatorBrain.gstRateText = gstRateController.text;
        _gstCalculatorBrain.compute();
      });
    });
    // To get the order of GST Rates list
    _loadIsReversedValue();
    super.initState();
  }

  @override
  void dispose() {
    // To ensure we discard any resources used by the controller object
    baseValueController.dispose();
    gstRateController.dispose();
    super.dispose();
  }

  // To store setting value for isGSTRatesListReverse to be used when app is opened next time
  // This is called everytime the swap icon button below GST Rates buttons is clicked
  void _setIsReversedValue() async {
    // Instance of SharedPreference
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Change the isGSTRatesListReverse value to opposite on click of swap icon button
      isGSTRatesListReverse = !isGSTRatesListReverse;
      // store the isGSTRatesListReverse value against IsReversedValue to be used when app is opened next time
      prefs.setBool('IsReversedValue', isGSTRatesListReverse);
    });
  }

  // To set the gstRate into its TextField on click of GST Rate buttons
  // r is the rate of the respective GST Rate button
  gstRateSetter(double r) {
    // We use offset to avoid cursor moving to the beginning of the TextField after setting the rate
    gstRateController.value = TextEditingValue(
      text: r.toString(),
      selection: TextSelection.fromPosition(
        TextPosition(offset: r.toString().length),
      ),
    );
    // To dismiss keyboard on click of GST Rate Button
    FocusScope.of(context).unfocus();
  }

  // To trigger gstOperator changes: 0 - Add GST / 1 - Less GST
  void updateGSTOperator(var v) {
    setState(() {
      _gstCalculatorBrain.gstOperatorSetter(v);
      // To get updated results everytime gstOperator changes
      _gstCalculatorBrain.compute();
    });
    // To dismiss keyboard on click of GST Operator Tab
    FocusScope.of(context).unfocus();
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
          // This contains - Base Amount, GST Rate, GST Rate Buttons, swap & Clear All
          Container(
            margin: EdgeInsets.only(top: kPadding - 3, bottom: kPadding * 2),
            padding: EdgeInsets.fromLTRB(10, 12, 10, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius - 2),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  // offset: Offset(0, 2),
                  blurRadius: kBorderRadius,
                  spreadRadius: 0,
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
                        'Base Amount',
                        style: TextStyle(
                          fontSize: kTextSize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: customTextField(
                        controller: baseValueController,
                        hintText: 'Enter Amount...',
                        inputLength: 12,
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
                      child: customTextField(
                          controller: gstRateController,
                          hintText: 'Enter Rate...',
                          inputLength: 9,
                          suffix: '%'),
                    ),
                  ],
                ),
                GSTRateButton(gstRatesList: gstRatesList, onTap: gstRateSetter),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      tooltip: 'Reverse GST Rates order',
                      // splash is shown behind container. To avoid that we set this
                      splashRadius: 1,
                      icon: Icon(
                        Icons.swap_horiz_rounded,
                        color: isGSTRatesListReverse
                            ? kMainColor
                            : Colors.grey[350],
                      ),
                      onPressed: () {
                        gstRatesList = gstRatesList.reversed.toList();
                        _setIsReversedValue();
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: kMainColor,
                      ),
                      onPressed: () {
                        setState(() {
                          baseValueController.clear();
                          gstRateController.clear();
                        });
                      },
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GSTOperatorTab(
            operatorValues: ['+ Add GST', '- Less GST'],
            f: updateGSTOperator,
          ),
          SizedBox(height: kSizedBoxHeight),
          gstSummary(_gstCalculatorBrain),
          SizedBox(height: kSizedBoxHeight),
          GSTOperatorTab(
            operatorValues: ['CGST & SGST', 'IGST'],
            f: updateGSTBreakupOperator,
          ),
          GSTTip(),
        ],
      ),
    );
  }
}
