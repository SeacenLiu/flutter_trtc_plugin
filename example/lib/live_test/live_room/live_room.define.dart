class TRTCLiveRoomLiveStatus {
  static const int TRTC_LIVE_ROOM_STATUS_NONE = 0;
  static const int TRTC_LIVE_ROOM_STATUS_SINGLE = 0;
  static const int TRTC_LIVE_ROOM_STATUS_LINKMIC = 0;
  static const int TRTC_LIVE_ROOM_STATUS_ROOMPK = 0;
}

class TRTCCreateRoomParam {
  String roomName;
  String coverUrl;

  TRTCCreateRoomParam(this.roomName, this.coverUrl);
}

class TRTCLiveRoomConfig {
  bool useCDNFirst;
  String cdnPlayDomain;

  TRTCLiveRoomConfig(this.useCDNFirst, this.cdnPlayDomain);
}

class TRTCLiveRoomInfo {
  String roomId;
  String roomName;
  String coverUrl;
  String ownerId;
  String ownerName;
  String streamUrl;
  int memberCount;
  int roomStatus;

  TRTCLiveRoomInfo(this.roomId, this.roomName, this.coverUrl, this.ownerId,
      this.ownerName, this.streamUrl,
      {this.memberCount = 0,
      this.roomStatus = TRTCLiveRoomLiveStatus.TRTC_LIVE_ROOM_STATUS_NONE});
}

class TRTCLiveUserInfo {
  String userId;
  String userName;
  String avatarURL;
  String streamId;
  bool isOwner;

  TRTCLiveUserInfo(this.userId, this.userName, this.avatarURL,
      {this.streamId = "", this.isOwner = false});
}
