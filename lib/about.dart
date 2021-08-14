import 'package:flutter/material.dart';
import 'package:gst_calc/constants.dart';
import 'package:gst_calc/custom_widgets.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & About',
          style: TextStyle(
            color: Color(0xffebf4ff),
          ),
        ),
        elevation: 0,
        brightness: Brightness.dark,
        backgroundColor: Color(0xff0050ab),
        actions: [
          IconButton(
            tooltip: 'Share App',
            iconSize: 22,
            onPressed: () {
              shareApp();
            },
            icon: Icon(
              Icons.share_rounded,
              color: Color(0xffebf4ff),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(kPadding + 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you for checking the app. Here is a quick guide:\n',
              style: aboutPageTextStyle,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 600,
                  maxWidth: 600,
                ),
                child: Image.asset('images/help.png'),
              ),
            ),
            Divider(height: 30),
            Text(
              'About',
              style: TextStyle(fontSize: 18, color: kMainColor),
            ),
            SizedBox(height: kSizedBoxHeight),
            Text(
              '👋 I am Akshay - A Chartered Accountant by profession & a technology enthusiast by passion. '
              'In my pursuit to make complex accounting, finance, & taxation concepts & tasks simple & easy with the help of technology, I\'ve started with this simplest GST Calculator.',
              style: aboutPageTextStyle,
            ),
            SizedBox(height: kSizedBoxHeight - 5),
            Wrap(
              children: [
                Text(
                  'GST Now is made with Flutter',
                  style: aboutPageTextStyle,
                ),
                FlutterLogo(),
                Text(
                  'and is available for Android, iOS (iPhone, iPad, iPod), & macOS.',
                  style: aboutPageTextStyle,
                ),
              ],
            ),
            SizedBox(height: kSizedBoxHeight - 5),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    launchURL(url: kPlayStoreURL);
                  },
                  child: Image.asset(
                    'images/playStore.png',
                    height: 35,
                  ),
                ),
                // SizedBox(width: kSizedBoxHeight),
                TextButton(
                  onPressed: () {
                    launchURL(url: kAppStoreURL);
                  },
                  child: Image.asset(
                    'images/appStore.png',
                    height: 35,
                    // fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: kSizedBoxHeight - 5),
            Wrap(
              children: [
                Text(
                  'Don\'t forget to review the app🙏 & ',
                  style: aboutPageTextStyle,
                ),
                GestureDetector(
                  onTap: () {
                    shareApp();
                  },
                  child: Text(
                    'Spread the word.',
                    style: aboutPageTextStyle.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(' '),
                Text(
                  'If you have any feedback to make this app more purposeful or want to say 👋, we can catch up on ',
                  style: aboutPageTextStyle,
                ),
                ActionChip(
                  label: Text('Twitter'),
                  avatar: Image.asset('images/twitter.png'),
                  backgroundColor: Color(0xffcce4ff),
                  onPressed: () {
                    launchURL(url: 'https://twitter.com/ar36t');
                  },
                ),
                SizedBox(width: kSizedBoxHeight),
                ActionChip(
                  label: Text('Telegram'),
                  avatar: Image.asset('images/telegram.png'),
                  backgroundColor: Color(0xffcce4ff),
                  onPressed: () {
                    launchURL(url: 'https://t.me/gstNow');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
