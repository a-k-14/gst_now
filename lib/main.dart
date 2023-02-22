// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
import 'package:flutter/services.dart'; // For Transparent status bar in SystemChrome
import 'about.dart';
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

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of application.

  final String title = 'GST Now';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        // This is the theme of application.
        // primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          //   0xff0069e0 0xff328ce6 0xff0055ab
          backgroundColor: kMainColor,
          elevation: 1,
          titleTextStyle: TextStyle(
            color: kAppBarContentColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ), //  0xffebf1ff
          systemOverlayStyle: SystemUiOverlayStyle.light,
          // To set the action icons & back button color
          iconTheme: IconThemeData(color: kAppBarContentColor),
        ),
      ),
      home: Home(title: title),
    );
  }
}

class Home extends StatefulWidget {
  final String title; // To be used in App Bar

  const Home({Key? key, required this.title}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 10),
                child: const Dropdown(),
              ),
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
                icon: const Icon(Icons.info_outline_rounded),
              ),
              IconButton(
                tooltip: 'Share App',
                iconSize: 22,
                onPressed: () {
                  share(shareData: shareAppData);
                },
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
          body: const GSTCalculatorPage(),
        ),
      ),
    );
  }
}

class Dropdown extends StatefulWidget {
  const Dropdown({Key? key}) : super(key: key);

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  // This is to set the default dropdown value and also to assign new dropdown value on selection
  int dropdownValue = 1;

  @override
  Widget build(BuildContext context) {
    // We edited dropdown.dart to ensure dropdown opens below spinner
    // final double selectedItemOffset = -40 instead of getItemOffset(index);
    return DropdownButton(
      onChanged: (int? selectedValue) {
        setState(() {
          dropdownValue = selectedValue!;
        });
      },
      value: dropdownValue,
      icon: Icon(
        Icons.keyboard_arrow_down_outlined,
        color: Colors.grey[350],
        size: 20,
      ),
      style: TextStyle(color: kAppBarContentColor),
      underline: Container(),
      dropdownColor: const Color(0xff004694),
      borderRadius: BorderRadius.circular(kGSTSummaryBorderRadius),
      elevation: 4,
      items: const [
        DropdownMenuItem(
          value: 1,
          child: Text('India'),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('Other'),
        ),
      ],
    );
  }
}
