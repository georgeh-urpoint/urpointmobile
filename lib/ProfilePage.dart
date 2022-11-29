import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:is_first_run/is_first_run.dart';

import 'main.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() {
    return _ProfilePageState();
  }

}

class _ProfilePageState extends State<ProfilePage> {

  late var username = getUserName();

  bool idGot = false;
  bool loaded = false;

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  late WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://www.ur-point.com/$username',
          onWebViewCreated: (controller) {
            this.controller = controller;
          },
        )
    );
  }
}

Future<String?> getUserName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var username = prefs.getString('username');
  return username;
}