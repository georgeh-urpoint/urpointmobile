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


  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String _username = await prefs.getString('username').toString();
    return _username;
  }

  bool idGot = false;

  bool loaded = false;

  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://www.ur-point.com',
          onWebViewCreated: (controller) async {
            var username = await getUserName();
            print(username);
            this.controller = controller;
            controller.loadUrl('https://www.ur-point.com/$username');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            controller.runJavascript(
                "document.getElementsByTagName('header')[0].style.display='none'");
            controller.runJavascript(
                "document.getElementsByTagName('footer')[0].style.display='none'");
          },
        )
    );
  }
}