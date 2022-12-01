import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ProfilePage.dart';
import 'main.dart';
import 'MainPage.dart';
import 'globals.dart' as globals;
import 'events.dart';
import 'package:flutter/services.dart';

typedef void Listener(String);
typedef void CancelListening();


CancelListening startListening(Listener listener) {
  var subscription = channel.receiveBroadcastStream(
  ).listen(listener, cancelOnError: true);
  return () {
    subscription.cancel();
  };
}


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



  var initLink;


  ValueNotifier<String> linkCheck = ValueNotifier(globals.currentLink);

  late WebViewController controller;

  bool isLoading = false;

  @override

  Widget build(BuildContext context) {

    if(widget.isRedir == true){
      initLink = widget.link;
    } else{
      initLink = "https://www.ur-point.com/";
    }

    ValueListenableBuilder<String>(
      valueListenable: linkCheck,
      builder: (context, value, child) {
        controller.loadUrl(globals.currentLink);
        print("url seen");
        throw "";
      }
    );




    return Stack(
      children: [
        ValueListenableBuilder<String>(
            valueListenable: linkCheck,
            builder: (context, value, child) {
              controller.loadUrl(globals.currentLink);
              print("url seen");
              throw "";
            }
        ),
        WebView(
        //Creates WebView
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: initLink,
        onWebViewCreated: (controller) {

          print("check here for ${linkCheck.hasListeners}");
          this.controller = controller;
          if(widget.isRedir == true){
            print("load qr");
            controller.loadUrl(widget.link);
          }
        },
        onPageFinished: (url) async {
          controller.runJavascript(
              "document.getElementsByTagName('header')[0].style.display='none'");
          controller.runJavascript(
              "document.getElementsByTagName('footer')[0].style.display='none'");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var name = await controller.runJavascriptReturningResult("window.document.getElementsByTagName('p')[0].innerHTML;");
          var username = name.replaceAll(RegExp('["@]'), '');
          print("user is: $username");
          var data = prefs.containsKey('username');
          if(data == false){
            print("data not detected, generating data file...");
            prefs.setString('username', username);
            print(prefs.getKeys());
            print("username saved as: ${prefs.getString('username')}");
          }
        },
        onPageStarted: (url) {
          controller.runJavascript(
              "document.getElementsByTagName('header')[0].style.display='none'");
          controller.runJavascript(
              "document.getElementsByTagName('footer')[0].style.display='none'");
        },
      ),
    ]
    );

}
}