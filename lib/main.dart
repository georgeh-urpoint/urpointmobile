import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'HomeTab.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

//Program script imports
import 'package:web_view/LoginPage.dart';
import 'package:web_view/ProfilePage.dart';
import 'package:web_view/MainPage.dart';
import 'package:web_view/HomeTab.dart' as home;
import 'package:web_view/globals.dart' as globals;

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

  var loginStatus = checkLogInStatus();

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
Future<bool> checkLogInStatus() async{
  bool login = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var check = prefs.containsKey('userdata');
  if(check == false){
    login = false;
  } else{
    login = true;
  }
  return login;
}

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
  var user = User(playerId, platform, userid, null);
  var usermap = user.toMap();

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

  //Formats user data to be saved to local user storage.
  Map<String, String> toMap() {
    return {
      "player_id": player_id,
      "platform": platform,
      "userId" : userId
    };
  }
}

Future<Widget> getInfo () async{
  var login = await checkLogInStatus();
  if(login == false){
    return LoginPage();
  } else{
    return MainPage(isRedir: false,);
  }
  return MainPage(isRedir: false,);
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
        onWebViewCreated: (controller) {
          this.controller = controller;
        },

        onPageStarted: (url) async {
          print("page started check");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var check = prefs.containsKey('userId');
          print("check 3 $check");
          if(check == false){
            print("check here 1");
            Navigator.push(context, new MaterialPageRoute(
                builder: (context) => new LoginPage()
          ));
          } else{
            print("check here 2");
            Navigator.push(context, new MaterialPageRoute(
                builder: (context) => new MainPage(isRedir: false,)
            ));
          }
          }
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

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'UrPoint',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.purple,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(''))),
          ),
          ListTile(
            leading: Icon(Icons.photo_camera_front),
            title: Text('Photo Booth'),
            onTap: () => {
              globals.currentLink = 'https://www.ur-point.com/ur-photo-booth',
              print(globals.currentLink),
              Navigator.pop(context),
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('Photos'),
            onTap: () => {
              globals.currentLink = 'https://www.ur-point.com/ur-photo-booth',
              print(globals.currentLink),
              Navigator.pop(context),
            },
          ),
          ListTile(
            leading: Icon(Icons.video_collection),
            title: Text('Videos'),
            onTap: () => {
              globals.currentLink = 'https://www.ur-point.com/ur-videos',
              print(globals.currentLink),
              Navigator.pop(context)
            },
          ),
          ListTile(
            leading: Icon(Icons.business_center),
            title: Text('Business'),
            onTap: () => {
              Navigator.pop(context)
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Groups'),
            onTap: () => {
              Navigator.pop(context)
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Events'),
            onTap: () => {
              Navigator.pop(context)
            },
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text('Cards'),
            onTap: () => {
              Navigator.pop(context)
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {
              Navigator.pop(context)
            },
          ),
        ],
      ),
    );
  }
}




