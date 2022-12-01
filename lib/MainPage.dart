import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ProfilePage.dart';
import 'main.dart';
import 'HomeTab.dart' as home;

class MainPage extends StatefulWidget {
  final link;
  final isRedir;

  MainPage({required this.isRedir, this.link});

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {

  late final dynamic isRedir;

  late WebViewController controller;

  bool idGot = false;
  bool loaded = false;

  late String currentUrl;


  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  get link => widget.link;

  int _selectedIndex = 0;

  void _onNavTapped(int index){
    setState((){
      _selectedIndex = index;
    });
  }

  @override

  Widget build(BuildContext context) {

    List<Widget> _pages = <Widget>[
      home.HomeTab(isRedir: widget.isRedir, link: 'https://www.ur-point.com/index.php',),
      ProfilePage(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages')
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
      drawer: NavDrawer(),
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
              onPressed: () {
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }

}