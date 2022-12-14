import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

//Program script imports
import 'package:web_view/LoginPage.dart';
import 'package:web_view/MainPage.dart';
import 'package:web_view/globals.dart' as globals;
import 'autoloadglobals.dart' as autoload;
import 'package:web_view/HomeTab.dart' as home;
import 'package:web_view/CardsUI.dart' as card;

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
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.deepPurple, // navigation bar color
    statusBarColor: Colors.deepPurple, // status bar color
  ));
  autoload.loadUserData();
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

  //Generates URL to send info to UrPoint website.
  var url = "https://www.ur-point.com/firestore.php?userid=$userid&platform=$platform&playerid=$playerId";
  print("get url here $url");
  return url;
}

class User {
  String player_id;
  String platform;
  String userId;
  String? userName;
  //constructor
  User(this.player_id, this.platform, this.userId, this.userName);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        home: LoadingPage(),
      );
  }
}

class LoadingPage extends StatelessWidget {
  late WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: 'https://www.ur-point.com/index.php',
        onWebViewCreated: (controller) async {
          var check = await autoload.loadData();
          print("Login Status: $check");
          if(check == false) {
            Navigator.pushReplacement(context, new MaterialPageRoute(
                builder: (context) => new LoginPage()
            ));
          } else{
            Navigator.pushReplacement(context, new MaterialPageRoute(
                builder: (context) => new MainPage(isRedir: false,)
            ));
          }
      },
        onPageStarted: (url) {
          print(url);
        }
        ,
      ),
    );
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
          title: const Text('QR Code Scanner'),
          backgroundColor: Colors.deepPurpleAccent,
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
                  Navigator.pushReplacement(context, new MaterialPageRoute(
                      builder: (context) => new MainPage(
                          isRedir: true, link: code)));
                }
              }
                }));
            }
  }




class GenerateQRPage extends StatefulWidget {
  late final url;

  GenerateQRPage({this.url});

  _GenerateQRPageState createState() {
    return _GenerateQRPageState();
  }
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  TextEditingController controller = TextEditingController();
  final key = GlobalKey();


  File? file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR GENERATOR'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: key,
                child: Container(
                  color: Colors.white,
                  child: QrImage(
                    data: widget.url,
                    size: 360,
                    padding: EdgeInsets.all(16),
                    backgroundColor: Colors.white,
                    embeddedImage: AssetImage('assets/QrEmbedUrPoint.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(80, 80)
                    ),
                  ),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple
                ),
                  onPressed: () async {
                    RenderRepaintBoundary boundary =
                      key.currentContext?.findRenderObject() as RenderRepaintBoundary;
                    var image = await boundary.toImage();
                    ByteData byteData = await image.toByteData(format: ImageByteFormat.png) as ByteData;
                    Uint8List pngBytes = byteData.buffer.asUint8List();
                    final tempDir = await getTemporaryDirectory();
                    final file = await new File('${tempDir.path}/image.png').create();
                    await file.writeAsBytes(pngBytes);
                    showToast("QR Saved Successfully");
                    print("qr saved");
                  },
                  child: Text('Save QR Invite')),
              ElevatedButton(
                  onPressed: () async {
                    final tempDir = await getTemporaryDirectory();
                    var path = XFile('${tempDir.path}/image.png');
                    Share.shareXFiles([path], text: "You have been invited to join my photo booth on UrPoint. Click the link or scan the QR code to join. ${widget.url}");
                  },
                  child: Text('Share QR Invite'))
          ]
          ),
        ),
      )
    );
  }
}
void showToast(String message){
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0
  );
}

Future<void> writeToFile(ByteData data, String path) async {
  final buffer = data.buffer;
  await File(path).writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
  );
}

Future<String> createQrCode(String url) async {

  var painter = await paintQr(url);

  final appDir = await getTemporaryDirectory();
  String tempPath = appDir.path;
  var time = DateTime.now();
  String path = '$tempPath/$time.png';
  var picData = await painter.toImageData(2048, format: ImageByteFormat.png);
  if(picData != null){
    print("$picData is here");
    writeToFile(picData, path);
  }
  return path;
}
Future<QrPainter> paintQr(String url) async {
  final painter = await QrPainter(
    data: url,
    version: QrVersions.auto,
  );
  return painter;
}


