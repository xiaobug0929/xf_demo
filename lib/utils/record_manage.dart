import 'dart:async';
import 'dart:io';

import 'package:mic_stream/mic_stream.dart';
import 'package:permission_handler/permission_handler.dart';

/// 创建日期: 2021/5/31
/// 作者: lijianbin
/// 描述:
class MicRecord {
  static bool _isRecording = false;
  static Stream<List<int>> _stream;
  static StreamSubscription<List<int>> _listener;
  static List<int> _currentSamples = List();

  static currentSamples() => _currentSamples;

  ///开始录音
  static Future<bool> startListening() async {
    //授权
    if (Platform.isAndroid &&
        !await Permission.microphone.request().isGranted) {
      return false;
    }
    _currentSamples.clear();
    if (_isRecording) return false;
    _stream = await MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,
      audioFormat: AudioFormat.ENCODING_PCM_16BIT,
    );
    _listener = _stream?.listen((samples) {
      _currentSamples.addAll(samples);
    });
    _isRecording = true;
    return true;
  }

  ///停止录音
  static bool stopListening() {
    if (!_isRecording) return false;
    _listener?.cancel();
    _isRecording = false;
    _stream = null;
    return true;
  }
}
