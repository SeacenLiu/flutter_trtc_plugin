
//roomModel
class RoomCommonModel {
  int errorCode = -1;
  String errorMessage = "";
}

class RoomInfoModel {
  String appId;
  String type;
  String roomId;
  int id;
  String createTime;
}

//roomListModel
class RoomInfoResultModel {
  int errorCode = -1;
  String errorMessage = "";
  List<RoomInfoModel> data;
}

//roomManager
class RoomManager {
  
}