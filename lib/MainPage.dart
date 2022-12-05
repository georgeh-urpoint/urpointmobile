
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ProfilePage.dart';
import 'main.dart';
import 'HomeTab.dart' as home;
import 'globals.dart' as globals;
import 'autoloadglobals.dart' as autoload;

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

  var currentUrl;


  get homeUrl => 'https://www.ur-point.com/index.php';

  get userIdUrl => 'https://www.ur-point.com/firestore.php';

  get link => widget.link;

  int _selectedIndex = 0;

  void _onNavTapped(int index){
    if(_selectedIndex == 0 && index == 0){
      globals.refresh = true;
    }
    setState((){
      _selectedIndex = index;
    });
  }

  @override

  Widget build(BuildContext context) {

    List<Widget> _pages = <Widget>[
      home.HomeTab(isRedir: widget.isRedir, link: 'https://www.ur-point.com/index.php',),
      Icon(
        Icons.account_circle,
        size: 150,
      ),
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
              icon: Icon(Icons.message),
              label: 'Messages'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile')
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Image.asset('assets/urpointlogo.png', fit: BoxFit.cover),
        centerTitle: true,
        backgroundColor: autoload.isOnCards,
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
                return GenerateQRPage(url: globals.currentLink);
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

