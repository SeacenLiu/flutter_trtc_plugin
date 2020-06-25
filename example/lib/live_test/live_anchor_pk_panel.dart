import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_room_manager.dart';

class LiveAnchorPKPanel extends StatefulWidget {
  const LiveAnchorPKPanel({Key key, @required this.onSelectRoom})
      : super(key: key);

  final Function(String roomId, String userId) onSelectRoom;

  @override
  State<StatefulWidget> createState() => _LiveAnchorPKPanelState();
}

class _LiveAnchorPKPanelState extends State<LiveAnchorPKPanel> {
  RoomListRespObject listRoom = null;

  @override
  void initState() {
    LiveRoomManager.getInstance()
        .queryLiveRoomList()
        .then((RoomListRespObject obj) {
      listRoom = obj;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(
        builder: (BuildContext context) {
          if (listRoom == null) {
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(color: Colors.blue),
            );
          } else {
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: ListView.builder(
                itemCount: listRoom.data.length,
                itemExtent: 50.0, //强制高度为50.0
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      if (widget.onSelectRoom != null) {
                        String roomId = listRoom.data[index].roomId.toString();
                        // 当前版本 userId 与 roomId 一致
                        widget.onSelectRoom(roomId, roomId);
                      }
                    },
                    child: ListTile(
                      title: Text(
                        listRoom.data[index].roomId.toString(),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
