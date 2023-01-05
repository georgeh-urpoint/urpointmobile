import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart' as globals;
import 'autoloadglobals.dart' as autoload;
import 'main.dart' as main;
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

CookieManager cookieManager = CookieManager.instance();

SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;

late InAppWebViewController webcontroller;
late InAppWebViewController webcontroller2;
late var data;


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

  late var getHashUrl;
  var hashFunc;

  bool scrollButtonShow = false;

  final homeUrl = 'https://www.ur-point.com/';
  var currentUrl;

  bool isLoading = false;

  void scrollToTop() {
    webcontroller.evaluateJavascript(source: "window.scrollTo({top: 0, behavior: 'smooth'});");
    setState(() {
      scrollButtonShow = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    Timer.periodic(Duration(seconds: 5), (timer) async {
      if(globals.hashGot == true) {
        var response = await webcontroller2.evaluateJavascript(
            source: "document.body.innerText");
        print(response);
        webcontroller2.loadUrl(urlRequest: URLRequest(url: Uri.parse('https://www.ur-point.com/requests.php?hash=${globals.hash}&f=update_data')));
        Map<String, dynamic> map = jsonDecode(response);
        print(map.keys);
        print(map['messages']);
        globals.msgNum = map['messages'];
        print(globals.hash);
        int? notifs = int.tryParse(map['notifications']);
        if(notifs == null){
          print("no notifications");
          return;
        }
        if(notifs == 0){
          print('notification number is $notifs');
          globals.notifNum = notifs;
          webcontroller2.loadUrl(urlRequest: URLRequest(url: Uri.parse('https://www.ur-point.com/requests.php?hash=${globals.hash}&f=get_notifications')));
        }
      }
    });

    RefreshController refreshController = RefreshController();
    ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      print('scrolling');
      return null;
    });

    void changeStorage(){
      webcontroller.evaluateJavascript(source: 'document.getElementById("optIn").click()');
    }



    return MaterialApp(
      home: Stack(
        children: [
        InAppWebView(
          onWebViewCreated: (InAppWebViewController controller) {
            webcontroller2 = controller;
        },
          onLoadStop: (webcontroller2, url) async {
            if(url == 'https://www.ur-point.com/requests.php?hash=${globals.hash}&f=get_notifications'){
              print('getting notifications');
              var getNotifs = await webcontroller2.evaluateJavascript(
                  source: "document.body.innerText");
              Map<String, dynamic> map = jsonDecode(getNotifs);
              globals.notiHTML = map['html'];
              print(map['html']);
            }
          },
      ),
          InAppWebView(
                  androidShouldInterceptRequest: (webcontroller, request) async {
                    getHashUrl = await request.url;
                    var url = getHashUrl.toString();
                    //if statement below gets the users hash, required to make requests to the ur-point site
                    if(url.contains('https://www.ur-point.com/requests.php?hash=') && globals.hashGot == false) {
                      print('hash found: $url');
                      hashFunc = url;
                      Cookie? cookie = await cookieManager.getCookie(url: Uri.parse(url), name: 'cookie');
                      print('cookie value is ${cookie!.value}');
                      final response = await http.get(Uri.parse(url));
                      print('response is: $response');
                      final queryParams = response.request?.url.queryParameters;
                      final hash = queryParams!['hash'];
                      if (hash == '') {
                        print('error saving hash, trying again');
                      }
                      if (hash != ''){
                        print('hash is: $hash');
                        globals.hash = hash!;
                        globals.hashGot = true;
                        print('hash saved as: ${globals.hash}');
                        globals.hashGot = true;
                      }
                    }
                  },
                  initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                        useShouldInterceptRequest: true,
                      )
                  ),
                  initialUrlRequest: URLRequest(url: Uri.parse('https://www.ur-point.com')),
                  onWebViewCreated: (controller) {
                    webcontroller = controller;
                    if (widget.isRedir == true) {
                      print("load qr");
                    }
                    globals.currentLink = homeUrl;
                    currentUrl = homeUrl;
                  },
                  onLoadStop: (webcontroller, url) async {
                    webcontroller.evaluateJavascript(source: 'document.querySelector("#publisher-box-focus > div").style.display="none"');
                    webcontroller.evaluateJavascript(
                        source: "document.getElementsByTagName('header')[0].style.display='none'");
                    webcontroller.evaluateJavascript(
                        source:  "document.getElementsByTagName('footer')[0].style.display='none'");
                    // print(notifs);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    var data = autoload.userName;
                    print(prefs.getKeys());
                    print("username is: $data");
                    print("Login Data $data");
                    print("page finished loading $url");
                  },
                  onLoadStart: (webcontroller, url) {
                    webcontroller.evaluateJavascript(
                        source: "document.getElementsByTagName('header')[0].style.display='none'");
                    webcontroller.evaluateJavascript(
                        source: "document.getElementsByTagName('footer')[0].style.display='none'");
                  },
                ),
    ]
              )
    );

  }
}