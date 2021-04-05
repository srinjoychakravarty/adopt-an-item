import 'package:flutter/material.dart';
import 'package:login_app/src/screens/login.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        accentColor: Colors.brown.shade300,
        primarySwatch: Colors.lime,
      ),
      home: LoginScreen(),
    );
  }
}