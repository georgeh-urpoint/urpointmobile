import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'MainPage.dart';
import 'main.dart';
import 'autoloadglobals.dart' as auto;

late WebViewController webviewcontroller;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  bool idGot = false;
  bool loaded = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  late String currentUrl;

  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  late CookieManager cookieManager;

  late WebViewController controller;

  bool doneLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(children: [
        WebView(
          //Creates WebView
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://www.ur-point.com/index.php?login=1',
          onWebViewCreated: (controller) {
            this.cookieManager = CookieManager();
            cookieManager.clearCookies();
            print("cookies cleared.");
            webviewcontroller = controller;
          },

          onPageStarted: (url) async {
            setState(() {
              doneLoading = false;
            });
            currentUrl = url;
            print(idGot);
            print("url is $currentUrl");
            if (url == 'https://www.ur-point.com/index.php' && idGot == false) {
              print("id not found, running script.");
              webviewcontroller.loadUrl(userIdUrl);
            }
            if (url == 'https://www.ur-point.com/index.php' && idGot == true) {
              print("pushing to main page");
              Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MainPage(
                            isRedir: false,
                          )));
            }
          },
          onPageFinished: (url) async {
            setState(() {
              doneLoading = true;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (url == userIdUrl && idGot == false) {
              //Gets user ID from UrPoint page.
              var getId = await webviewcontroller.runJavascriptReturningResult(
                  "document.getElementById('userid').value");
              var getUser = await webviewcontroller.runJavascriptReturningResult(
                  "document.getElementById('username').value");
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
              webviewcontroller.loadUrl(senderUrl);
              idGot = true;
              print("id got: $idGot");
              Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MainPage(
                            isRedir: false,
                          )));
            }
          },
        ),
        MaterialApp(
          home: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/UrPointBack.png"),
                fit: BoxFit.cover
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 200,
                    child: Center(
                      child: Image.asset("assets/HomeLogo.png", scale: 2,),
                    ),
                  ),
                  Visibility(
                    visible: doneLoading,
                    replacement: new CircularProgressIndicator(backgroundColor: Colors.purple, color: Colors.purpleAccent,),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                      labelText: 'Username',
                    ),
                    onChanged: (value) {
                      webviewcontroller.runJavascript("document.querySelector('#username').value = '$value'");
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                      ),
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      webviewcontroller.runJavascript("document.querySelector('#password').value = '$value'");
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Remember me', style: TextStyle(color: Colors.white),),
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurple)),
                      child: Text('Login'), onPressed: () {
                    webviewcontroller.runJavascript("document.querySelector('#login > div:nth-child(6) > button').click()");
                  }),
                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurple)),
                      child: Text('Forgot Password?'), onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassPage()));
                      }),
                    ],
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
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
    if (osUserID == null) {
      return true;
    } else {
      return false;
    }
  });
  var status = await OneSignal.shared.getDeviceState();
  String? osUserID = status?.userId;
  String? playerId = osUserID;

  //Creates a class of the user info
  if (playerId == null) {
    playerId = "null";
  }

  // Saves user info to users  local storage
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('playerId', playerId);
  prefs.setString('platform', platform);
  prefs.setString('userId', userid);
  //Generates URL to send info to UrPoint website.
  var url =
      "https://www.ur-point.com/firestore.php?userid=$userid&platform=$platform&playerid=$playerId";
  prefs.setBool('loggedIn', true);
  return url;
}


