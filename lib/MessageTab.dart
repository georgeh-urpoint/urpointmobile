import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'globals.dart' as globals;
import 'autoloadglobals.dart' as autoload;


class MessageTab extends StatefulWidget {

  @override
  MessageTabState createState() {
    return MessageTabState();
  }
}

class MessageTabState extends State<MessageTab> {

  final homeUrl = 'https://www.ur-point.com/messages';
  var currentUrl;

  late WebViewController controller;

  bool isLoading = false;

  @override

  Widget build(BuildContext context) {

    return Scaffold(
      body: WebView(
        //Creates WebView
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: homeUrl,
        onWebViewCreated: (controller) {
          this.controller = controller;
        },
        onPageFinished: (url) async {
          print(url);
          controller.runJavascript(
              "document.getElementsByTagName('header')[0].style.display='none'");
          controller.runJavascript(
              "document.getElementsByTagName('footer')[0].style.display='none'");
        },
        onPageStarted: (url) {
          controller.runJavascript(
              "document.getElementsByTagName('header')[0].style.display='none'");
          controller.runJavascript(
              "document.getElementsByTagName('footer')[0].style.display='none'");
        },
      ),
    );
  }
}