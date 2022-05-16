
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:janus_client/Plugin.dart';
import 'package:janus_client/janus_client.dart';
import 'package:janus_client/utils.dart';

class Streaming extends StatefulWidget {

  final int selectedStreamId;
  final Function isLoading;

  const Streaming({Key key, this.selectedStreamId, this.isLoading}) : super(key: key);
  @override
  _StreamingState createState() => _StreamingState();
}

class _StreamingState extends State<Streaming> {
  JanusClient janusClient = JanusClient(iceServers: [
    RTCIceServer(
        url: "stun:stun.voip.eutelia.it:3478", username: "", credential: "")
  ], server: "http://3.34.148.99:8088", withCredentials: true);
  Plugin publishVideo;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await _remoteRenderer.initialize();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    janusClient.connect(onSuccess: (sessionId) {
      janusClient.attach(Plugin(
          onRemoteStream: (remoteStream) {
            _remoteRenderer.srcObject = remoteStream as MediaStream;
          },
          plugin: "janus.plugin.streaming",
          onMessage: (msg, jsep) async {
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

            if (jsep != null) {
              debugPrint("Handling SDP as well...$jsep");
              await publishVideo.handleRemoteJsep(jsep);
              final RTCSessionDescription answer = await publishVideo.createAnswer();
              publishVideo.send(message: {"request": "start"}, jsep: answer);
            }
          },
          onSuccess: (plugin) {
            setState(() {
              publishVideo = plugin;
            });
            startStreaming();
          }));
    });
  }

  Future<void> startStreaming()async{
    widget.isLoading(true);
   await publishVideo.send(message: {
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
    janusClient.destroy();
    if (_remoteRenderer != null) {
      _remoteRenderer.srcObject = null;
      await _remoteRenderer.dispose();
    }
    await publishVideo.destroy();
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