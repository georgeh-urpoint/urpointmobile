import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';

late WebViewController webcontroller;

class MessageTab extends StatefulWidget {

  @override
  MessageTabState createState() {
    return MessageTabState();
  }
}

class MessageTabState extends State<MessageTab> {

  final homeUrl = 'https://www.ur-point.com/messages';
  var currentUrl;


  late TabController tabController;

  bool isLoading = false;



  @override


  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, textStyle: TextStyle(fontSize: 12));

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.black,
            onTap: (index) async {
              SystemChannels.platform.invokeMethod<void>('HapticFeedback.vibrate');
              print(index);
              if(index == 0){
                webcontroller.runJavascript('document.querySelector("#wo_msg_left_prt > form > ul > li:nth-child(1) > a").click()');
              }
              if(index == 1){
                webcontroller.runJavascript('document.querySelector("#groups-message-tab").click()');
              }
            },
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Users',icon: Icon(Icons.person_rounded),),
              Tab(text: 'Groups',icon: Icon(Icons.group),),
              ElevatedButton.icon(
                onPressed: () {
                webcontroller.runJavascript('document.querySelector("#groups-message > div.msg_mrk_rd > span").click()');
              },
                style: style,
                icon: Icon(Icons.add),
                label: Text('New Group'),
              )
            ],
          ),
          body: WebView(
            //Creates WebView
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: homeUrl,
            onWebViewCreated: (controller) {
              webcontroller = controller;
            },
            onPageFinished: (url) async {
              print(url);
              webcontroller.runJavascript(
                  "document.getElementsByTagName('header')[0].style.display='none'");
              webcontroller.runJavascript(
                  "document.getElementsByTagName('footer')[0].style.display='none'");
              webcontroller.runJavascript('document.querySelector("#groups-message > div.msg_mrk_rd").style.display="none"');
              webcontroller.runJavascript('document.querySelector("#wo_msg_left_prt > form > ul").style.display="none"');
              webcontroller.runJavascript('document.querySelector("#wo_msg_left_prt > form > div.form-group.inner-addon.left-addon.messages-search-icon").style.visibility="hidden"');
            },
            onPageStarted: (url) {
              webcontroller.runJavascript(
                  "document.getElementsByTagName('header')[0].style.display='none'");
              webcontroller.runJavascript(
                  "document.getElementsByTagName('footer')[0].style.display='none'");
            },
          ),
        ),

      ),
    );
  }
}