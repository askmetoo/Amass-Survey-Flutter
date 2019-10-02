import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'scan_page.dart';
import 'auth.dart';
import 'signup_page.dart';

void main() => runApp(MyApp());

const color = Color.fromRGBO(122, 214, 217, 1);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(title: 'Amass'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var authHandler = Auth();

  @override
  void initState() {
    super.initState();

    authHandler.getUser().then((var user) {
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScanPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  _scanPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
  }

  var width = 0.0;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width - 40;

    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            // Box decoration takes a gradient
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Color.fromRGBO(122, 214, 217, 1),
                Color.fromRGBO(146, 220, 226, 1),
                Color.fromRGBO(170, 225, 225, 1),
                Color.fromRGBO(195, 240, 240, 1),
              ],
            ),
            color: color,
          ),
          child: Container(child: _buildCenter(context))),
    );
  }

  Widget _buildCenter(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        child: _column(context),
      ),
    );
  }

  Column _column(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('assets/images/amass.png'),
        Padding(
          padding: EdgeInsets.all(4),
        ),
        _bottomColumn(context)
      ],
    );
  }

  Column _bottomColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 90,
          width: width,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                height: 40,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Email'),
                ),
              ),
              SizedBox(height: 4),
              Container(
                color: Colors.white,
                height: 40,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Password'),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            children: <Widget>[
              Spacer(),
              InkWell(
                child: Text(
                  'Forgot Your Password?',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  print('forgot password clicked');
                },
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 40.0,
            child: RaisedButton(
              color: Colors.white,
              onPressed: () {
                var email = emailController.text;
                var password = passwordController.text;

                authHandler
                    .handleSignInEmail(email, password)
                    .then((var value) {
                  _scanPage();
                });
              },
              child: Text(
                "Login",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              child: Text(
                'Don\'t have an account?',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          child: Align(
            alignment: Alignment.center,
            child: InkWell(
              child: Text(
                'Continue as Guest',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                authHandler.handleSignInAnonymously().then((FirebaseUser user) {
                  _scanPage();
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
