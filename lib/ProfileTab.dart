

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'autoloadglobals.dart' as globals;
import 'package:web_view/ProfilePage.dart' as profile;
import 'NotificationPage.dart' as notifs;

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() {
    return _ProfileTabState();
  }
}

class _ProfileTabState extends State<ProfileTab> with AutomaticKeepAliveClientMixin<ProfileTab>{

  bool idGot = false;

  bool loaded = false;

  late WebViewController controller;
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: TabBar(
                physics: NeverScrollableScrollPhysics(),
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                onTap: (index) async {
                  print(index);
                },
                indicatorColor: Colors.deepPurple,
                tabs: [
                  Tab(text: 'Profile',icon: Icon(Icons.person_rounded),),
                  Tab(text: 'Timeline',icon: Icon(Icons.feed),),
                ],
              ),
              body: TabBarView(
                children: [
                  profile.ProfilePage(),
                  profile.TimelinePage(),
                ],
                physics: NeverScrollableScrollPhysics(),),
            )
        )
    );
  }
}