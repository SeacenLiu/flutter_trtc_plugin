import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin/flutter_trtc_plugin.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

const String TRTC_LIVE_ROOM_HOST =
    "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest";
const String sdkAppID = "1400384163";
const String TRTC_LIVE_ROOM_TYPE = "1"; //"LiveRoom";

class ResponseObject {
  int errorCode = -1;
  String errorMessage = "";

  ResponseObject.fromJson(Map<String, dynamic> json)
      : errorCode = json['errorCode'],
        errorMessage = json['errorMessage'];
}

class LiveRoomItem {
  String type = TRTC_LIVE_ROOM_TYPE;
  String createTime = "";
  int id = 0;
  String roomId = "";
  String appId = sdkAppID;

  LiveRoomItem.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        createTime = json['createTime'],
        id = json['id'],
        roomId = json['roomId'],
        appId = json['appId'];
}

class RoomListRespObject {
  int errorCode = -1;
  String errorMessage = "";
  List<LiveRoomItem> data = [];

  RoomListRespObject(this.errorCode, this.errorMessage, this.data);

  factory RoomListRespObject.fromJson(Map<String, dynamic> json) {
    final originList = json['data'] as List;
    List<LiveRoomItem> list =
        originList.map((value) => LiveRoomItem.fromJson(value)).toList();
    return RoomListRespObject(json['errorCode'], json['errorMessage'], list);
  }
}

class LiveRemoteUser {
  String userId = "";
  bool isVideoMuted = false;
  bool isAudioMuted = false;

  LiveRemoteUser(this.userId);
}

/**
 * RTC视频互动直播房间管理逻辑
 *
 * 包括房间创建/销毁，房间列表拉取，以及房间内用户的静音、静画（关闭该用户的视频）状态管理
 * 对房间内某个用户设置“静音”、“关闭视频”时，会把状态保存在LiveRoomManager里面
 */
class LiveRoomManager {
  LiveRoomManager._();

  static LiveRoomManager _instance;

  static LiveRoomManager getInstance() {
    if (_instance == null) {
      _instance = LiveRoomManager._();
    }
    return _instance;
  }

  // ---------------------- 直播间用户状态 ---------------------
  /// 用于保存房间内用户的静音和静画状态，以userId为key，存储的是一个LiveRemoteUser对象
  Map<String, LiveRemoteUser> roomUserMap = Map();

  bool isVideoMuted(String userId) {
    LiveRemoteUser user = roomUserMap[userId];
    if (user != null) {
      return user.isVideoMuted;
    }
    return false;
  }

  bool isAudioMuted(String userId) {
    LiveRemoteUser user = roomUserMap[userId];
    if (user != null) {
      return user.isAudioMuted;
    }
    return false;
  }

  void muteRemoteVideo(String userId, bool muted) {
    LiveRemoteUser user = roomUserMap[userId];
    if (user != null) {
      user.isVideoMuted = muted;
    }
  }

  void muteRemoteAudio(String userId, bool muted) {
    LiveRemoteUser user = roomUserMap[userId];
    if (user != null) {
      user.isAudioMuted = muted;
    }
  }

  void ownerEnterRoom(String userId) {
    onRemoteUserEnterRoom(userId);
  }

  void ownerLeaveRoom(String userId) {
    onRemoteUserLeaveRoom(userId);
  }

  void onRemoteUserEnterRoom(String userId) {
    roomUserMap[userId] = LiveRemoteUser(userId);
  }

  void onRemoteUserLeaveRoom(String userId) {
    roomUserMap.remove(userId);
  }

  void exitRoom() {
    roomUserMap.clear();
  }

  // ---------------------- 房间列表协议 ---------------------
  /// 获取视频直播房间列表
  Future<RoomListRespObject> queryLiveRoomList() async {
    Response response = await Dio().post(TRTC_LIVE_ROOM_HOST,
        data: {
          "method": "getRoomList",
          "appId": sdkAppID,
          "type": TRTC_LIVE_ROOM_TYPE
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.data is Map) {
      Map<String, dynamic> data = response.data;
      RoomListRespObject obj = RoomListRespObject.fromJson(data);
      return Future.value(obj);
    }
    return Future.value(null);
  }

  /// 创建直播房间
  Future<ResponseObject> createLiveRoom(String roomId) async {
    Response response = await Dio().post(TRTC_LIVE_ROOM_HOST,
        data: {
          "method": "createRoom",
          "appId": sdkAppID,
          "type": TRTC_LIVE_ROOM_TYPE,
          "roomId": roomId,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.data is Map) {
      Map<String, dynamic> data = response.data;
      ResponseObject obj = ResponseObject.fromJson(data);
      roomUserMap.clear();
      return Future.value(obj);
    }
    return Future.value(null);
  }

  /// 销毁直播房间
  Future<ResponseObject> destroyLiveRoom(String roomId) async {
    Response response = await Dio().post(TRTC_LIVE_ROOM_HOST,
        data: {
          "method": "destroyRoom",
          "appId": sdkAppID,
          "type": TRTC_LIVE_ROOM_TYPE,
          "roomId": roomId,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.data is Map) {
      Map<String, dynamic> data = response.data;
      ResponseObject obj = ResponseObject.fromJson(data);
      roomUserMap.clear();
      return Future.value(obj);
    }
    return Future.value(null);
  }
}
