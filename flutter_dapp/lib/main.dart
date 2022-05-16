import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
   MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final infuraWc = WalletConnectProvider.fromInfura('https://mainnet.infura.io/ws/v3/9ebece031a1d44a5b9a66a4a6d75412');

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  void _connectWallet() async{
    await widget.infuraWc.connect();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connectWallet,
        tooltip: 'Connect',
        child: const Icon(Icons.account_balance_wallet_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
