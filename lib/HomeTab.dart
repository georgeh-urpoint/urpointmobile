import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'globals.dart' as globals;
import 'autoloadglobals.dart' as autoload;
import 'main.dart' as main;

late WebViewController webcontroller;

void scrollToTop() {
  webcontroller.runJavascript("window.scrollTo({top: 0, behavior: 'smooth'});");
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

  final homeUrl = 'https://www.ur-point.com/';
  var currentUrl;

  bool isLoading = false;

  bool scrollButtonShow = true;

  void floatingButtonVisibility() async {
    int y = await webcontroller.getScrollY();
    if (y > 50) {
      setState(() {
        scrollButtonShow = true;
      });
    } else {
      setState(() {
        scrollButtonShow = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    void changeStorage(){
      webcontroller.runJavascript('document.getElementById("optIn").click()');
    }

    return MaterialApp(
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Visibility(
            visible: scrollButtonShow,
            child: FloatingActionButton.extended(
              label: Text('Return to Top'),
              icon: Icon(Icons.navigation),
              onPressed: () {
                scrollToTop();

              },
              backgroundColor: Colors.purple,
            ),
          )
        ),
        body: GestureDetector(
          onVerticalDragUpdate: (details) {
            print('scrolling ${details.globalPosition}');
            floatingButtonVisibility();
            String scrollInfo = details.toString();
            webcontroller.scrollBy(details.localPosition.dx.toInt(), details.localPosition.dy.toInt());
          },
          child: WebView(
            //Creates WebView
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: homeUrl,
            onWebViewCreated: (controller) {
              webcontroller = controller;
              if (widget.isRedir == true) {
                print("load qr");
                controller.loadUrl(widget.link);
              }
              globals.currentLink = homeUrl;
              currentUrl = homeUrl;
            },
            javascriptChannels: {
              JavascriptChannel(
                  name: 'scrollEventChannel',
                  onMessageReceived: (JavascriptMessage message) {
                    if(message.message == 0){
                      print("scroll event: $message");
                      setState(() {
                        scrollButtonShow = false;
                      });
                    }
                  }
              )
            },
            onPageFinished: (url) async {
              // var notifs = await controller.runJavascriptReturningResult(
              //   'document.querySelector("#head_menu_rght > li.dropdown.messages-notification-container > span").firstChild.data');
              //var notifString = notifs.toString();
              // var notif = await notifString.replaceAll(RegExp('[^0-9]'), '');
              // print('Without RegExp $notifs');
              // print('With RegExp $notif');
              // var intnotif = int.parse(notif);
              // if(intnotif != 0){
              //    globals.msgNum = intnotif;
              //  }
              // var msgs = await controller.runJavascriptReturningResult('document.querySelector("#head_menu_rght > li.dropdown.messages-notification-container > span").firstChild.data');
              //  var msg = await notifs.replaceAll(RegExp('[^0-9]'), '');
              //   var msgString = msgs.toString();
              // print('Without RegExp msg $msgs');
              //  print('With RegExp msg $msg');
              //  var intmsg = int.parse(msg);
              // print('num of messages = $intmsg');
              // if(intmsg != 0){
              //   globals.msgNum = intmsg;
              //    print(globals.msgNum);
              // }
              // print(url);
              webcontroller.runJavascript(
                  "document.getElementsByTagName('header')[0].style.display='none'");
              webcontroller.runJavascript(
                  "document.getElementsByTagName('footer')[0].style.display='none'");
              // print(notifs);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var data = autoload.userName;
              print(prefs.getKeys());
              print("username is: $data");
              print("Login Data $data");
              print("page finished loading $url");
            },
            onPageStarted: (url) {
              globals.currentLink = url;
              webcontroller.runJavascript(
                  "document.getElementsByTagName('header')[0].style.display='none'");
              webcontroller.runJavascript(
                  "document.getElementsByTagName('footer')[0].style.display='none'");
            },
          ),
        )
      ),
    );
  }
}