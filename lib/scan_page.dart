import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'auth.dart';
import 'survey_page.dart';

const color = Color.fromRGBO(122, 214, 217, 1);

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => new _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String barcode = "";

  var authHandler = Auth();
  @override
  initState() {
    super.initState();

    // scan();
  }

  _pushToSurveyPage() {
    //print('-Lq0QlnrelUNA4BXTKcY');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SurveyPage(
                surveyKey: '-Lq26B7ACnOsTS337Fu1',
              )),
    );
  }

  var isGuest = false;
  var isUserchecked = false;

  @override
  Widget build(BuildContext context) {
    if (!isUserchecked) {
      authHandler.getUser().then((var user) {
        setState(() {
          isUserchecked = true;
          isGuest = user.isAnonymous;
        });
      });
    }

    return Scaffold(
        appBar: new AppBar(
          backgroundColor: color,
          title: new Text(
            'Amass',
            style: TextStyle(color: Colors.white),
          ),
          leading: Container(),
          actions: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: InkWell(
                  child: Text(
                    isGuest ? 'Back' : 'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    authHandler.logout().then((var value) {
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
            )
          ],
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                  color: color,
                  textColor: Colors.white,
                  splashColor: color,
                  onPressed: () {
                    scan(context);
                    //_pushToSurveyPage();
                  },
                  child: const Text('Start QR Scan'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  barcode,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ));
  }

  Future scan(context) async {
    try {
      String barcode = await BarcodeScanner.scan();
      //setState(() => this.barcode = barcode);
      print(barcode);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SurveyPage(
                  surveyKey: barcode,
                )),
      );
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'Camera Permission Required!';
        });
      } else {
        setState(() => this.barcode = '$e');
      }
    } on FormatException {
      setState(() => this.barcode = 'Unable to capture QR Code');
    } catch (e) {
      setState(() => this.barcode = '$e');
    }
  }
}
