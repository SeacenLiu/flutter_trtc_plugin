import 'package:flutter/material.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_play_page.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_push_page.dart';
import 'package:flutter_trtc_plugin_example/live_test/live_room_manager.dart';

class LiveListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LiveListPageState();
}

class _LiveListPageState extends State<LiveListPage> {
  RoomListRespObject listRoom = null;

  TextEditingController editingController =
      TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("直播列表"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              RoomListRespObject obj =
                  await LiveRoomManager.getInstance().queryLiveRoomList();
              setState(() {
                listRoom = obj;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 100,
            left: 0,
            right: 0,
            child: _liveList(),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: TextField(
              controller: editingController,
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    String userId = editingController.text;
                    return LivePushPage(roomId: userId, userId: userId);
                  }),
                );
              },
              child: Text("开始直播"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveList() {
    if (listRoom != null) {
      return ListView.builder(
        itemCount: listRoom.data.length,
        itemExtent: 50.0, //强制高度为50.0
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return LivePlayPage(
                    roomId: listRoom.data[index].roomId,
                    userId: "111111",
                  );
                }),
              );
            },
            child: ListTile(
              title: Text(
                listRoom.data[index].roomId.toString(),
              ),
            ),
          );
        },
      );
    } else {
      return SizedBox();
    }
  }
}
