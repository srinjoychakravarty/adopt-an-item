import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirebaseAuthDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirebaseAuthDemo extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                style: TextStyle(fontSize: 22, color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Email Address",
                  hintStyle: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(fontSize: 22, color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 45,
                child: ElevatedButton(
                    onPressed: () async {
                      final GoogleSignInAccount googleUser =
                          await GoogleSignIn().signIn();
                      final GoogleSignInAuthentication googleAuth =
                          await googleUser.authentication;

                      final OAuthCredential credential =
                          GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken);

                      await FirebaseAuth.instance
                          .signInWithCredential(credential)
                          .then((value) => print('registered'));
                    },
                    child: Text(
                      'Google Signin',
                      style: TextStyle(fontSize: 20),
                    )),
              ),
              SizedBox(
                width: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
