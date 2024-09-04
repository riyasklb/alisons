import 'package:flutter/material.dart';
import 'package:task1/screens/login_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login and Home Demo',
      home: LoginPage(),
    );
  }
}
