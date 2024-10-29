// import 'dart:ui';

// import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
// This file stores the custom widgets

// To create TextFields for Base Amount & GST Rate
// TODO: Widget or Class? If class, then extends stless or stful?
Widget customTextField({
  required TextEditingController controller,
  required String hintText,
  required int inputLength,
  required bool wideScreen,
  String? suffix,
}) {
  return TextField(
    controller: controller,
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(r'(^(\d{1,})\.?(\d{0,2}))'),
      ),
      // To limit the number of digits
      // To allow decimal point only once and up to 2 decimal places
      // To deny space
      // We can use 'maxLength' & 'counterText' alternatively
      LengthLimitingTextInputFormatter(inputLength),
    ],
    keyboardType: TextInputType.number,
    cursorHeight: 22,
    cursorColor: kMainColor,
    decoration: InputDecoration(
      // Dense only if large screen (width > 600)
      isDense: wideScreen ? false : true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: kTextSize - 1,
        color: Colors.grey[300],
      ),
      // Suffix is only for GST Rate
      suffix: suffix == null
          ? const Text('')
          : Text(suffix, style: TextStyle(color: kMainColor)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          // TODO: Cannot use Colors.grey[350] or Colors.grey.shade350
          color: Color(0xffD6D6D6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kMainColor),
      ),
    ),
  );
}

// To create the GST Rate Buttons
class GSTRateButton extends StatelessWidget {
  // The list of rates to be displayed as buttons
  final List<double> gstRatesList;
  // To set the GST rate value into the GST Rate TextField
  final Function onTap;

  const GSTRateButton(
      {Key? key, required this.gstRatesList, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Contains the SCS with GST Rate Buttons
      padding: EdgeInsets.all(kPadding - 4),
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(22, 118, 118, 128),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (double gstRate in gstRatesList)
              Container(
                // Width & height given to keep all buttons consistent
                // width: 82,
                height: 36,
                // Space between the buttons
                // TODO: The bottom shadow of the buttons is not visible. If we give bottom margin we can see it.
                margin: const EdgeInsets.only(right: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Button color
                    // primary: Colors.white,
                    backgroundColor: Colors.white,
                    // Splash color
                    // onPrimary: Colors.grey[350],
                    foregroundColor: Colors.grey[350],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    onTap(gstRate);
                  },
                  child: Text(
                    '$gstRate%',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// GST Operator Tab to create gstOperator - Add/Less GST and gstBreakupOperator - CGST&SGST/IGST selectors
class GSTOperatorTab extends StatefulWidget {
  // The operator values like Add/Less GST or CGST&SGST/IGST
  final List<String> operatorValues;
  final bool wideScreen;
  // The function to send the gstOperator/gstBreakupOperator value to GST Calculator Brain
  final Function f;

  const GSTOperatorTab(
      {Key? key,
      required this.operatorValues,
      required this.wideScreen,
      required this.f})
      : super(key: key);

  @override
  _GSTOperatorTabState createState() => _GSTOperatorTabState();
}

class _GSTOperatorTabState extends State<GSTOperatorTab> {
  int? segmentedControlGroupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container is to enforce width
      // width:
          // MediaQuery.of(context).size.width * (widget.wideScreen ? 0.5 : 0.93),
      // Edited const double _kMinSegmentedControlHeight = 30.0; default value is - 28.0 in the default files
      // Edited const double _kSegmentMinPadding = 7.25; default value is 9.25
      child: CupertinoSlidingSegmentedControl(
        groupValue: segmentedControlGroupValue,
        // We are using children directly here instead of creating a variable as
        // we get the error The instance member ‘{0}’ can’t be accessed in an initializer
        children: {
          0: Text(widget.operatorValues[0]),
          1: Text(widget.operatorValues[1]),
        },
        // i is the value of myTab{int}
        onValueChanged: (dynamic i) {
          setState(() {
            segmentedControlGroupValue = i;
          });
          widget.f(segmentedControlGroupValue);
        },
      ),
    );
  }
}

// To show GST Tip table on expansion
// We use stateful widget for the Expansion Panel List to work
class GSTTip extends StatefulWidget {
  const GSTTip({Key? key}) : super(key: key);

  @override
  _GSTTipState createState() => _GSTTipState();



}

class _GSTTipState extends State<GSTTip> {


  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[ ExpansionTile(
      collapsedBackgroundColor: const Color(0xfff9f9f9),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
      title: const Text(
        "When to use CGST&SGST vs IGST?",
        style: TextStyle(color: Colors.black45),
      ),
      children: <Widget>[
        gstTipTable(),
      ],),

        ],
    );
  }



  // To build the Tip table
  Widget gstTipTable() {
    // To build the rows of the Tip table
    Widget customTipRow({
      required String tipTitle,
      required String tipValue,
      required Color backgroundColor,
      required BorderRadius borderRadius,
    }) {
      // Custom Tip Row to be returned
      return Container(
        padding: EdgeInsets.all(kPadding - 2),
        decoration: BoxDecoration(
          border: Border.all(color: kGSTSummaryRowBackground1),
          // We take border radius as a parameter as the border corners are different for 1st & 2nd rows
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tipTitle,
                style: kGSTSummaryBreakupTextStyle,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                tipValue,
                style: const TextStyle(
                  color: Colors.grey,
                  wordSpacing: 1,
                ),
              ),
            )
          ],
        ),
      );
    }

    // The Tip table returned by the gstTipTable widget
    // and used inside the Expansion Panel
    // We use outer widget as column to avoid the border created by the container around text
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: kPadding),
          child: Column(
            children: [
              customTipRow(
                tipTitle: 'CGST&SGST\n(Intra-State)',
                tipValue: csgstTip,
                backgroundColor: kGSTSummaryRowBackground1,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(kBorderRadius),
                  topRight: Radius.circular(kBorderRadius),
                ),
              ),
              customTipRow(
                tipTitle: 'IGST\n(Inter-State)',
                tipValue: igstTip,
                backgroundColor: kGSTSummaryRowBackground2,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(kBorderRadius),
                  bottomRight: Radius.circular(kBorderRadius),
                ),
              ),
            ],
          ),
        ),
        // This is placed with the tip table so that it will not stick out in the home screen
        Text(
          '\nMade with Flutter 💙 | akshay',
          textAlign: TextAlign.center,
          style: kGSTSummaryBreakupTextStyle,
        ),
        // SizedBox(height: kSizedBoxHeight - 5),
        TextButton(
          onPressed: () {
            share(shareData: shareAppData);
          },
          style: TextButton.styleFrom(
            foregroundColor: kMainColor,
          ),
          child: const Text('Share the app & spread the word'),
        ),
      ],
    );
  }
}

