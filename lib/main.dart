import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Transparent status bar in SystemChrome
import 'package:gst_calc/about.dart';
import 'constants.dart';
import 'gst_calculatorPage.dart';

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
        appBarTheme: AppBarTheme(
          // To set the action icons & back button color
          iconTheme: IconThemeData(color: kAppBarContentColor),
        ),
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
                icon: Icon(Icons.info_outline_rounded),
              ),
              IconButton(
                tooltip: 'Share App',
                iconSize: 22,
                onPressed: () {
                  share(shareData: shareAppData);
                },
                icon: Icon(Icons.share_rounded),
              ),
            ],
          ),
          body: GSTCalculatorPage(),
        ),
      ),
    );
  }
}
