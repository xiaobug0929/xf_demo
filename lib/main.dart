import 'package:flutter/material.dart';
import 'package:xf_demo/utils/mic_manage.dart';
import 'package:xf_demo/utils/xf_manage.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WsWidgetPage(),
    );
  }
}

const host = 'iat-api.xfyun.cn';
const appId = 'xxx';
const apiKey = 'xxx';
const apiSecret = 'xxx';


class WsWidgetPage extends StatefulWidget {
  @override
  _WsWidgetPageState createState() => _WsWidgetPageState();
}

class _WsWidgetPageState extends State<WsWidgetPage> {
  String _msg = '等待中...';
  XfManage _xf;

  @override
  void dispose() {
    _xf?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('讯飞语音转文字测试'),
      ),
      body: Column(
        children: [
          RaisedButton(
            onPressed: () {
              MicRecord.startListening();
              setState(() {
                _msg = '录音中..';
              });
            },
            child: Text('开始录音'),
          ),
          RaisedButton(
            onPressed: connect,
            child: Text('停止录音'),
          ),
          Container(
            height: 20,
          ),
          Center(child: Text(_msg)),
        ],
      ),
    );
  }

  connect() async {
    MicRecord.stopListening();
    setState(() {
      _msg = '录音停止,正在语音转文字...';
    });

    _xf = XfManage.connect(
      host,
      apiKey,
      apiSecret,
      appId,
      await MicRecord.currentSamples(),
      (msg) {
        setState(() {
          _msg = '语音转文字完成: \r\n$msg';
        });
      },
    );
  }
}
