// import 'package:flutter/cupertino.dart';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'custom_widgets.dart';
import 'gst_calculation_item.dart';
import 'gst_calculator_brain.dart';
import 'gst_summary.dart';

class GSTCalculatorPage extends StatefulWidget {
  const GSTCalculatorPage({Key? key}) : super(key: key);

  @override
  _GSTCalculatorPageState createState() => _GSTCalculatorPageState();
}

class _GSTCalculatorPageState extends State<GSTCalculatorPage> {
  // We use TEC instead of onChange as it's the way to clear the TF by click of a button
  // We used static keyword for TEC and instantiated them in calculator brain object
  // This way we get that a disposed TextEditingController was used
  // So we use setters in setState in initState
  final TextEditingController amountController = TextEditingController();
  // To set the value in GST Rate text field on click of GST Rate Button
  final TextEditingController gstRateController = TextEditingController();
  // To hold the details to be added to the GST DataTable
  // We use it in gstSummary, but we declare it here so that this can be cleared on click of 'Clear All' button
  final TextEditingController detailsController = TextEditingController();
  // To hold gst rates in pop up for edit
  // final TextEditingController getRateOptionController = TextEditingController();

  List<double> gstRatesList = [1, 3, 5, 12, 18, 28];
  // We use this to reset GST rates on click of RESET button in edit rates pop up
  List<double> defaultGSTRatesList = [1, 3, 5, 12, 18, 28];

  // We use this to set new rate in the rate list array
  void updateRate(int index, double newRate) {
    setState(() {
      gstRatesList[index] = newRate;
      // print(gstRatesList);
      // we call this to set new GST rates in local storage
      _setGstRatesList();
    });
  }

