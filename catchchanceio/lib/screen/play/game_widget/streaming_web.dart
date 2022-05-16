
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:janus_client/JanusClient.dart';
import 'package:janus_client/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StreamingWeb extends StatefulWidget {

  final int selectedStreamId;
  final Function isLoading;

  const StreamingWeb({required Key key ,required this.selectedStreamId, required this.isLoading}) : super(key: key);
  @override
  StreamingWebState createState() => StreamingWebState();
}

class StreamingWebState extends State<StreamingWeb> {
  WebViewController? controller;


  @override
  void initState() {
    print("StreamingWeb is initialized ${widget.selectedStreamId}");
    // widget.isLoading.call(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(

      color: Colors.blueAccent,
      child: WebView(
        initialUrl: 'http://3.34.148.99:5000/?name=${widget.selectedStreamId}',
        // initialUrl: 'http://google.com',
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        onWebViewCreated: (WebViewController webViewController){
          controller = webViewController;
        },
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: 'Complete',
              onMessageReceived: (JavascriptMessage message){
                if(message.message == 'Completed'){
                  widget.isLoading(false);
                }
              })
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller?.clearCache();
    controller = null;
  }
}