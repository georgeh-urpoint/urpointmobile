
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'MainPage.dart';
import 'main.dart';
import 'autoloadglobals.dart' as auto;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }

}

class _LoginPageState extends State<LoginPage> {
  bool idGot = false;
  bool loaded = false;

  late String currentUrl;


  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  late CookieManager cookieManager;

  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        //Creates WebView
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: 'https://www.ur-point.com/holding.php',
        onWebViewCreated: (controller) {
          this.cookieManager = CookieManager();
          cookieManager.clearCookies();
          print("cookies cleared.");
          this.controller = controller;
        },

        onPageStarted: (url) async {
          currentUrl = url;
          print(idGot);
          print("url is $currentUrl");
          if(url == 'https://www.ur-point.com/index.php' && idGot == false) {
            print("id not found, running script.");
            controller.loadUrl(userIdUrl);
          }
          if(url == 'https://www.ur-point.com/index.php' && idGot == true) {
            print("pushing to main page");
            Navigator.pushReplacement(context, new MaterialPageRoute(
                builder: (context) => new MainPage(isRedir: false,))
            );
          }
        },
        onPageFinished: (url) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (url == userIdUrl && idGot == false) {
            //Gets user ID from UrPoint page.
            var getId = await controller.runJavascriptReturningResult("document.getElementById('userid').value");
            var getUser = await controller.runJavascriptReturningResult("document.getElementById('username').value");
            var userId = getId.replaceAll('"', '');
            var userName = getUser.replaceAll('"', '');
            auto.userName = userName;
            auto.userId = userId;
            print("go here $getId");
            print("go here $getUser");
            prefs.setString('username', userName);
            //Creates UrPoint URL with user id.
            var senderUrl = await getUserInfo(userId);
            //Sends user data to UrPoint if the user is logging in.
            print("check4");
            print(senderUrl);
            controller.loadUrl(senderUrl);
            idGot = true;
            print("id got: $idGot");
            Navigator.pushReplacement(context, new MaterialPageRoute(
                builder: (context) => new MainPage(isRedir: false,))
            );
          }
        },
      ),
    );
  }
  
}

Future<String> getUserInfo(var userid) async {

  // Gets the user platform
  var platform = getPlatform();

  // Gets the OneSignal PlayerID
  await Future.doWhile(() async {
    var status = await OneSignal.shared.getDeviceState();
    String? osUserID = status?.userId;
    if(osUserID == null){
      return true;
    } else {
      return false;
    }
  });
  var status = await OneSignal.shared.getDeviceState();
  String? osUserID = status?.userId;
  String? playerId = osUserID;

  //Creates a class of the user info
  if(playerId == null){
    playerId = "null";
  }

  // Saves user info to users  local storage
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('playerId', playerId);
  prefs.setString('platform', platform);
  prefs.setString('userId', userid);
  //Generates URL to send info to UrPoint website.
  var url = "https://www.ur-point.com/firestore.php?userid=$userid&platform=$platform&playerid=$playerId";
  prefs.setBool('loggedIn', true);
  return url;
}