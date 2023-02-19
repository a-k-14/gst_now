import 'dart:io';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'constants.dart';
import 'custom_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  // To set the scroll bar visibility
  final ScrollController scrollController = ScrollController();

  AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // To set the size of help.png & scroll bar visibility
    final bool wideScreen = MediaQuery.of(context).size.width > wideScreenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & About'),
        actions: [
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(kPadding + 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you for checking the app. Here is a quick guide ℹ\n',
              style: aboutPageTextStyle,
            ),
            // Align is to center help.png on bigger screens like ipad or browser
            Align(
              alignment: Alignment.center,
              child: Container(
                height: wideScreen ? 550 : 400,
                decoration: BoxDecoration(
                  color: const Color(0xfffafafa),
                  borderRadius: BorderRadius.circular(kBorderRadius),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: CupertinoScrollbar(
                  // isAlwaysShown: true,
                  controller: scrollController,
                  child: SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Image.asset('images/help.png'),
                          SizedBox(
                            width: 2,
                            height: 200,
                            child: Container(color: Colors.grey[200]),
                          ),
                          Image.asset('images/help2.png'),
                        ],
                      )),
                ),
              ),
            ),
            const Divider(height: 30),
            Text(
              'About',
              style: TextStyle(fontSize: 18, color: kMainColor),
            ),
            SizedBox(height: kSizedBoxHeight),
            Text(
              '👋 I am Akshay - developer of this app. I\'m a Chartered Accountant by profession & a developer by passion. ',
              style: aboutPageTextStyle,
            ),
            // const Divider(),
            Wrap(
              children: [
                Text(
                  'If you have any feedback, please drop a message:',
                  style: aboutPageTextStyle,
                ),
                ActionChip(
                  label: const Text('Email'),
                  avatar: Icon(
                    Icons.email_rounded,
                    color: kMainColor,
                    size: 18,
                  ),
                  backgroundColor: const Color(0xffcce4ff),
                  // here we use url launcher separately instead of using launchURL from custom_widgets.dart (as used for share, app store links) as we have to use try and catch for mailto and not canLaunchUrl, which is only for http/https
                  onPressed: () async {
                    try {
                      await launchUrl(Uri(
                        scheme: 'mailto',
                        path: 'unitedbyc@gmail.com',
                        query: 'subject=App Feedback',
                      ));
                    } catch (e) {
                      throw '!Error!: ${e.toString()}';
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: kSizedBoxHeight - 5),
            Text(
              'Don\'t forget to review⭐ the app',
              style: aboutPageTextStyle,
            ),
            Row(
              children: [
                Platform.isIOS || Platform.isMacOS
                    ? TextButton(
                        onPressed: () {
                          launchURL(url: Uri.parse(kAppStoreURL));
                        },
                        child: Image.asset(
                          'images/appStore.png',
                          height: 35,
                          // fit: BoxFit.cover,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          launchURL(url: Uri.parse(kPlayStoreURL));
                        },
                        child: Image.asset(
                          'images/playStore.png',
                          height: 35,
                        ),
                      ),
                // Added this SizedBox so that the 2 TextButtons have some space on browser
              ],
            ),
          ],
        ),
      ),
    );
  }
}
