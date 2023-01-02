

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'autoloadglobals.dart' as globals;

class TimelinePage extends StatefulWidget {
  @override
  _TimelinePageState createState() {
    return _TimelinePageState();
  }
}

class _TimelinePageState extends State<TimelinePage> with AutomaticKeepAliveClientMixin<TimelinePage>{

  bool isLoaded = false;
  bool isLoading = true;

  void makeVisible(){
    setState(() {
      isLoaded = true;
      isLoading = false;
    });
  }


  bool idGot = false;

  bool loaded = false;

  late WebViewController controller;
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Visibility(
                visible: this.isLoaded,
                maintainState: true,
                child: WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: 'https://www.ur-point.com/${globals.userName}',
                  onWebViewCreated: (controller) async {
                    this.controller = controller;
                    controller.loadUrl('https://www.ur-point.com/${globals.userName}');
                  },
                  onPageStarted: (String url) async {
                    isLoaded = false;
                    isLoading = true;
                  },
                  onPageFinished: (String url) async {
                    print('Page finished loading: $url');
                    controller.runJavascript(
                        "document.getElementsByTagName('header')[0].style.display='none'");
                    controller.runJavascript(
                        "document.getElementsByTagName('footer')[0].style.display='none'");
                    controller.runJavascript(
                        'document.querySelector("#contnet > div.page-margin > div > div.sidebar-conatnier.col-md-3.leftcol.sidebar_fixed.no-padding-right > div").style.display="none"');
                    controller.runJavascript(
                        'document.querySelector("#contnet > div.page-margin > div > div.restrictMiddle > div > div.sun_profile_header_area").style.display="none"');
                    controller.runJavascript(
                        'document.querySelector("#publisher-box-focus").style.display="none"');
                    makeVisible();
                  },
                ),
              ),
              isLoading ? Center(child: CircularProgressIndicator(),)
                  : Stack(),
            ],
          )
        )
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin<ProfilePage>{

  bool isLoaded = false;
  bool isLoading = true;

  bool idGot = false;

  bool loaded = false;

  late WebViewController controller;

  void makeVisible(){
    setState(() {
      isLoaded = true;
      isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Visibility(
                visible: this.isLoaded,
                maintainState: true,
                child: WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: 'https://www.ur-point.com/${globals.userName}',
                  onWebViewCreated: (controller) async {
                    this.controller = controller;
                    controller.loadUrl('https://www.ur-point.com/${globals.userName}');
                  },
                  onPageStarted: (String url) async {
                    isLoaded = false;
                    isLoading = true;
                  },
                  onPageFinished: (String url) async {
                    print('Page finished loading: $url');
                    controller.runJavascript(
                        "document.getElementsByTagName('header')[0].style.display='none'");
                    controller.runJavascript(
                        "document.getElementsByTagName('footer')[0].style.display='none'");
                    controller.runJavascript(
                        'document.querySelector("#contnet > div.page-margin > div > div.restrictMiddle").style.display="none"');
                    controller.runJavascript(
                        'document.querySelector("#sortable2").style.display="none"');
                    makeVisible();
                  },
                ),
              ),
              isLoading ? Center(child: CircularProgressIndicator(),)
                  : Stack(),
            ],
          )

        )
    );
  }
}