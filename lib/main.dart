import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialising Firebase.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}
  WidgetsFlutterBinding.ensureInitialized();
  //Runs webview.
  runApp(MyApp());

  //Initialising OneSignal
  OneSignal.shared.setAppId("bb459789-7bb7-46cf-b712-15f6ecd564d9");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  var platform = getPlatform();
  print("platform is $platform");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
        home: MainPage(isQR: false, link: 'https://www.ur-point.com/index.php',),
      );
}

class MainPage extends StatefulWidget {
  late final link;
  late final isQR;

  MainPage({required this.isQR, this.link});
  @override
  _MainPageState createState() {
    return _MainPageState();
  }
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
                print("context");
                if(code.contains(new RegExp(r'www.ur-point.com/', caseSensitive: false))) {
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) => new MainPage(
                          isQR: true, link: code)));
                }
              }
                }));
            }
  }

class _MainPageState extends State<MainPage> {
  final qrKey = GlobalKey();

  late WebViewController controller;

  bool idGot = false;
  bool loaded = false;

  late String currentUrl;

  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  get link => widget.link;


  //Webview
  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/urpointlogo.png', fit: BoxFit.cover),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                print("qr here");
                Navigator.push(context, new MaterialPageRoute(builder: (context) {
                  return QrPage(currentUrl);
                }));
              },
              child: Text("QR Code"),

            )
          ],
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CameraPage();
            }));
          },
        ),
          body: WebView(
            //Creates WebView
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'https://www.ur-point.com/',
            onWebViewCreated: (controller) {
              this.controller = controller;
            },

            onPageStarted: (url) async {
              currentUrl = url;
              print(idGot);
              print("link is $link");
              if (widget.isQR == true && loaded == false){
                controller.loadUrl(link);
                loaded = true;
              }
              if (url == homeUrl && idGot == false) {
                controller.loadUrl(userIdUrl);
              }
              if(url.contains(new RegExp(r'www.ur-point.com/ur-photo-booth', caseSensitive: false))){

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

class QrPage extends StatelessWidget {
  late final url;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GenerateQRPage(),
    );
  }
}
class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}
class _GenerateQRPageState extends State<GenerateQRPage> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR GENERATOR'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImage(
                data: controller.text,
                size: 300,
                embeddedImage: AssetImage('assets/urpointlogo.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(80,80)
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Enter URL'),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                    });
                  },
                  child: Text('GENERATE QR')),

            ],
          ),
        ),
      ),
    );
  }
}