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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(kPadding),
              decoration: BoxDecoration(
                color: const Color(0xffd6f1ff),
                borderRadius: BorderRadius.circular(kBorderRadius)
              ),
              child: Wrap(
                children: [
                  const Text(
                    'If you have any feedback, please drop a message:',
                    style: TextStyle(
                      wordSpacing: 0.5,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Color(0xff0062cf),
                    ),
                  ),
                  ActionChip(
                    side: const BorderSide(width: 0.2),
                    label: const Text('Email', style: TextStyle(color: Color(
                        0xff0062cf)),),
                    avatar: const Icon(
                      Icons.email_rounded,
                      color: Color(0xff0062cf),
                      size: 18,
                    ),
                    backgroundColor: const Color(0xffd6f1ff),

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
            ),
            const SizedBox(height: 15),
            SizedBox(height: kSizedBoxHeight - 5),
            Container(
              padding: EdgeInsets.all(kPadding),
              decoration: BoxDecoration(
                  color: const Color(0xfffff1e0),
                  borderRadius: BorderRadius.circular(kBorderRadius)
              ),
              child: Wrap(
                children: [
                  const Text(
                    'Rate us⭐ on the Playstore',
                    style: TextStyle(
                      wordSpacing: 0.5,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Color(0xffb86d14),
                    ),
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
            const SizedBox(height: 15),
            Container(
              // padding: EdgeInsets.all(kPadding),
              padding: EdgeInsets.all(kPadding),
              decoration: BoxDecoration(
                  color: const Color(0xfff3f5f7),
                  borderRadius: BorderRadius.circular(kBorderRadius)
              ),
              child: const Text(
                  'Made with Flutter 💙 | akshay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    wordSpacing: 0.5,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: Colors.black54,
                  ),
                
                ),

            ),
          ],
        ),
      ),
    );
  }
}
