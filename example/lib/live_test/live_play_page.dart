import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin/flutter_trtc_plugin.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_room_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'live_sub_video_view.dart';

class LivePlayPage extends StatefulWidget {
  String roomId;
  String userId;

  LivePlayPage({Key key, @required this.roomId, this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LivePlayPageState();
}

class _LivePlayPageState extends State<LivePlayPage> {
  String _userSig = "";
  int _sdkAppId = 1400384163;
  String _secretKey =
      'b005f225bd2051f6a7fd3d7f89deb62275342a81a767d04454db91a6943e1215';
  LiveRoomManager roomManager = LiveRoomManager.getInstance();

  String roomOwner;
  // 直播自定义属性
  bool isAudioEnable = true;
  bool isVideoEnable = true;
  bool isSwitch = false;
  bool isFront = true;
  TrtcVideoView localVideoView;
  Map<String, TrtcVideoView> remoteVideoViews = Map();

  @override
  void initState() {
    // 房主的uid就是房间id
    roomOwner = widget.roomId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Render
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _roomOwnerWidget(),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _localAndOtherVideoWidget(),
          ),
          // ToolBar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _operationBar(),
          ),
          // NavigationBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _appBar(),
          ),
        ],
      ),
    );
  }

  // 关闭直播操作
  void _leaveLive() {
    // 解除监听
    TrtcBase.unregisterCallback();
    // 退出 TRTC 房间
    TrtcRoom.exitRoom();
    // 销毁 PlatformView
    if (localVideoView != null) {
      TrtcVideo.destroyPlatformView(localVideoView.viewId);
      localVideoView = null;
    }
    remoteVideoViews.forEach((key, value) {
      TrtcVideo.destroyPlatformView(value.viewId);
    });
    remoteVideoViews.clear();
  }

  // appBar
  Widget _appBar() {
    return AppBar(
      title: Text("观众端"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () async {
            String userId = widget.userId;
            int roomId = int.parse(widget.roomId);
            // 获取 UserSig
            _userSig = await TrtcBase.getUserSig(_sdkAppId, _secretKey, userId);
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
            // 进入房间
            TrtcRoom.enterRoom(_sdkAppId, userId, _userSig, roomId,
                TrtcAppScene.TRTC_APP_SCENE_LIVE,
                role: TrtcRole.TRTC_ROLE_AUDIENCE);
          },
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: () {
            _leaveLive();
          },
        ),
      ],
    );
  }

  // 底部操作按钮
  Widget _operationBar() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 通话
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              print('发起连麦');
              isSwitch = !isSwitch;
              if (isSwitch) {
                TrtcRoom.switchRole(TrtcRole.TRTC_ROLE_ANCHOR);
                TrtcAudio.startLocalAudio();
                localVideoView = TrtcVideo.createPlatformView(
                  widget.userId,
                  (viewId) {
                    TrtcVideo.startLocalPreview(true, viewId);
                  },
                );
                isFront = true;
                setState(() {});
              } else {
                TrtcRoom.switchRole(TrtcRole.TRTC_ROLE_AUDIENCE);
                TrtcAudio.stopLocalAudio();
                TrtcVideo.stopLocalPreview();
                TrtcVideo.destroyPlatformView(localVideoView.viewId);
                localVideoView = null;
                setState(() {});
              }
            },
          ),
          // 前后置摄像头
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: isSwitch ? 1 : 0,
            child: Builder(
              builder: (BuildContext context) {
                Icon icon;
                if (isFront) {
                  icon = Icon(Icons.camera_front);
                } else {
                  icon = Icon(Icons.camera_rear);
                }
                return IconButton(
                  icon: icon,
                  onPressed: () {
                    isFront = !isFront;
                    TrtcVideo.switchCamera();
                    setState(() {});
                  },
                );
              },
            ),
          ),
          // 音频
          Builder(
            builder: (BuildContext context) {
              Icon icon;
              if (isAudioEnable) {
                icon = Icon(Icons.mic);
              } else {
                icon = Icon(Icons.mic_off);
              }
              return IconButton(
                icon: icon,
                onPressed: () {
                  isAudioEnable = !isAudioEnable;
                  TrtcAudio.muteRemoteAudio(roomOwner, !isAudioEnable);
                  setState(() {});
                },
              );
            },
          ),
          // 视频
          Builder(
            builder: (BuildContext context) {
              Icon icon;
              if (isVideoEnable) {
                icon = Icon(Icons.videocam);
              } else {
                icon = Icon(Icons.videocam_off);
              }
              return IconButton(
                icon: icon,
                onPressed: () {
                  isVideoEnable = !isVideoEnable;
                  if (isVideoEnable) {
                    TrtcVideo.startRemoteView(
                        roomOwner, remoteVideoViews[roomOwner].viewId);
                  } else {
                    TrtcVideo.stopRemoteView(roomOwner);
                  }
                  setState(() {});
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // 渲染组件
  Widget _roomOwnerWidget() {
    if (remoteVideoViews[roomOwner] == null) {
      return SizedBox();
    } else {
      return Container(
        child: remoteVideoViews[roomOwner],
      );
    }
  }

  Widget _localAndOtherVideoWidget() {
    if (localVideoView != null ||
        (remoteVideoViews[roomOwner] != null && remoteVideoViews.length > 1) ||
        (remoteVideoViews[roomOwner] == null && remoteVideoViews.length > 0)) {
      List<Widget> views = List();
      print('123');
      if (localVideoView != null) {
        views.add(_remoteVideoView(localVideoView));
      }
      remoteVideoViews.forEach(
        (key, value) {
          if (key != roomOwner) {
            views.add(_remoteVideoView(value));
          }
        },
      );
      // - 16 - 90 - x - 90 - 16 -
      double crossAxisSpacing =
          (window.physicalSize.width / window.devicePixelRatio) - 212;
      return GridView.count(
        // 禁止滑动
        physics: NeverScrollableScrollPhysics(),
        // 逆向编排
        reverse: true,
        // 水平子Widget之间间距
        crossAxisSpacing: crossAxisSpacing,
        // 垂直子Widget之间间距
        mainAxisSpacing: 16.0,
        // GridView内边距
        padding: EdgeInsets.fromLTRB(16, 0, 16, 85),
        // 一行的Widget数量
        crossAxisCount: 2,
        // 子Widget宽高比例
        childAspectRatio: 90 / 160,
        // 子Widget列表
        children: views,
      );
    } else {
      return SizedBox();
    }
  }

  Widget _remoteVideoView(TrtcVideoView videoView) {
    return LiveSubVideoView(
      child: videoView,
      onAudioEnable: (bool enable) {
        if (videoView.userId == widget.userId) {
          TrtcAudio.muteLocalAudio(!enable);
        } else {
          TrtcAudio.muteRemoteAudio(videoView.userId, !enable);
        }
      },
      onVideoEnable: (bool enable) {
        if (videoView.userId == widget.userId) {
          TrtcVideo.muteLocalVideo(!enable);
        } else {
          if (enable) {
            TrtcVideo.startRemoteView(videoView.userId, videoView.viewId);
          } else {
            TrtcVideo.stopRemoteView(videoView.userId);
          }
        }
      },
    );
  }

  // 提示
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
      roomManager.exitRoom();
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
      if (remoteVideoViews[userId] == null) {
        remoteVideoViews[userId] = TrtcVideo.createPlatformView(
          userId,
          (viewID) {
            TrtcVideo.setRemoteViewFillMode(
                userId, TrtcVideoRenderMode.TRTC_VIDEO_RENDER_MODE_FILL);
            TrtcVideo.startRemoteView(userId, viewID);
          },
        );
        setState(() {});
      }
    } else {
      if (remoteVideoViews[userId] != null) {
        TrtcVideo.stopRemoteView(userId);
        TrtcVideo.destroyPlatformView(remoteVideoViews[userId].viewId)
            .then((flag) {
          if (flag) {
            remoteVideoViews.remove(userId);
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
