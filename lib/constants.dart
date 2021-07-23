import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  static double d = 0;
  static TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    editingController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

  Calc calc = Calc(d: d, e: editingController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      d = double.parse(value);
                    } else if (value.isEmpty) {
                      d = 0;
                    }
                  });
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'(^(\d{1,})\.?(\d{0,2}))'),
                  ),
                ],
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: editingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'(^(\d{1,})\.?(\d{0,2}))'),
                  ),
                ],
              ),
              Text(
                'First Text Field Value + 2 = \n${calc.dString()}',
                style: TextStyle(fontSize: 30, color: Colors.purpleAccent),
              ),
              Text(
                calc.eString(),
                style: TextStyle(fontSize: 30, color: Colors.deepOrangeAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Calc {
  final double d;
  final TextEditingController e;

  Calc({this.d, this.e});

  String dString() {
    double result = d + 2;
    return result.toStringAsFixed(0);
  }

  String eString() {
    return e.text;
  }
}
