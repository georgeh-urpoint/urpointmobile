library my_prj.globals;

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';


String userName = '';
String playerId = '';
String userId = '';
bool storageSetting = false;
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
    return true;
  }

  if(check1 == false && check2 == false && check3 == false) {
    return false;
  }

  print("UserData is $userName, $userId, $playerId");
  throw("Error occurred while loading user data, try again.");
}


Future<void> loadUserData() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userName = await prefs.getString('username')!;
  playerId = await prefs.getString('playerId')!;
  userId = await prefs.getString('userId')!;
  storageSetting = await prefs.getBool('storageSetting')!;
  print("Username Loaded: $userName");
  print("account loaded successfully.");
  prefs.setBool('loggedIn', true);
  print("User Loaded: $userName, $playerId, $userId");
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