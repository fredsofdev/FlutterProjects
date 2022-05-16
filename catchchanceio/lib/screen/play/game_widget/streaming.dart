
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:janus_client/JanusClient.dart';
import 'package:janus_client/utils.dart';

class Streaming extends StatefulWidget {

  final int selectedStreamId;
  final Function isLoading;

  const Streaming({required Key key ,required this.selectedStreamId, required this.isLoading}) : super(key: key);
  @override
  _StreamingState createState() => _StreamingState();
}

class _StreamingState extends State<Streaming> {
  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   return SizedBox();
  //   throw UnimplementedError();
  // }

  late JanusClient j;
  late RestJanusTransport rest;
  late JanusSession session;
  late JanusPlugin plugin;
  Map<int, JanusPlugin> subscriberHandles = {};

  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  List<dynamic> streams = [];
  late int selectedStreamId;


  // JanusClient janusClient = JanusClient(iceServers: [
  //   RTCIceServer(
  //       url: "stun:stun.voip.eutelia.it:3478", username: "", credential: ""),
  //   RTCIceServer(
  //       url: "turn:turn.orangestep-antmedia.com:3478", username: "guest", credential: "somepassword"),
  // ], server: "http://3.34.148.99:8088", withCredentials: true);
  // late Plugin publishVideo;
  // final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await _remoteRenderer.initialize();
  }

  Future<void> initJanusClient() async {
    setState(() {
      rest = RestJanusTransport(url: "http://3.34.148.99:8088/janus");
      print(rest.url);
      j = JanusClient(transport: rest,withCredentials: true,iceServers: [
        RTCIceServer(
            url: "stun:stun.voip.eutelia.it:3478", username: "", credential: ""),
        RTCIceServer(
            url: "turn:turn.orangestep-antmedia.com:3478", username: "guest", credential: "somepassword"),
      ]);
    });
    print("Connection to Janus");

    session = await j.createSession();
    print(session.sessionId);
    plugin = await session.attach(JanusPlugins.STREAMING);
    print('got handleId');
    print(plugin.handleId);
    startStreaming();
    plugin.remoteStream!.listen((event) {
        _remoteRenderer.srcObject = event;
    });

    plugin.messages!.listen((even) async {
      print('got onmsg');
      print(even);
      var pluginData = even.event['plugindata'];
      if (pluginData != null) {
        var data = pluginData['data'];
        if (data != null) {
          var msg = data;

          if (msg['streaming'] != null) {
            if(msg['result'] != null) {
              if (msg['streaming'] == 'event' &&
                  msg['result']['status'] == 'stopping') {
                // await destroy();
              }
              if (msg['streaming'] == 'event' &&
                  msg['result']['status'] == 'started') {
                stopLoading();
              }
            }
            if (msg['streaming'] == 'event' &&
                msg['error_code'] == 455) {
              startStreaming();
            }
          }
        }
      }

      if (even.jsep != null) {
        debugPrint("Handling SDP as well..." + even.jsep.toString());
        await plugin.handleRemoteJsep(even.jsep!);
        RTCSessionDescription answer = await plugin.createAnswer();
        plugin.send(data: {"request": "start"}, jsep: answer);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initJanusClient();
  }

  Future<void> startStreaming()async{
    widget.isLoading(true);
   await plugin.send(data: {
      "request": "watch",
      "id": widget.selectedStreamId,
      "offer_audio": false,
      "offer_video": true,
    });
  }

  Future<void> stopLoading()async{
    await Future.delayed(const Duration(milliseconds: 2000));
    widget.isLoading(false);
  }


  Future<void> destroy() async {
    if (_remoteRenderer != null) {
      _remoteRenderer.srcObject = null;
      await _remoteRenderer.dispose();
    }
    await plugin.dispose();
    session.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        ),
      ],
    );
  }

  @override
  void dispose(){
    destroy();
    super.dispose();
  }
}