class NavDrawer extends StatefulWidget {

  NavDrawerState createState() {
    return NavDrawerState();
  }
}

class NavDrawerState extends State<NavDrawer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();



  bool forAndroid = autoload.storageSetting;

  late String labelText;

  @override
  Widget build(BuildContext context) {

    final ButtonStyle style = ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, textStyle: TextStyle(fontSize: 12));

    if(forAndroid == true){
      labelText = "All Posts will be Kept";
    }
    if(forAndroid == false){
      labelText = 'Posts will expire after 7 days.';
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Welcome to Ur Point, ${autoload.userName}',
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.white
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(''))),
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Photobooth-P.png', fit: BoxFit.cover),
            title: Text('Photo Booth'),
            onTap: () => {
            home.webcontroller.loadUrl('https://www.ur-point.com/ur-photo-booth'),
              print(globals.currentLink),
              Navigator.pop(context),
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Photos-P.png', fit: BoxFit.cover),
            title: Text('Photos'),
            onTap: () => {
            home.webcontroller.loadUrl('https://www.ur-point.com/ur-photos'),
              Navigator.pop(context),
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Videos-P.png', fit: BoxFit.cover),
            title: Text('Videos'),
            onTap: () => {
            home.webcontroller.loadUrl('https://www.ur-point.com/ur-videos'),
              Navigator.pop(context)
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Business-P.png', fit: BoxFit.cover),
            title: Text('Business'),
            onTap: () => {
            home.webcontroller.loadUrl('https://www.ur-point.com/ur-business'),
              Navigator.pop(context)
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Business-P.png', fit: BoxFit.cover),
            title: Text('Message'),
            onTap: () => {
              home.webcontroller.loadUrl('https://www.ur-point.com/ur-message'),
              Navigator.pop(context)
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Groups-P.png', fit: BoxFit.cover),
            title: Text('Groups'),
            onTap: () => {
            home.webcontroller.loadUrl('https://www.ur-point.com/groups'),
              Navigator.pop(context)
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Events-P.png', fit: BoxFit.cover),
            title: Text('Events'),
            onTap: () => {
            home.webcontroller.loadUrl('https://www.ur-point.com/events'),
              Navigator.pop(context)
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Image.asset('UrIcons/Ur-Cards-P.png', fit: BoxFit.cover),
            title: Text('Cards'),
            onTap: () => {
              home.webcontroller.loadUrl('https://www.ur-cards.com/'),
              Navigator.pop(context),
              card.CardPage(),
            },
          ),
          ListTile(
            minVerticalPadding: 25,
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Really Log Out?"),
                  content: const Text("Are you sure you want to log out? Your account details will not be saved."),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        color: Colors.green,
                        padding: const EdgeInsets.all(14),
                        child: const Text("Cancel"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        home.webcontroller.loadUrl('https://www.ur-point.com/logout');
                        autoload.logOut(context);
                      },
                      child: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.all(14),
                        child: const Text("Log Out"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            width: 42.0,
            height: 136.0,
            child: DecoratedBox(
              decoration: BoxDecoration(border:
              Border.all(color: Colors.black),
                  color: Colors.white
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Storage', style: new TextStyle(
                          fontSize: 20.0,
                          color: Colors.purple
                        ),),
                        Switch(
                            activeColor: Colors.purple,
                            activeTrackColor: Colors.black,
                            inactiveThumbColor: Colors.purple,
                            inactiveTrackColor: Colors.black26,
                            splashRadius: 50.0,
                            // boolean variable value
                            value: forAndroid,
                            // changes the state of the switch
                            onChanged: (value) async {
                              final SharedPreferences prefs = await _prefs;
                              setState(() {
                                prefs.setBool('storageSetting', value);
                                print(prefs.getBool('storageSetting'));
                                home.webcontroller.runJavascript('\$( "#toggleSwitch" ).click()');
                                forAndroid = value;
                                print('changed storage to $value');
                              });
                            }
                        ),
                        Text(labelText,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            home.webcontroller.loadUrl('https://www.ur-point.com/upgrade');
                            Navigator.pop(context);
                          },
                          style: style,
                          child: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            )
          ),
        ],
      ),
    );
  }
}

