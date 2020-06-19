import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin/flutter_trtc_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LiveAudiencePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LiveAudiencePageState();
}

class _LiveAudiencePageState extends State<LiveAudiencePage> {
  String _currentUserId;
  String _userSig;
  int _sdkAppId = 1400384163;
  String _secretKey =
      'b005f225bd2051f6a7fd3d7f89deb62275342a81a767d04454db91a6943e1215';
  int _roomId = 19971231; //58994078;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("观众端"),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 240,
            left: 0,
            right: 0,
            child: _hostLiveWidget(),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FlatButton(
                onPressed: () async {
                  // 获取 UserSig
                  _currentUserId = '666';
                  _userSig = await TrtcBase.getUserSig(
                      _sdkAppId, _secretKey, _currentUserId);
                  showTips('获取UserSig成功');
                  // 初始化 SDK
                  TrtcBase.sharedInstance();
                  // TODO: - 设置监听
                  // 进入房间
                  TrtcRoom.enterRoom(_sdkAppId, _currentUserId, _userSig,
                      _roomId, TrtcAppScene.TRTC_APP_SCENE_LIVE);
                  
                },
                child: Text("观看直播"),
              )),
        ],
      ),
    );
  }

  Widget _hostLiveWidget() {
    return SizedBox();
  }

  void showTips(String msg) {
    Fluttertoast.showToast(msg: msg);
    print(msg);
  }
}
