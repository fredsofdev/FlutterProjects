import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebview extends StatelessWidget {
  final String appBarTitle;
  final String url;

  const CustomWebview({required this.appBarTitle, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
