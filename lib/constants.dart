import 'package:flutter/material.dart';

// This file is to store the constants for the app

Color? kAccentColor = Color(0xff0069e0);

Color? kGrey300 = Colors.grey[300];
Color? kGrey350 = Colors.grey[350];

// To enforce validation on TextFields
// To allow decimal point only once and up to 2 decimal places
// To deny space
String kRegexpValue = r'(^(\d{1,})\.?(\d{0,2}))';

double kBorderRadius = 8;
double kGSTSummaryBorderRadius = 6;

double kSizedBoxHeight = 10;

double kTextSize = 16;

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
Charged when the address of the customer is in same state as your GST registered address.

SGST is also referred as UTGST.
    """;
String igstTip =
    'Charged when the address of the customer is in a different state than your GST registered address.';
