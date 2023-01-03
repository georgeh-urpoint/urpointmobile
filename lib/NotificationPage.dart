import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'globals.dart' as globals;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

late InAppWebViewController webcontroller;

class NotiPage extends StatefulWidget {
  @override
  _NotiPageState createState() {
    return _NotiPageState();
  }
}

class _NotiPageState extends State<NotiPage> {
  late PageController _pageController;
  int _currentPage = 0;
  late Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Stack(children: [
      InAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse(
                'https://www.ur-point.com/requests.php?hash=cb58c376c77fa09772e5&f=get_notifications')),
        onWebViewCreated: (InAppWebViewController controller) {
          webcontroller = controller;
        },
        onLoadStop: (webcontroller, url) async {
            print('getting notifications');
            var getNotifs = await webcontroller.evaluateJavascript(
                source: "document.body.innerText");
            map = jsonDecode(getNotifs);
            globals.notiHTML = map['html'];
            print('printing ${map['html']}');
        },
      ),
          HtmlWidget(
            map['html']
          )
    ]));
  }
}
