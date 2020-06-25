import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin/flutter_trtc_plugin.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_room_manager.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_sub_video_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LiveVideoConfig {
  int bitrate = 850;
  String resolutionName = "高";
  String resolutionDesc = "高清：540*960";
  int resolution = TrtcVideoResolution.TRTC_VIDEO_RESOLUTION_960_540;

  LiveVideoConfig(
      this.bitrate, this.resolutionName, this.resolutionDesc, this.resolution);

  static List<LiveVideoConfig> videoConfigs() {
    return [
      LiveVideoConfig(900, "标", "标清：360*640",
          TrtcVideoResolution.TRTC_VIDEO_RESOLUTION_640_360),
      LiveVideoConfig(1200, "高", "高清：540*960",
          TrtcVideoResolution.TRTC_VIDEO_RESOLUTION_960_540),
      LiveVideoConfig(1500, "超", "超清：720*1280",
          TrtcVideoResolution.TRTC_VIDEO_RESOLUTION_1280_720),
    ];
  }

  void setVideoEncoderParam() {
    TrtcVideo.setVideoEncoderParam(
        videoResolution: resolution, videoBitrate: bitrate);
  }
}

class LivePushPage extends StatefulWidget {
  String roomId;
  String userId;

  LivePushPage({Key key, @required this.roomId, this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LivePushPageState();
}

class _LivePushPageState extends State<LivePushPage> {
  // 直播基础属性
  String _userSig = "";
  int _sdkAppId = 1400384163;
  String _secretKey =
      'b005f225bd2051f6a7fd3d7f89deb62275342a81a767d04454db91a6943e1215';
  LiveRoomManager roomManager = LiveRoomManager.getInstance();

  // 渲染视图管理属性
  TrtcVideoView localVideoView;
  Map<String, TrtcVideoView> remoteVideoViews = Map();

  // 直播自定义属性
  bool isFront = true;
  bool isAudioEnable = true;
  bool isVideoEnable = true;
  LiveVideoConfig videoConfig = LiveVideoConfig(1200, "高", "高清：540*960",
      TrtcVideoResolution.TRTC_VIDEO_RESOLUTION_960_540);

  String otherAnchorId = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          // Render
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _localVideoWidget(),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _remoteVideoWidget(),
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
    // 销毁直播间
    LiveRoomManager.getInstance().destroyLiveRoom(widget.roomId);
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

  // AppBar
  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent, // AppBar 透明
      elevation: 0, // 阴影处理
      centerTitle: true,
      title: Text("主播端"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: () async {
            String userId = widget.userId;
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
              onConnectOtherRoom: _onConnectOtherRoom,
              onDisconnectOtherRoom: _onDisconnectOtherRoom,
            );
            // 打开麦克风和摄像头
            roomManager.ownerEnterRoom(widget.userId);
            TrtcAudio.startLocalAudio();
            localVideoView = TrtcVideo.createPlatformView(userId, (viewId) {
              TrtcVideo.setLocalViewFillMode(
                  TrtcVideoRenderMode.TRTC_VIDEO_RENDER_MODE_FILL);
              TrtcVideo.startLocalPreview(true, viewId);
            });
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.live_tv),
          onPressed: () {
            String userId = widget.userId;
            int roomId = int.parse(widget.roomId);
            // 进入房间
            TrtcRoom.enterRoom(_sdkAppId, userId, _userSig, roomId,
                TrtcAppScene.TRTC_APP_SCENE_LIVE,
                role: TrtcRole.TRTC_ROLE_ANCHOR);
            // 创建直播间
            LiveRoomManager.getInstance().createLiveRoom(roomId.toString());
            // 配置视频
            videoConfig.setVideoEncoderParam();
            // 清空远程视频
            remoteVideoViews.clear();
            setState(() {});
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

  // 底部操作栏
  Widget _operationBar() {
    return SafeArea(
      // 适配底部安全区问题
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // PK
          IconButton(
            icon: Icon(Icons.play_for_work),
            onPressed: () {
              TrtcRoom.connectOtherRoom('12345678', '12345678');
            },
          ),
          // 翻转摄像头
          Builder(
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
          // 视频质量
          SizedBox(
            width: 48,
            height: 48,
            child: FlatButton(
              padding: EdgeInsets.all(8),
              onPressed: () {
                List<LiveVideoConfig> videoConfigs =
                    LiveVideoConfig.videoConfigs();
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // 设置最小的弹出
                        children: <Widget>[
                          ListTile(
                            title: Text(videoConfigs[0].resolutionDesc),
                            onTap: () {
                              videoConfigs[0].setVideoEncoderParam();
                              videoConfig = videoConfigs[0];
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(videoConfigs[1].resolutionDesc),
                            onTap: () {
                              videoConfigs[1].setVideoEncoderParam();
                              videoConfig = videoConfigs[1];
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(videoConfigs[2].resolutionDesc),
                            onTap: () {
                              videoConfigs[2].setVideoEncoderParam();
                              videoConfig = videoConfigs[2];
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Text(videoConfig.resolutionName),
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
                  TrtcAudio.muteLocalAudio(!isAudioEnable);
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
                  TrtcVideo.muteLocalVideo(!isVideoEnable);
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
  Widget _localVideoWidget() {
    if (localVideoView == null) {
      return SizedBox();
    } else {
      return Container(
        child: localVideoView,
      );
    }
  }

  Widget _remoteVideoWidget() {
    if (remoteVideoViews.isEmpty) {
      return SizedBox();
    } else {
      List<Widget> views = List();
      remoteVideoViews.forEach(
        (key, value) {
          views.add(_remoteVideoView(value));
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
    }
  }

  Widget _remoteVideoView(TrtcVideoView videoView) {
    return LiveSubVideoView(
      child: videoView,
      onAudioEnable: (bool enable) {
        TrtcAudio.muteRemoteAudio(videoView.userId, !enable);
      },
      onVideoEnable: (bool enable) {
        if (enable) {
          TrtcVideo.startRemoteView(videoView.userId, videoView.viewId);
        } else {
          TrtcVideo.stopRemoteView(videoView.userId);
        }
      },
    );
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
    roomManager.onRemoteUserEnterRoom(userId);
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
    roomManager.onRemoteUserLeaveRoom(userId);
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

  void _onConnectOtherRoom(String userId, int errCode, String errMsg) {
    // TODO: - PK
    print("_onConnectOtherRoom userId: $userId, errCode: $errCode, errMsg: $errMsg");
    showTips("_onConnectOtherRoom userId: $userId, errCode: $errCode, errMsg: $errMsg");
  }

  void _onDisconnectOtherRoom(int errCode, String errMsg) {
    // TODO: - PK
    print("_onDisconnectOtherRoom errCode: $errCode, errMsg: $errMsg");
    showTips("_onDisconnectOtherRoom errCode: $errCode, errMsg: $errMsg");
  }
}
