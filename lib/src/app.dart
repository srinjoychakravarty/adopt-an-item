import 'package:flutter/material.dart';
import 'package:login_app/src/screens/login.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Item Adoption',
      theme: ThemeData(
        accentColor: Colors.brown.shade300,
        primarySwatch: Colors.teal,
      ),
      home: LoginScreen(),
    );
  }
}
