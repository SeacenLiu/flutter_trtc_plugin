import 'package:flutter/services.dart';

class TrtcStream {
  static const MethodChannel _channel = const MethodChannel('flutter_trtc_plugin');

  static Future<void> startPublishing(String streamId, int type) async {
    return await _channel.invokeMethod('startPublishing', {'streamId': streamId, 'type': type});
  }

  static Future<void> stopPublish() async {
    return await _channel.invokeMethod('stopPublish');
  }
}