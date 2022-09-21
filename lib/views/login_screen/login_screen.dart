import 'package:celebify/database/auth_methods.dart';
import 'package:celebify/utils/constants.dart';
import 'package:celebify/views/home_screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoginPressed ? loader1 :Center(child: loginButton()),
    );
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: shadeColor,
      child: TextButton(
        onPressed: () => performLogin(),
        style: TextButton.styleFrom(shape:  RoundedRectangleBorder(
          borderRadius:  BorderRadius.circular(10.0),
        ),),
        child: Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: const Text(
            "LOGIN",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }

  ///this is performing login with google
  void performLogin() {

    setState(() {
      isLoginPressed =true;
    });

    _authMethods.signInWithGoogle(context).then((UserCredential? userCredential) {
      User? user = userCredential!.user;
      if (user != null) {
        authenticateUser(user);
      } else {
        // print("There was an error");
      }
    });
  }

  ///this is authenticating user if it is new or signed in previously also, if new -> add them to DB
  void authenticateUser(User user) {
    _authMethods.authenticateUser(user).then((isNewUser) {

      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _authMethods.addDatatoDB(user, context).then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        });
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }
}