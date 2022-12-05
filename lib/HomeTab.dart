import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'globals.dart' as globals;
import 'events.dart';
import 'autoloadglobals.dart' as autoload;


void changeUrl(bool, link) {
  new HomeTab(isRedir: bool, link: link, );
}

class HomeTab extends StatefulWidget {
  late final link;
  late final isRedir;

  HomeTab({required this.isRedir, this.link});

  @override
  HomeTabState createState() {
    return HomeTabState();
  }
}

class HomeTabState extends State<HomeTab> {

  final homeUrl = 'https://www.ur-point.com/';
  var currentUrl;

  late WebViewController controller;

  bool isLoading = false;


  @override

  Widget build(BuildContext context) {

    void updateUrl() {
      if(globals.refresh == true){
        globals.refresh = false;
        controller.loadUrl(homeUrl);
      }
      if (currentUrl != globals.currentLink) {
        print("LOADING");
        controller.loadUrl(globals.currentLink);
        currentUrl = globals.currentLink;
      }
    }

    var timer = Timer.periodic(Duration(seconds: 1), (Timer t) => updateUrl());

    return Scaffold(
        body: WebView(
        //Creates WebView
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: homeUrl,
        onWebViewCreated: (controller) {
          this.controller = controller;
          if(widget.isRedir == true){
            print("load qr");
            controller.loadUrl(widget.link);
          }
          globals.currentLink = homeUrl;
          currentUrl = homeUrl;
        },
        onPageFinished: (url) async {
          print(url);
          controller.runJavascript(
              "document.getElementsByTagName('header')[0].style.display='none'");
          controller.runJavascript(
              "document.getElementsByTagName('footer')[0].style.display='none'");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var data = prefs.getString('username');
          print(prefs.getKeys());
          print("username is: $data");
          print("Login Data $data");
          if(data == null){
            print("data not detected, generating data file...");
            var name = await controller.runJavascriptReturningResult("window.document.getElementsByTagName('p')[0].innerHTML;");
            var username = name.replaceAll(RegExp('["@]'), '');
            print("user is: $username");
            prefs.setString('username', username);
            print(prefs.getKeys());
            print("username saved as: ${prefs.getString('username')}");
          }
        },
        onPageStarted: (url) {
          if(url == 'https://www.ur-cards.com/'){
            autoload.isOnCards = Colors.blue;
          }
          globals.currentLink = url;
          controller.runJavascript(
              "document.getElementsByTagName('header')[0].style.display='none'");
          controller.runJavascript(
              "document.getElementsByTagName('footer')[0].style.display='none'");
        },
          onProgress: ,
      ),
    );
}
}