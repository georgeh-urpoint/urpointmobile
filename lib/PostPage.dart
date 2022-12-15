

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'autoloadglobals.dart' as globals;
import 'package:web_view/HomeTab.dart' as home;
import 'package:web_view/ProfilePage.dart' as profile;

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() {
    return _PostPageState();
  }
}

class _PostPageState extends State<PostPage>{

  final ButtonStyle style = ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, textStyle: TextStyle(fontSize: 16));
  final ButtonStyle small = ElevatedButton.styleFrom(backgroundColor: Colors.purple, textStyle: TextStyle(fontSize: 12));

  final ImagePicker _picker = ImagePicker();

  bool idGot = false;

  bool loaded = false;

  late WebViewController controller;
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: ElevatedButton.icon(
          style: style,
          onPressed: () {
            home.webcontroller.evaluateJavascript(source: 'document.querySelector("#publisher-button").click()');
            Navigator.pop(context);
            home.webcontroller.evaluateJavascript(source: 'document.querySelector("#publisher-box-focus > div").style.display="none"');
          },
          label: Text('Send'),
          icon: Icon(Icons.send),

        ),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              home.webcontroller.evaluateJavascript(source: 'document.querySelector("#post-textarea > div > textarea").value="$value"');
            },
            autofocus: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Share Ur-Point'
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                style: small,
                onPressed: () async {
                  home.webcontroller.evaluateJavascript(source: 'document.querySelector("#publisher-photos").click()');
                },
                label: Text('Upload Photo'),
                icon: Icon(Icons.image),
              ),
              ElevatedButton.icon(
                style: small,
                onPressed: () async {
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                },
                label: Text('Take Picture'),
                icon: Icon(Icons.camera),
              ),
              ElevatedButton.icon(
                style: small,
                onPressed: () async {
                  final XFile? image = await _picker.pickVideo(source: ImageSource.gallery);
                },
                label: Text('Upload Video'),
                icon: Icon(Icons.video_file),
              ),
            ],
          )
        ],
      )
    );
  }
}