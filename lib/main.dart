import 'package:flutter/material.dart';

import 'package:circular_bar_coffee_app/example_page.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:circular_bar_coffee_app/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(home: Homepage(),);
  }
}



