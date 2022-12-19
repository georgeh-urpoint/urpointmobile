

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'autoloadglobals.dart' as globals;
import 'package:web_view/HomeTab.dart' as home;
import 'package:web_view/ProfilePage.dart' as profile;

late InAppWebViewController webcontroller;

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() {
    return _PostPageState();
  }
}

class _PostPageState extends State<PostPage>{

  var getImage = home.webcontroller.evaluateJavascript(source: 'document.querySelector("#image_to_0 > img")');

  final ButtonStyle style = ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, textStyle: TextStyle(fontSize: 16));
  final ButtonStyle small = ElevatedButton.styleFrom(backgroundColor: Colors.purple, textStyle: TextStyle(fontSize: 12));

  final ImagePicker _picker = ImagePicker();

  bool isLoaded = false;
  bool isLoading = true;

  bool idGot = false;

  bool loaded = false;

  void makeVisible(){
    setState(() {
      isLoaded = true;
      isLoading = false;
    });
  }

  late WebViewController controller;
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: ElevatedButton.icon(
          style: style,
          onPressed: () {
            webcontroller.evaluateJavascript(source: 'document.querySelector("#publisher-button").click()');
            home.webcontroller.reload();
            Navigator.pop(context);

          },
          label: Text('Send'),
          icon: Icon(Icons.send),

        ),
      ),
      body: Stack(
        children: [
          Visibility(
            visible: this.isLoaded,
            maintainState: true,
            child: InAppWebView(
              //Creates WebView
                initialUrlRequest: URLRequest(url: Uri.parse('https://www.ur-point.com')),
                onWebViewCreated: (controller) {
                  webcontroller = controller;
                },
                onLoadStart: (webcontroller, url) async {
                  isLoaded = false;
                  isLoading = true;
                },
                onLoadStop: (webcontroller, url) async {
                  webcontroller.evaluateJavascript(
                      source: "document.getElementsByTagName('header')[0].style.display='none'");
                  webcontroller.evaluateJavascript(
                      source:  "document.getElementsByTagName('footer')[0].style.display='none'");
                  webcontroller.evaluateJavascript(
                      source: "document.querySelector('#firstholder').style.display='none'");
                  webcontroller.evaluateJavascript(
                      source: "document.querySelector('#contnet > div > div > div.restrictMiddle > div > div.posts_load').style.display='none'");
                  webcontroller.evaluateJavascript(
                      source: "document.querySelector('#sortable2').style.display='none'");
                  webcontroller.evaluateJavascript(
                      source: 'document.querySelector("#post-textarea > div > textarea").click()');

                  print('loading finished!');
                  makeVisible();
                  print('$isLoaded $isLoading');
                }
            ),
          ),
          isLoading ? Center(child: CircularProgressIndicator(),)
              : Stack(),
        ],
      )
    );
  }
}