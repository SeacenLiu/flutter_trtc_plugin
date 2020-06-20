import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_list_page.dart';
import 'package:flutter_trtc_plugin_example/video_chat_test/video_chat_page.dart';
import 'package:flutter_trtc_plugin_example/scene_live_test/live_anchor_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRTC Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TRTC Demo"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return LiveListPage();
                    },
                  ),
                );
              },
              child: Text("简易直播"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return VideoChatPageRoute();
                    },
                  ),
                );
              },
              child: Text("视频聊天"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return LiveAnchorPage();
                    },
                  ),
                );
              },
              child: Text("我要直播"),
            ),
          ],
        ),
      ),
    );
  }
}
