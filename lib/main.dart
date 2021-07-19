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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the GSTHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        // TODO: tap anywhere to dismiss keyboard
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
                      padding: EdgeInsets.all(padding - 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue[300],
                        ),
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      child: SingleChildScrollView(
                        // padding: EdgeInsets.all(padding - 6),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // SizedBox(width: 8),
                            GSTRateButton(rate: '1%'),
                            GSTRateButton(rate: '3%'),
                            GSTRateButton(rate: '5%'),
                            GSTRateButton(rate: '12%'),
                            GSTRateButton(rate: '18%'),
                            GSTRateButton(rate: '28%'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GSTRateButton extends StatelessWidget {
  final String rate; // The rate to be displayed on the button

  GSTRateButton({this.rate}); // Constructor for the GST Rate Button
  @override
  Widget build(BuildContext context) {
    return Container(
      // Width & height given to keep all boxes consistent
      width: 60,
      height: 40,
      margin: EdgeInsets.only(right: 6),
      child: ElevatedButton(
        child: Text(
          rate,
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          print('$rate GST Rate Button clicked');
        },
      ),
    );
  }
}
