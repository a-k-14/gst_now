import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  // This widget is the home page of your application.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the MyApp widget) and
  // used by the build method of the State.
  // Fields in a Widget subclass are always marked "final".

  final String title;

  GSTHomePage({this.title});

  @override
  _GSTHomePageState createState() => _GSTHomePageState();
}

class _GSTHomePageState extends State<GSTHomePage> {
  double padding = 10; // Overall padding and padding in between the widgets
  double textSize = 20;
  double borderRadius = 8;

  double initialValue = 0;
  // To store the GST rate for calculations
  double gstRate = 0;
  // To set the value in GST Rate text field on click of GST Rate Button
  TextEditingController gstRateController = TextEditingController();

  // To avoid calling setState in every GSTRateButton we use this
  // r is the rate of the respective button
  gstRateSetter(double r) {
    /*
    We set this outside setState so that we can avoid rebuilds
    Also, this works outside setState
    We use TextEditingValue to get around the issue that cursor will be at the
    beginning when we click the GST Rate Button and the set the value inside the
    GST Rate TextField
    */
    // gstRateController.value = TextEditingValue(
    //   text: r.toInt().toString(),
    //   selection: TextSelection.fromPosition(
    //     TextPosition(offset: r.toInt().toString().length),
    //   ),
    // );
    print('$r GST Rate Button clicked');
    gstRateController.text = r.toInt().toString();
    print('controller value: ${gstRateController.text}');
    setState(() {
      gstRate = double.parse(gstRateController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return GestureDetector(
      // To enable tap anywhere to dismiss keyboard
      // If we wrap this around body of Scaffold, it does not dismiss keyboard when we tap on some places
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the GSTHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
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
                        keyboardType: TextInputType.number,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                SingleChildScrollView(child: GSTOperatorTab()),
                Text(gstRate.toString()),
              ],
            ),
          ),
        ),
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