  // To store the edited gst rates list to be used when app is opened next time
  void _setGstRatesList() async {
    // Instance of SharedPreference
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // shared prefs stores only few types of data. so we convert the array of doubles to an array strings and then store it
      prefs.setStringList(
          'items', gstRatesList.map((e) => e.toString()).toList());
    });
  }

  // To get the stored GST rates list
  void _loadGstRatesList() async {
    // Instance of SharedPreference
    final prefs = await SharedPreferences.getInstance();
    // print('!ERROR!${prefs.getStringList('items')}');
    if (prefs.getStringList('items') != null) {
      setState(() {
        // Get GST rates list which is stored as list of strings, and then convert that to double
        gstRatesList =
            prefs.getStringList('items')!.map((e) => double.parse(e)).toList();
      });
    }
    // print(prefs.getStringList('items'));
  }

  // We use this to reset GST rates to default
  void resetGstRatesList() {
    // print(gstRatesList);
    setState(() {
      gstRatesList = [...defaultGSTRatesList];
      // print(gstRatesList);
    });
    _setGstRatesList();
    if (isGSTRatesListReverse) {_setIsReversedValue();}
  }

  // To set the sort icon color
  bool isGSTRatesListReverse = false;

  // To get the stored setting value for isGSTRatesListReverse and if null, then assign false to it
  void _loadIsReversedValue() async {
    // Instance of SharedPreference
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Get IsReversedValue and if null assign false to isGSTRatesListReverse
      isGSTRatesListReverse = (prefs.getBool('IsReversedValue') ?? false);
      // Order GST Rates based on isGSTRatesListReverse obtained above
      gstRatesList =
          isGSTRatesListReverse ? gstRatesList.reversed.toList() : gstRatesList;
    });
  }

  // Instance of GST Calculator Brain to perform calculations and get results
  static final GSTCalculatorBrain _gstCalculatorBrain = GSTCalculatorBrain(
      // initialValue: initialValueController,
      // gstRate: gstRateController,
      );

  @override
  void initState() {
    amountController.addListener(() {
      // We call setState so that everytime initial value changes, controller will trigger changes like calling compute method
      setState(() {
        // To get updated results everytime initialValue changes
        _gstCalculatorBrain.amountText = amountController.text;
        _gstCalculatorBrain.compute();
      });
    });
    // This is used to make sure the controller works like onChanged method of TextField
    gstRateController.addListener(() {
      setState(() {
        // To get updated results everytime gstRate changes
        _gstCalculatorBrain.gstRateText = gstRateController.text;
        _gstCalculatorBrain.compute();
      });
    });
    // To get the order of GST Rates list
    _loadIsReversedValue();
    // To get GST rates list
    _loadGstRatesList();
    detailsController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // To ensure we discard any resources used by the controller object
    amountController.dispose();
    gstRateController.dispose();
    detailsController.dispose();
    // getRateOptionController.dispose();
    super.dispose();
  }

  // To store setting value for isGSTRatesListReverse to be used when app is opened next time
  // This is called everytime the swap icon button below GST Rates buttons is clicked
  void _setIsReversedValue() async {
    // Instance of SharedPreference
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Change the isGSTRatesListReverse value to opposite on click of swap icon button
      isGSTRatesListReverse = !isGSTRatesListReverse;
      // store the isGSTRatesListReverse value against IsReversedValue to be used when app is opened next time
      prefs.setBool('IsReversedValue', isGSTRatesListReverse);
    });
  }

  // To set the gstRate into its TextField on click of GST Rate buttons
  // r is the rate of the respective GST Rate button
  gstRateSetter(double r) {
    // We use offset to avoid cursor moving to the beginning of the TextField after setting the rate
    gstRateController.value = TextEditingValue(
      text: r.toString(),
      selection: TextSelection.fromPosition(
        TextPosition(offset: r.toString().length),
      ),
    );
    // To dismiss keyboard on click of GST Rate Button
    FocusScope.of(context).unfocus();
  }

  // To trigger gstOperator changes: 0 - Add GST / 1 - Less GST
  void updateGSTOperator(var v) {
    setState(() {
      _gstCalculatorBrain.gstOperatorSetter(v);
      // To get updated results everytime gstOperator changes
      _gstCalculatorBrain.compute();
    });
    // To dismiss keyboard on click of GST Operator Tab
    FocusScope.of(context).unfocus();
  }

  // To trigger gstBreakupOperator changes: 0 - CGST&SGST / 1 - IGST
  void updateGSTBreakupOperator(var v) {
    setState(() {
      _gstCalculatorBrain.gstBreakupOperatorSetter(v);
      // To get updated results everytime gstOperator changes
      _gstCalculatorBrain.compute();
    });
  }

  // To store the calculations in this object and to use them to generate rows for GST DataTable
  GSTCalcItem gstCalcItem = GSTCalcItem(
    details: '',
    gstRate: '',
    baseAmount: '',
    csgstRate: '',
    csgstAmount: '',
    igstAmount: '',
    totalAmount: '',
    gstBreakupOperator: '',
    gstAmount: '',
  );

  // This is to add a new item to the gstCalcList that is used to build GST DataTable
  void addGSTCalcItem(GSTCalcItem data) {
    setState(() {
      gstCalcItem.updateGSTCalcList(data);
    });
  }

  // This is to clear the gstCalcList and remove the GST DataTable rows
  void clearGSTCalcList() {
    setState(() {
      gstCalcItem.clearGSTCalcList();
    });
  }

  // This is to remove the selected rows from gstCalcList
  void removeSelectedRows(List<GSTCalcItem> selectedRowsToRemove) {
    setState(() {
      gstCalcItem.removeSelectedRows(selectedRowsToRemove);
    });
  }

  void updateDetails(int index, String newDetails) {
    setState(() {
      gstCalcItem.updateDetails(index, newDetails);
    });
  }

  // This is to store the totals of amounts
  // This will be passed to the GST DataTable for using it in Total row
  Totals totals = Totals();

  @override
  // This method is rerun every time setState is called
  Widget build(BuildContext context) {
    // To set the TextFields dense value
    // To set the GST operator tab width
    // To set the SnackBar (share) width
    // To set the details column width of GST DataTable
    final bool wideScreen = MediaQuery.of(context).size.width > wideScreenWidth;

    return SingleChildScrollView(
      // SCS is added to avoid overflow error when keyboard is shown
      padding: EdgeInsets.all(kPadding),
      child: Column(
        children: [
          // This contains - Base Amount, GST Rate, GST Rate Buttons, swap & Clear All
          Container(
            margin: EdgeInsets.only(top: kPadding - 5, bottom: kPadding + 5),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kBorderRadius - 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  // offset: Offset(0, 2),
                  blurRadius: kBorderRadius,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      // To ensure Initial Value and GST Rate take same width
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        'Amount',
                        style: TextStyle(
                          fontSize:
                              wideScreen ? kLargeScreenTextSize : kTextSize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: customTextField(
                        controller: amountController,
                        hintText: 'Enter Amount...',
                        inputLength: 12,
                        wideScreen: wideScreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kSizedBoxHeight + 5),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        'GST Rate',
                        style: TextStyle(
                          fontSize:
                              wideScreen ? kLargeScreenTextSize : kTextSize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: customTextField(
                        controller: gstRateController,
                        hintText: 'Enter Rate...',
                        inputLength: 9,
                        wideScreen: wideScreen,
                        suffix: '%',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GSTRateButton(
                        gstRatesList: gstRatesList,
                        onTap: gstRateSetter,
                      ),
                    ),
                    EditRates(
                      gstRatesList: gstRatesList,
                      updateRate: updateRate,
                      resetGstRatesList: resetGstRatesList,
                      // getRateOptionController: getRateOptionController,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      // margin: kTextButtonContainerMargin, // we do not provide margin as this pushes icon button a little down
                      height: kTextButtonContainerHeight,
                      child: IconButton(
                        tooltip: 'Reverse GST Rates order',
                        // splash is shown behind container. To avoid that we set this
                        splashRadius: 1,
                        icon: Icon(
                          Icons.swap_horiz_rounded,
                          color: isGSTRatesListReverse
                              ? kMainColor
                              : Colors.grey[350],
                        ),
                        onPressed: () {
                          gstRatesList = gstRatesList.reversed.toList();
                          _setIsReversedValue();
                        },
                      ),
                    ),
                    Container(
                      margin: kTextButtonContainerMargin,
                      height: kTextButtonContainerHeight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: kMainColor,
                        ),
                        onPressed: () {
                          setState(() {
                            amountController.clear();
                            gstRateController.clear();
                            detailsController.clear();
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GSTOperatorTab(
            operatorValues: const ['+ Add GST', '- Less GST'],
            wideScreen: wideScreen,
            f: updateGSTOperator,
          ),
          SizedBox(height: kSizedBoxHeight - 2),
          gstSummary(
            gstCalculatorBrain: _gstCalculatorBrain,
            context: context,
            wideScreen: wideScreen,
            addGSTCalcItem: addGSTCalcItem,
            totals: totals,
            detailsController: detailsController,
            f: updateGSTBreakupOperator,
          ),
          // SizedBox(height: kSizedBoxHeight),
          GSTOperatorTab(
            operatorValues: const ['CGST & SGST', 'IGST'],
            wideScreen: wideScreen,
            f: updateGSTBreakupOperator,
          ),
          GSTDataTable(
            gstCalcItemsList: gstCalcItem.gstCalcList,
            clearList: clearGSTCalcList,
            removeSelectedRows: removeSelectedRows,
            updateDetails: updateDetails,
            totals: totals,
          ),
          const GSTTip(),
        ],
      ),
    );
  }
}
