
import 'package:flutter/material.dart';
import 'package:flutter_app_webview/exchange.dart';
import 'package:page_transition/page_transition.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Screen"),
      ),
      body: Center(
        child: TextButton(onPressed: () async{
          await Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: const ExchangeScreen()));
        }, child: const Text("Goto Exchange")),
      )
    );
  }
}
