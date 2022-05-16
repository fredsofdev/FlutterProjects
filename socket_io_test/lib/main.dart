import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;




  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Socket socket;

  void connectToServer() {
    socket = io('http://222.119.99.42:8451', <String, dynamic>{
      'transports': ['websocket']
    });
    print("Connecting to Server %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    socket.on('connect', (_) {
      print("Connected to Server");
    });

    socket.on('disconnect', (_) {
      print("Disconnected from Server");
    });

    socket.on('on_disconnect', (data) {
      print("Disconnected with reason " + data.toString());
      socket.disconnect();
    });

    socket.on('machine_reserved', (_) {
      print("Machine reserved");

    });

    socket.on('machine_empty', (_) {
      print("Machine empty");
    });

    socket.on('confirm_play', (_) {
    });
  }

  void sendControlMessage(String message) {
    socket.emit('send_control', message);
    print("Message Sent");
  }

  void startGame(){
    socket.emit('start_game', {'laser': true,
      'stage': true});
    print("StartGame request sent");
  }

  @override
  void initState() {
    connectToServer();
    super.initState();
  }


  @override
  void dispose() {
    socket.clearListeners();
    socket.dispose();
    socket.destroy();
    super.dispose();
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
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
