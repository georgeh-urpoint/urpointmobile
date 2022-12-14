import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'ProfilePage.dart';
import 'main.dart';
import 'HomeTab.dart' as home;
import 'globals.dart' as globals;
import 'package:web_view/MessageTab.dart' as message;
import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';


class CardPage extends StatefulWidget {
  final link;
  final isRedir;

  CardPage({this.isRedir, this.link});

  @override
  _CardPageState createState() {
    return _CardPageState();
  }
}


class _CardPageState extends State<CardPage> {

  late final dynamic isRedir;

  late InAppWebViewController controller;

  bool idGot = false;
  bool loaded = false;

  var currentUrl;

  TextEditingController textController = TextEditingController();

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
      message.MessageTab(),
      Text('Notifications Page Currently Unavailable. Check back soon!'),
      ProfilePage(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purpleAccent,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.deepPurple,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: new Stack(
                  children: <Widget>[
                    new Icon(Icons.message),
                    globals.msgNum != 0?
                    new Positioned(
                      right: 0,
                      child: new Container(
                          padding: EdgeInsets.all(1),
                          decoration: new BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: globals.msgNum < 9?new Text(
                            '${globals.msgNum}',
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ):
                          new Text('9+',
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center)
                      ),
                    ):
                    SizedBox.shrink()
                  ]
              ),
              label: 'Messages'
          ),
          BottomNavigationBarItem(
            icon: new Stack(
                children: <Widget>[
                  new Icon(Icons.notifications),
                  globals.notifNum != 0?
                  new Positioned(
                    right: 0,
                    child: new Container(
                        padding: EdgeInsets.all(1),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: globals.notifNum < 9?new Text(
                          '${globals.notifNum}',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ):
                        new Text('9+',
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center)
                    ),
                  ):
                  SizedBox.shrink()
                ]
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile')
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
      drawer: NavDrawer(),
      appBar: AppBarWithSearchSwitch(
        fieldHintText: 'Search Groups',
        keepAppBarColors: true,
        backgroundColor: Colors.deepPurple,
        customTextEditingController: textController,
        onSubmitted: (value){
          _selectedIndex = 0;
          home.webcontroller.loadUrl(urlRequest: URLRequest(url: Uri.parse('https://www.ur-point.com/search?query=$value')));
        },
        appBarBuilder: (BuildContext context) {
          return AppBar(
              toolbarHeight: 50,
              title: Image.asset('', fit: BoxFit.fill),
              centerTitle: true,
              backgroundColor: Colors.blueAccent,
              actions: [
                AppBarSearchButton(
                  searchActiveButtonColor: Colors.purple,
                )
              ]
          );
        },
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
