
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_webview/shop.dart';
// import 'package:flutter_app_webview/shop.dart';

import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


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
        title: Text(widget.title),
      ),

      body: WebView(
        initialUrl: 'https://master.drs5grv2g5u4m.amplifyapp.com/',
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: {
          JavascriptChannel(
              name: 'messageHandler',
              onMessageReceived: (JavascriptMessage message) async{
                 print(message.message);
                 if(message.message == "login"){
                   await Navigator.push(
                       context,
                       PageTransition(
                           type: PageTransitionType.fade,
                           child: const ShopScreen()))
                   .then((value){
                     _controller!.reload();
                   });

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
