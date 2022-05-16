
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';


class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({Key? key}) : super(key: key);

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {


  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }


  @override
  Widget build(BuildContext context) {
    WebViewController? _controller;

    return Scaffold(
      appBar: AppBar(
        title:const Text("Exchange Screen"),
      ),
      body: WebView(
        initialUrl: 'https://master.drs5grv2g5u4m.amplifyapp.com/',
        onWebViewCreated: (controller){
          _controller = controller;

        },
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: {
          JavascriptChannel(
              name: 'messageHandler',
              onMessageReceived: (JavascriptMessage message) async{
                print(message.message);
                if(message.message == "logout"){
                  Navigator.of(context).pop();
                }

              })
        },
        navigationDelegate: (NavigationRequest request) async{
          print(request.url);
          if(request.url.contains("mailto:")) {
            await launch(request.url);
            return NavigationDecision.prevent;
          }
          else if (request.url.contains("tel:")) {
            await launch(request.url);
            return NavigationDecision.prevent;
          }
          else if (request.url.contains("wc:")) {
            bool isInstalled = await DeviceApps.isAppInstalled('io.metamask');

            if(isInstalled) {
              await launch(request.url);
            }else{
              await launch('https://play.google.com/store/apps/details?id=io.metamask');
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
