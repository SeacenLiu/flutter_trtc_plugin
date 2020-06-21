import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin/flutter_trtc_plugin.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_room_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:collection';

class LivePushPage extends StatefulWidget {
  String roomId;
  String userId;

  LivePushPage({Key key, @required this.roomId, this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LivePushPageState();
}

class _LivePushPageState extends State<LivePushPage> {
  String _userSig = "";
  int _sdkAppId = 1400384163;
  String _secretKey =
      'b005f225bd2051f6a7fd3d7f89deb62275342a81a767d04454db91a6943e1215';
  // UserId: ViewId
  HashMap<String, int> _viewIdMap = HashMap<String, int>();
  // UserId: UIKitView
  HashMap<String, Widget> _widgetMap = HashMap<String, Widget>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("主播端"),
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 240,
              left: 0,
              right: 0,
              child: _renderWidget(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FlatButton(
                onPressed: () async {
                  String userId = widget.userId;
                  int roomId = int.parse(widget.roomId);
                  // 获取 UserSig
                  _userSig =
                      await TrtcBase.getUserSig(_sdkAppId, _secretKey, userId);
                  showTips('获取UserSig成功');
                  // 初始化 SDK
                  TrtcBase.sharedInstance();
                  // 设置监听
                  TrtcBase.registerCallback(
                    onError: _onError,
                    onWarning: _onWarning,
                    onEnterRoom: _onEnterRoom,
                    onExitRoom: _onExitRoom,
                    onRemoteUserEnterRoom: _onRemoteUserEnterRoom,
                    onRemoteUserLeaveRoom: _onRemoteUserLeaveRoom,
                    onUserVideoAvailable: _onUserVideoAvailable,
                    onUserAudioAvailable: _onUserAudioAvailable,
                    onConnectionLost: _onConnectionLost,
                    onTryToReconnect: _onTryToReconnect,
                    onConnectionRecovery: _onConnectionRecovery,
                    onTrtcViewClick: (viewId) {
                      showTips('$viewId被点击');
                    },
                  );
                  // 打开麦克风和摄像头
                  TrtcAudio.startLocalAudio();
                  Widget localView =
                      TrtcVideo.createPlatformView(userId, (viewId) {
                    _viewIdMap[userId] = viewId;
                    TrtcVideo.setLocalViewFillMode(
                        TrtcVideoRenderMode.TRTC_VIDEO_RENDER_MODE_FILL);
                    TrtcVideo.startLocalPreview(true, _viewIdMap[userId]);
                  });
                  _widgetMap[userId] = localView;
                  // 进入房间
                  TrtcRoom.enterRoom(_sdkAppId, userId, _userSig, roomId,
                      TrtcAppScene.TRTC_APP_SCENE_LIVE,
                      role: TrtcRole.TRTC_ROLE_ANCHOR);
                  // 创建直播间
                  LiveRoomManager.getInstance()
                      .createLiveRoom(roomId.toString());
                  setState(() {});
                },
                child: Text("开始直播"),
              ),
            ),
          ],
        ));
  }

  // 渲染组件
  Widget _renderWidget() {
    if (_widgetMap == null || _widgetMap.isEmpty) {
      return SizedBox();
    } else {
      return Container(
        child: _widgetMap[widget.userId],
      );
    }
  }

  void showTips(String msg) {
    Fluttertoast.showToast(msg: msg);
    print(msg);
  }

  // 监听
  void _onError(int errCode, String errMsg) {
    String msg = 'onError: errCode = $errCode, errMsg = $errMsg';
    showTips(msg);
  }

  void _onWarning(int warningCode, String warningMsg) {
    if (warningCode == TrtcWarningCode.WARNING_VIDEO_PLAY_LAG) {
      TrtcVideo.setNetworkQosParam(
          preference: TrtcVideoQosPreference.TRTC_VIDEO_QOS_PREFERENCE_SMOOTH);
    }
    String msg =
        'onWarning: warningCode = $warningCode, warningMsg = $warningMsg';
    showTips(msg);
  }

  void _onEnterRoom(int result) {
    String msg;
    if (result > 0) {
      msg = '进入房间耗时$result毫秒';
      // TrtcAudio.startLocalAudio();
      // Widget widget = TrtcVideo.createPlatformView(_currentUserId, (viewId) {
      //   _viewIdMap[_currentUserId] = viewId;
      //   TrtcVideo.setLocalViewFillMode(
      //       TrtcVideoRenderMode.TRTC_VIDEO_RENDER_MODE_FILL);
      //   TrtcVideo.startLocalPreview(true, _viewIdMap[_currentUserId]);
      // });
      // _widgetMap[_currentUserId] = widget;
      // setState(() {});
    } else {
      msg = '进入房间失败，错误码$result';
    }
    debugPrint(msg);
    showTips(msg);
  }

  void _onExitRoom(int reason) {
    String msg;
    if (reason == 0) {
      msg = '用户主动离开房间';
      _widgetMap.clear();
      _viewIdMap.clear();
    } else if (reason == 1) {
      msg = '用户被踢出房间';
    } else {
      msg = '房间已解散';
    }
    showTips(msg);
  }

  void _onRemoteUserEnterRoom(String userId) {
    String msg = '用户$userId进入房间';
    showTips(msg);
  }

  void _onRemoteUserLeaveRoom(String userId, int reason) {
    String reasonStr;
    if (reason == 0) {
      reasonStr = '用户主动离开房间';
    } else if (reason == 1) {
      reasonStr = '用户超时退出房间';
    } else {
      reasonStr = '用户被踢出房间';
    }
    showTips('用户$userId离开房间，离开原因为：$reasonStr');
  }

  void _onUserVideoAvailable(String userId, bool available) {
    String availableStr = available ? '开启' : '关闭';
    showTips('用户$userId的画面$availableStr');

    if (available) {
      if (!_viewIdMap.containsKey(userId) && !_widgetMap.containsKey(userId)) {
        Widget widget = TrtcVideo.createPlatformView(userId, (viewId) {
          _viewIdMap[userId] = viewId;
          TrtcVideo.setRemoteViewFillMode(
              userId, TrtcVideoRenderMode.TRTC_VIDEO_RENDER_MODE_FILL);
          TrtcVideo.startRemoteView(userId, viewId);
        });
        _widgetMap[userId] = widget;
        setState(() {});
      }
    } else {
      if (_viewIdMap.containsKey(userId) && _widgetMap.containsKey(userId)) {
        TrtcVideo.stopRemoteView(userId);
        TrtcVideo.destroyPlatformView(_viewIdMap[userId]).then((flag) {
          if (flag) {
            _viewIdMap.remove(userId);
            _widgetMap.remove(userId);
            setState(() {});
          }
        });
      }
    }
  }

  void _onUserAudioAvailable(String userId, bool available) {
    String availableStr = available ? '开启' : '关闭';
    showTips('用户$userId的音频$availableStr');
  }

  void _onConnectionLost() {
    showTips('连接已断开...');
  }

  void _onTryToReconnect() {
    showTips('正在重连中...');
  }

  void _onConnectionRecovery() {
    showTips('连接已恢复...');
  }
}
