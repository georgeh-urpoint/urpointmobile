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


SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;
late InAppWebViewController webcontroller;


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
    ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      print('scrolling');
      return null;
    });

    void changeStorage(){
      webcontroller.evaluateJavascript(source: 'document.getElementById("optIn").click()');
    }

    return MaterialApp(
      home: Scaffold(
          body: InAppWebView(
              //Creates WebVie
              androidShouldInterceptRequest: (webcontroller, request) async {
                getHashUrl = await request.url;
                var url = getHashUrl.toString();
                if(url.contains('https://www.ur-point.com/requests.php?hash=')){
                  print('hash found: $url');
                  hashFunc = url;
                  final response = await http.get(Uri.parse(url));
                  print('response is: $response');
                  final queryParams = response.request?.url.queryParameters;
                  final hash = queryParams!['hash'];
                  print('hash is: $hash');
                  if(autoload.hash == null){
                    autoload.hash = hash!;
                  }
                  if(prefs.containsKey('hash') == false){
                    prefs.setString('hash', hash!);
                  }
                  print(prefs.getString('hash'));
                  print('requesting: ${http.get(Uri.parse('https://www.ur-point.com/requests.php?hash=${autoload.hash}&f=update_data&user_id=0&before_post_id=3231&check_posts=false&hash_posts=false&_=1671804930902'))}');
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
      )
    );
  }
}