import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

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
        ),
        floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: ExpandableFab(
          children: [
            FloatingActionButton.small(
                child: const Icon(Icons.add_a_photo_outlined),
                onPressed:() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CameraPage();
                  }));
                }
            ),
            FloatingActionButton.small(
              child: const Icon(Icons.add_box_rounded),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return GenerateQRPage(url: currentUrl);
                }));
              },
            )
          ],
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
                    RenderRepaintBoundary boundary =
                      key.currentContext?.findRenderObject() as RenderRepaintBoundary;
                    var image = await boundary.toImage();
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

  var qrValidationResult = await QrValidator.validate(
    data: url,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );

  QrCode qrCode = await qrValidationResult.qrCode as QrCode;

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

