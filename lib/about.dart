import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gst_calc/constants.dart';
import 'package:gst_calc/custom_widgets.dart';
import 'package:flutter/cupertino.dart';

class AboutPage extends StatelessWidget {
  // To set the scroll bar visibility
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // To set the size of help.png & scroll bar visibility
    final bool wideScreen = MediaQuery.of(context).size.width > wideScreenWidth;

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
              share(shareData: shareAppData);
            },
            icon: Icon(Icons.share_rounded),
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
            // Align is to center help.png on bigger screens like ipad or browser
            Align(
              alignment: Alignment.center,
              child: Container(
                height: wideScreen ? 550 : 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: CupertinoScrollbar(
                  isAlwaysShown: true,
                  controller: scrollController,
                  child: SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Image.asset('images/help.png'),
                          SizedBox(
                            width: 2,
                            child: Container(color: Colors.grey[200]),
                            height: 200,
                          ),
                          Image.asset('images/help2.png'),
                        ],
                      )),
                ),
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
                // The following check is to avoid copyright issues from apple
                Platform.isIOS || Platform.isMacOS
                    ? Text(
                        'with ~2200 lines of code, and is available across operating systems & devices including iPhone, iPad, iPod, & macOS.')
                    : Text(
                        'with ~2200 lines of code, and is available for Android, iOS (iPhone, iPad, iPod), & macOS.',
                        style: aboutPageTextStyle,
                      ),
              ],
            ),
            SizedBox(height: kSizedBoxHeight - 5),
            Platform.isIOS || Platform.isMacOS
                ? ActionChip(
                    label: Text('Get it here'),
                    avatar: Icon(Icons.info_rounded, color: kMainColor),
                    backgroundColor: Color(0xffcce4ff),
                    onPressed: () {
                      launchURL(
                          url: 'https://curiobeing.github.io/GSTNow.app/');
                    },
                  )
                : Row(
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
                      // Added this SizedBox so that the 2 TextButtons have some space on browser
                      SizedBox(width: 5),
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
                    share(shareData: shareAppData);
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
