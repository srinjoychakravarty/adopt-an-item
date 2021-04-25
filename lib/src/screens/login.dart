import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/src/screens/home.dart';
import 'package:login_app/src/screens/reset.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  final auth = FirebaseAuth.instance;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:
          AppBar(title: Text("🔐 Login "), elevation: 0.0, actions: <Widget>[
        TextButton.icon(
          icon: Icon(
            Icons.login_rounded,
            color: Colors.white,
          ),
          label: Text(
            "v0.1.11-a.1",
            style: TextStyle(color: Colors.black, fontSize: 9),
          ),
          onPressed: () {},
        )
      ]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Welcome to Hyper Vision Sale",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                  fontFamily: 'Roboto',
                  fontStyle: FontStyle.italic,
                  color: Colors.teal.shade900)),
          Icon(Icons.store_outlined, size: 369), //replace with image
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
<<<<<<< Updated upstream
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
=======
            ElevatedButton.icon(
              onPressed: () => _signin(_email, _password),
              icon: Icon(Icons.vpn_key_rounded),
              label: Text(
                'Sign In',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _signup(_email, _password),
              icon: Icon(Icons.format_list_bulleted_rounded),
              label: Text(
                'Register',
                style: TextStyle(color: Colors.white),
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue.shade900)),
                icon: Icon(
                  Icons.email_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  'Login with Google',
                  style: TextStyle(fontSize: 20, color: Colors.white),
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey.shade700)),
                icon: Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  'Login with Phone',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            ],
          ),
          Row(
>>>>>>> Stashed changes
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  child: Text(
                    'Reset Password?',
                    style: TextStyle(
                      color: Colors.teal.shade900,
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
      await widget.auth
          .createUserWithEmailAndPassword(email: _email, password: _password);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(
          msg: error.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 60,
          backgroundColor: Colors.brown.shade500,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _signin(String _email, String _password) async {
    try {
      await widget.auth
          .signInWithEmailAndPassword(email: _email, password: _password);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (error) {
      Fluttertoast.showToast(
          msg: error.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 60,
          backgroundColor: Colors.brown.shade500,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