class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/UrPointBack.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 150,
              child: Center(
                child: Image.asset("assets/HomeLogo.png", scale: 2,),
              ),
            ),
            Text('Connect with friends and the world around you', style: TextStyle(color: Colors.white),),
            SizedBox(height: 20),
            OutlinedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purpleAccent), minimumSize: MaterialStatePropertyAll(Size(150, 50))),
              child: Text('Login', style: TextStyle(color: Colors.white,)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
            SizedBox(height: 10),
            OutlinedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurple), minimumSize: MaterialStatePropertyAll(Size(150, 50))),
              child: Text('Join Now', style: TextStyle(color: Colors.white,)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  bool idGot = false;
  bool loaded = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  late String currentUrl;

  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  late CookieManager cookieManager;

  late WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(children: [
        WebView(
          //Creates WebView
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://www.ur-point.com/index.php?login=1',
          onWebViewCreated: (controller) {
            this.cookieManager = CookieManager();
            cookieManager.clearCookies();
            print("cookies cleared.");
            webviewcontroller = controller;
          },

          onPageStarted: (url) async {
            currentUrl = url;
            print(idGot);
            print("url is $currentUrl");
            if (url == 'https://www.ur-point.com/index.php' && idGot == false) {
              print("id not found, running script.");
              webviewcontroller.loadUrl(userIdUrl);
            }
            if (url == 'https://www.ur-point.com/index.php' && idGot == true) {
              print("pushing to main page");
              Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MainPage(
                        isRedir: false,
                      )));
            }
          },
          onPageFinished: (url) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (url == userIdUrl && idGot == false) {
              //Gets user ID from UrPoint page.
              var getId = await webviewcontroller.runJavascriptReturningResult(
                  "document.getElementById('userid').value");
              var getUser = await webviewcontroller.runJavascriptReturningResult(
                  "document.getElementById('username').value");
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
              webviewcontroller.loadUrl(senderUrl);
              idGot = true;
              print("id got: $idGot");
              Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MainPage(
                        isRedir: false,
                      )));
            }
          },
        ),
        MaterialApp(
          home: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/UrPointBack.png"),
                  fit: BoxFit.cover
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 200,
                    child: Center(
                      child: Image.asset("assets/HomeLogo.png", scale: 2,),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                      labelText: 'Username',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      webviewcontroller.runJavascript("document.querySelector('#username').value = '$value'");
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      webviewcontroller.runJavascript("document.querySelector('#password').value = '$value'");
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Remember me', style: TextStyle(color: Colors.white),),
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurple)),
                      child: Text('Login'), onPressed: () {
                        webviewcontroller.runJavascript("document.querySelector('#login > div:nth-child(6) > button').click()");
                      }),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class ForgotPassPage extends StatefulWidget {
  @override
  _ForgotPassPageState createState() {
    return _ForgotPassPageState();
  }
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  bool idGot = false;
  bool loaded = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  late String currentUrl;

  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  late CookieManager cookieManager;

  late WebViewController controller;

  bool doneLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(children: [
        WebView(
          //Creates WebView
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://www.ur-point.com/forgot-password',
          onWebViewCreated: (controller) {
            this.cookieManager = CookieManager();
            cookieManager.clearCookies();
            print("cookies cleared.");
            webviewcontroller = controller;
          },

          onPageStarted: (url) async {
            setState(() {
              doneLoading = true;
            });
            currentUrl = url;
            print(idGot);
            print("url is $currentUrl");
            if (url == 'https://www.ur-point.com/index.php' && idGot == false) {
              print("id not found, running script.");
              webviewcontroller.loadUrl(userIdUrl);
            }
            if (url == 'https://www.ur-point.com/index.php' && idGot == true) {
              print("pushing to main page");
              Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MainPage(
                        isRedir: false,
                      )));
            }
          },
          onPageFinished: (url) async {
            setState(() {
              doneLoading = true;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (url == userIdUrl && idGot == false) {
              //Gets user ID from UrPoint page.
              var getId = await webviewcontroller.runJavascriptReturningResult(
                  "document.getElementById('userid').value");
              var getUser = await webviewcontroller.runJavascriptReturningResult(
                  "document.getElementById('username').value");
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
              webviewcontroller.loadUrl(senderUrl);
              idGot = true;
              print("id got: $idGot");
              Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MainPage(
                        isRedir: false,
                      )));
            }
          },
        ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/UrPointBack.png"),
                  fit: BoxFit.cover
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Visibility(
              visible: doneLoading,
              replacement: new CircularProgressIndicator(),
              child:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 200,
                    child: Center(
                      child: Image.asset("assets/HomeLogo.png", scale: 2,),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: 'Forgotten your password?')
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurple)),
                      child: Text('Recover by Email'), onPressed: () {
                        webviewcontroller.runJavascript("document.querySelector('#login > div:nth-child(6) > button').click()");
                      }),
                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurple)),
                      child: Text('Recover by SMS'), onPressed: () {
                        webviewcontroller.runJavascript("document.querySelector('#login > div:nth-child(6) > button').click()");
                      }),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}