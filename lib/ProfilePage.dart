

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'autoloadglobals.dart' as globals;

var userName = globals.userName;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() {
    return _ProfilePageState();
  }

}

class _ProfilePageState extends State<ProfilePage> {

  bool idGot = false;

  bool loaded = false;

  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://www.ur-point.com/$userName',
          onWebViewCreated: (controller) async {
            this.controller = controller;
            controller.loadUrl('https://www.ur-point.com/$userName');
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