import 'dart:async';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xf_demo/utils/xf_manage.dart';

/// 创建日期: 2021/5/31
/// 作者: lijianbin
/// 描述:
class MicRecord {
  static bool _isRecording = false;
  static Stream<List<int>> _stream;
  static StreamSubscription<List<int>> _listener;
  static List<int> _currentSamples = List();

  ///获取录音生成的字节数组
  static Future<List<int>> currentSamples() async {
    //获取录制配置信息
    double sampleRate = await MicStream.sampleRate;
    //需要进行重采样
    if (sampleRate != 16000) {
      //保存音频到temp.pcm
      final temp =
          (await getApplicationDocumentsDirectory()).path + '/temp.pcm';
      if (!await File(temp).exists()) {
        await File(temp).create();
      }
      await File(temp).writeAsBytes(_currentSamples);

      //创建重采样后的文件
      final temp2 = (await getApplicationDocumentsDirectory()).path +
          '/temp2.pcm';
      if (!await File(temp2).exists()) {
        await File(temp2).create();
      }

      final rc = await FlutterFFmpeg().execute(
          "-y -f s16le -ar $sampleRate -ac 1 -i $temp -acodec pcm_s16le -f s16le -ac 1 -ar 16000 $temp2");
      log('ffmpeg:rc = $rc');
      return File(temp2).readAsBytes();
    }
    return _currentSamples;
  }

  ///开始录音
  static Future<bool> startListening() async {
    //授权
    if (Platform.isAndroid &&
        !await Permission.microphone.request().isGranted) {
      return false;
    }
    //清空缓存
    _currentSamples.clear();
    if (_isRecording) return false;

    //开始录音
    _stream = await MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      sampleRate: 16000,
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
