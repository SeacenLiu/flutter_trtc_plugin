import 'package:flutter/material.dart';

class LiveSubVideoView extends StatefulWidget {
  const LiveSubVideoView(
      {Key key, @required this.child, this.onAudioEnable, this.onVideoEnable})
      : super(key: key);

  final Widget child;
  final Function(bool isAudio) onAudioEnable;
  final Function(bool isVideo) onVideoEnable;

  @override
  State<StatefulWidget> createState() => _LiveSubVideoViewState();
}

class _LiveSubVideoViewState extends State<LiveSubVideoView> {
  bool isAudioEnable = true;
  bool isVideoEnable = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 160,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: widget.child,
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Builder(
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
                    if (widget.onAudioEnable != null) {
                      widget.onAudioEnable(isAudioEnable);
                    }
                    setState(() {});
                  },
                );
              },
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Builder(
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
                    if (widget.onVideoEnable != null) {
                      widget.onVideoEnable(isVideoEnable);
                    }
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
