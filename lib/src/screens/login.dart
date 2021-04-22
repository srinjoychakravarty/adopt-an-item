import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/src/screens/home.dart';
import 'package:login_app/src/screens/phone.dart';
import 'package:login_app/src/screens/reset.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _email, _password;
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Adoption Centre  ⛏',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: ('Email')),
              onChanged: (value) {
                setState(() {
                  _email = value.trim();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: ('Password')),
              onChanged: (value) {
                setState(() {
                  _password = value.trim();
                });
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton.icon(
              onPressed: () => _signin(_email, _password),
              icon: Icon(Icons.vpn_key_rounded),
              label: Text(
                'Sign In',
                style: TextStyle(color: Colors.black), //white or black
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _signup(_email, _password),
              icon: Icon(Icons.format_list_bulleted_rounded),
              label: Text(
                'Register',
                style: TextStyle(color: Colors.black), //white or black
              ),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
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
                        .then((value) => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => HomeScreen())));
                  } on FirebaseAuthException catch (error) {
                    Fluttertoast.showToast(
                        msg: error.message.toString(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 8,
                        backgroundColor: Colors.brown.shade200,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .blue
                        .shade900)), //Colors.lime.shade700 or blue.shade900
                icon: Icon(
                  Icons.email,
                  color: Colors.white, //white or black
                ),
                label: Text(
                  'Login with Google',
                  style: TextStyle(
                      fontSize: 20, color: Colors.white), //white or black
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PhoneScreen(),
                )),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors
                        .grey
                        .shade900)), //Colors.lime.shade700 or blue.shade900
                icon: Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white, //white or black
                ),
                label: Text(
                  'Login with Phone',
                  style: TextStyle(
                      fontSize: 20, color: Colors.white), //white or black
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  child: Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: Colors.lime.shade700,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ResetScreen(),
                      )))
            ],
          )
        ],
      ),
    );
  }

  _signup(String _email, String _password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);

      // Success
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(
          msg: error.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.brown.shade200,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _signin(String _email, String _password) async {
    try {
      await auth.signInWithEmailAndPassword(email: _email, password: _password);

      // Success
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(
          msg: error.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.brown.shade200,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
