library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'LoginPage.dart';
import 'main.dart';
import 'package:is_first_run/is_first_run.dart';


String userName = '';
String playerId = '';
String userId = '';
MaterialColor isOnCards = Colors.purple;
bool hasRan = false;

Future<bool> loadData() async{

  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool check1 = prefs.containsKey('username');
  bool check2 = prefs.containsKey('userId');
  bool check3 = prefs.containsKey('playerId');

  print("username: $check1, userid: $check2, playerId: $check3");

  if(check1 == true && check2 == true && check3 == true) {
    userName = prefs.getString('username')!;
    userId = prefs.getString('userId')!;
    playerId = prefs.getString('playerId')!;
  }

  print("UserData is $userName, $userId, $playerId");
  var returnData = await autoLoad();
  return returnData;
}

Future<bool> autoLoad() async{
  print("loadingUser");
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool firstRun = await IsFirstRun.isFirstRun();
  bool usercheck = prefs.containsKey('username');
  bool? logcheck = prefs.getBool('loggedIn');
  print("logged in? $logcheck");

  if(firstRun == true && hasRan == false){
    print("First Run Detected");
    prefs.setBool('loggedIn', false);
    logcheck = prefs.getBool('loggedIn');
    hasRan = true;
    autoLoad();
  }

  if(logcheck == false){
    hasRan = true;
    print("no account detected, running login script");
    return false;
  }

  if(logcheck == true){
    userName = prefs.getString('username')!;
    playerId = prefs.getString('playerId')!;
    userId = prefs.getString('userId')!;
    print("Username Loaded: $userName");
    print("account loaded successfully.");
    prefs.setBool('loggedIn', true);
    print("User Loaded: $userName, $playerId, $userId");
    return true;
  }

  throw("Error occurred while searching for account, try again.");
}

void logOut(BuildContext context) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('username');
  prefs.remove('userId');
  prefs.remove('playerId');
  userName = '';
  userId = '';
  playerId = '';
  prefs.setBool('loggedIn', false);
  print("User Logged Out");
  Navigator.pushReplacement(context, new MaterialPageRoute(
      builder: (context) => new LoginPage()
  ));
}