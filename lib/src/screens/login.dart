import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/src/screens/home.dart';
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
            ElevatedButton(
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
                child: Text(
                  'Google Signin',
                  style: TextStyle(fontSize: 20),
                )),
            RaisedButton(
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                child: Text('Sign in'),
                onPressed: () => _signin(_email, _password)),
            RaisedButton(
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: Text('Register'),
              onPressed: () => _signup(_email, _password),
            )
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  child: Text(
                    'Reset Password?',
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
