import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:is_first_run/is_first_run.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialising Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform);
  //Runs webview.
  runApp(MyApp());

  //Initialising OneSignal
  OneSignal.shared.setAppId("bb459789-7bb7-46cf-b712-15f6ecd564d9");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  var platform = getPlatform();
  print("platform is $platform");
  //Saves user data to phone local storage.
  SharedPreferences prefs = await  SharedPreferences.getInstance();
  bool res = prefs.containsKey('userdata');
  bool firstRun = await IsFirstRun.isFirstRun();
  if(firstRun == false) {
    var data = prefs.getString('userdata');
  }
}

// Function to get the users platform
// Used by UrPoint to get OneSignal notifications working.
String getPlatform(){
  var platform;
  if (Platform.isAndroid) {
    platform = "android";
  } else if (Platform.isIOS) {
    platform = "IOS";
  }
  return platform;
}

bool hideAppBar(){
  bool hide;
  var platform = getPlatform();
  if(platform == "IOS"){
    return false;
  }
  if(platform == "android"){
    return true;
  }
  throw"platform not found";
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
  var user = User(playerId, platform, userid);
  var usermap = user.toMap();

  // Saves user info to users  local storage
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = json.encode(usermap);
  prefs.setString('userdata', data);
  //Generates URL to send info to UrPoint website.
  var url = "https://www.ur-point.com/firestore.php?userid=$userid&platform=$platform&playerid=$playerId";
  return url;
}

class User {
  String player_id;
  String platform;
  String userId;
  //constructor
  User(this.player_id, this.platform, this.userId);

  //Formats user data to be saved to local user storage.
  Map<String, String> toMap() {
    return {
      "player_id": player_id,
      "platform": platform,
      "userId" : userId
    };
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  const MainPage();

  @override
  _MainPageState createState() => _MainPageState();
}

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mobile Scanner'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state as CameraFacing) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) {
              if (barcode.rawValue == null) {
                debugPrint('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue!;
                debugPrint('Barcode found! $code');
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return MainPage();
                }));
              }
            }));
  }
}

void _sendLinkToMain(BuildContext context) {
  String linkToSend = 
}

class _MainPageState extends State<MainPage> {
  late WebViewController controller;

  bool idGot = false;


  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';


  //Webview
  @override
  Widget build(BuildContext context) =>
      Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CameraPage();
            }));
          },
        ),
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
        title: Text("UrPoint")
        ),
          body: WebView(
            //Creates WebView
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'https://www.ur-point.com/',
            onWebViewCreated: (controller) {
              this.controller = controller;
            },

            onPageStarted: (url) async {
              print(idGot);
              if (url == homeUrl && idGot == false) {
                controller.loadUrl(userIdUrl);
              }
            },
            onPageFinished: (url) async {
              //Gets user ID from UrPoint page.
              var getId = await controller.runJavascriptReturningResult("document.getElementById('userid').value");
              var userId = getId.replaceAll('"', '');
              //Creates UrPoint URL with user id.
              var senderUrl = await getUserInfo(userId);
              if (url == userIdUrl && idGot == false) {
                //Sends user data to UrPoint if the user is logging in.
                print("check4");
                print(senderUrl);
                controller.loadUrl(senderUrl);
              }
            },
          )

      );
}