// To open the link on click of button
void launchURL({required Uri url}) async {
  if (await (canLaunchUrl(url))) {
    await launchUrl(
      url,
      /*
      By default URL is opened in SafariViewController and the problem is that the status bar content - time, network etc. are in white and
      there seems no way to change that. To avoid this, we set 'forceSafariVC: false' so that URL is opened in safari browser and we will not have these status bar content in white color issues.
      There seems to be error with URL launcher package.
      TODO: check if the above error is resolved for url_launcher package
      */
      // forceSafariVC: false,
    );
  } else {
    throw 'Cannot connect. Please try again.';
  }
}

// To show edit button for editing the rates
class EditRates extends StatelessWidget {
  // The list of rates to be displayed as buttons
  final List<double> gstRatesList;
  // To set the GST rate value into the GST Rate TextField
  final Function updateRate;
  final Function resetGstRatesList;

  // final TextEditingController getRateOptionController;

  const EditRates({
    Key? key,
    required this.gstRatesList,
    required this.updateRate,
    required this.resetGstRatesList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      margin: const EdgeInsets.only(left: 6),
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          showDialog(
            context: context,
            // barrierDismissible: false, // user must tap Done button!
            builder: (BuildContext context) {
              return SingleChildScrollView(
                // TODO: Why this and details column width based on wideScreen does not work
                // So we use MediaQuery here directly. Defining it in the start of class also doesn't work?
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width > wideScreenWidth
                        ? 0
                        : 100),
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text('Edit GST Rates'),
                  content: Column(
                    children: [
                      for (int i = 0; i < gstRatesList.length; i++)
                        Container(
                          padding: const EdgeInsets.all(6),
                          // height: 40,
                          child: TextFormField(
                            initialValue: gstRatesList[i].toString(),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'(^(\d{1,})\.?(\d{0,2}))'),
                              ),
                              // To limit the number of digits
                              // To allow decimal point only once and up to 2 decimal places
                              // To deny space
                              // We can use 'maxLength' & 'counterText' alternatively
                              LengthLimitingTextInputFormatter(5),
                            ],
                            keyboardType: TextInputType.number,
                            // controller: getRateOptionController,
                            cursorColor: kMainColor,
                            onChanged: (text) {
                              updateRate(
                                i,
                                text.isEmpty ? 0.0 : double.parse(text),
                              );
                            },
                            cursorHeight: 18,
                            // autofocus: true,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kMainColor)),
                              // filled: true,
                              fillColor: Colors.grey[50],
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius)),
                  actions: [
                    TextButton(
                        onPressed: () {
                          resetGstRatesList();
                          Navigator.of(context).pop();
                          // to avoid keyboard opening and focusing in description field
                          FocusScope.of(context).unfocus();
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: kMainColor),
                        // TODO: Reset function
                        child: const Text('Reset')),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: kMainColor),
                      child: const Text('Done'),
                      onPressed: () {
                        // To update the new details in the row
                        // updateDetails(index, newDetailsController.text);
                        // updateRate(
                        //     1, double.parse(getRateOptionController.text));
                        Navigator.of(context).pop();
                        // to avoid keyboard opening and focusing in description field
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(
          Icons.edit_rounded,
          color: Colors.black54,
          size: 18,
        ),
      ),
    );
  }
}
