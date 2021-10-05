import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

// This file is to store the constants for the app

Color kMainColor = Color(0xff0050ab);
Color kAppBarContentColor = Color(0xffebf4ff);

double kBorderRadius = 8;
double kGSTSummaryBorderRadius = 6;

double kSizedBoxHeight = 10;

double kTextSize = 16;
double kLargeScreenTextSize = kTextSize + 2;

double wideScreenWidth = 600;

// Overall padding and padding in between the widgets
double kPadding = 10;

// Alternating colors for GST summary table
Color kGSTSummaryRowBackground1 = Color(0x1A8690B1);
Color kGSTSummaryRowBackground2 = Color(0x58690B1);
TextStyle kGSTSummaryRowTextStyle1 = TextStyle(
  fontSize: kTextSize,
  color: Colors.grey[700],
);
TextStyle kGSTSummaryRowTextStyle2 = TextStyle(fontSize: kTextSize);
TextStyle kGSTSummaryBreakupTextStyle = TextStyle(
  fontSize: kTextSize - 2,
  color: Colors.grey,
  fontWeight: FontWeight.w500,
);

String csgstTip = """
Charged when the address of the customer is in the same state as your GST registered address.

SGST is also referred to as UTGST.
    """;
String igstTip =
    'Charged when the address of the customer is in a different state than your GST registered address.';

TextStyle aboutPageTextStyle = TextStyle(
  wordSpacing: 0.5,
  fontSize: 15,
  height: 1.25,
  color: Colors.grey[800],
);

String kPlayStoreURL =
    'https://play.google.com/store/apps/details?id=com.resoso.gst_now';
String kAppStoreURL =
    'https://apps.apple.com/us/app/gst-now-simple-gst-calculator/id1579338419';

String shareAppData =
    'Download GST Now - The simplest GST calculator app with CGST, SGST & IGST breakup!⚡'
    '\n\nAndroid\n$kPlayStoreURL'
    '\n\niOS & macOS\n$kAppStoreURL';

// We use shareData as a variable as share method is required to share different data from the app
void share({required String shareData}) {
  Share.share(shareData);
}
