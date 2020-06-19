import 'package:flutter_trtc_plugin/flutter_trtc_plugin.dart';

const double trtcLivePlayTimeOut = 5.0;

class TRTCCloudAction {
  // /// 播放回调存储
  // private var playCallBackMap: [String: TRTCLiveRoomImpl.Callback] = [:]
  // private var userPlayInfo = [String: PlayInfo]()
  int roomId;
  String curRoomUUID;

  String _userId;
  String _urlDomain;
  int _sdkAppId = 1400384163;
  String _userSig;
  bool _isEnterRoom = false;

  TRTCCloudAction(this._userId, this._urlDomain, this._sdkAppId, this._userSig);

  void reset() {
    _userId = "";
    _urlDomain = "";
    _sdkAppId = 0;
    _userSig = "";
  }

  void enterRoom(int roomID, String userId, int role) {
    if (_sdkAppId == 0 || _isEnterRoom) {
      return;
    }
    this.roomId = roomID;
    _isEnterRoom = true;
    // TODO: - 随机生成
    curRoomUUID = "qwertasdfg123456";
    // TRTCParams 由原生进行处理
    TrtcRoom.enterRoom(
        _sdkAppId, userId, _userSig, roomID, TrtcAppScene.TRTC_APP_SCENE_LIVE);
  }

  void switchRole(int role) {
    TrtcRoom.switchRole(role);
  }

  void exitRoom() {
    // playCallBackMap.removeAll();
    TrtcRoom.exitRoom();
    _isEnterRoom = false;
    curRoomUUID = "";
  }

  void setupVideoParam(bool isOwner) {
    if (isOwner) {
      TrtcVideo.setVideoEncoderParam(
          videoResolution: TrtcVideoResolution.TRTC_VIDEO_RESOLUTION_960_540,
          videoResolutionMode:
              TrtcVideoResolutionMode.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT,
          videoFps: 15,
          videoBitrate: 1200,
          enableAdjustRes: true);
    } else {
      TrtcVideo.setVideoEncoderParam(
          videoResolution: TrtcVideoResolution.TRTC_VIDEO_RESOLUTION_480_270,
          videoResolutionMode:
              TrtcVideoResolutionMode.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT,
          videoFps: 15,
          videoBitrate: 400,
          enableAdjustRes: true);
    }
  }

  void startLocalPreview(bool frontCamera, int viewId) {
    TrtcVideo.startLocalPreview(frontCamera, viewId);
  }

  void stopLocalPreview() {
    TrtcVideo.stopLocalPreview();
  }

  void startPublish(String streamID) {
    if (_userId.isEmpty || roomId == 0) {
      return;
    }
    enterRoom(roomId, _userId, TrtcRole.TRTC_ROLE_ANCHOR);
    TrtcAudio.startLocalAudio();
    if (streamID.isNotEmpty) {
      TrtcStream.startPublishing(streamID, TRTCVideoStreamType.TRTC_VIDEO_STREAM_TYPE_BIG);
    }
  }

  void stopPublish() {
    TrtcAudio.startLocalAudio();
    TrtcStream.stopPublish();
  }

  // TODO: - 播放
  // startPlay
  // startTrtcPlay
  // stopPlay
  // stopAllPlay
  // onFirstVideoFrame
  // playCallBack
  // togglePlay
  // isUserPlaying

  // TODO: - PK
  // startRoomPK
  // updateMixingParams
  // 
}
