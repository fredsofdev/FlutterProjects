import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';


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
        primaryColor: Colors.deepOrangeAccent,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:ControlScreen(),
    );
  }
}

class ControlScreen extends StatefulWidget {



  @override
  _ControlScreenState createState() => _ControlScreenState();




}

class _ControlScreenState extends State<ControlScreen> {
  TextStyle _t = TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Colors.white);
  double _margin = 15;
  IO.Socket socket;
  final ip = "192.168.50.137";
  final port = "1234";

  void connect(){
    socket = IO.io('http://'+ip+':'+port, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false}).connect();

    socket.on('connect', (_) {
      print("Connected to Server");

      Fluttertoast.showToast(
          msg: "Connected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );

    });

    socket.on('disconnect', (_) {
      print("Disconnect from Server");

      Fluttertoast.showToast(
          msg: "Disconnected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );

    });
  }


  void sendControl(String data){
    socket.emit('my_message',data);
  }

  @override
  void initState() {
    connect();
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
        title: Text('머신 테스트'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.blueAccent,
                //todo move horizontal
                child: Text('수평 이동',style: _t,),
                onPressed: (){
                  if(socket.connected){
                    sendControl("RightON");
                  }
                },
              ),
            ),
            SizedBox(height: _margin,),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.orange,
                //todo move vertical
                child: Text('수직 이동',style: _t,),
                onPressed: (){
                  if(socket.connected){
                    sendControl("LeftON");
                  }
                },
              ),
            ),
            SizedBox(height: _margin,),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.pink,
                //todo grab
                child: Text('집게 잡기',style: _t,),
                onPressed: (){
                  if(socket.connected){
                    sendControl("Gclose");
                  }
                },
              ),
            ),
            SizedBox(height: _margin,),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.teal,
                // todo release grab
                child: Text('집게 풀기',style: _t,),
                onPressed: (){
                  if(socket.connected){
                    sendControl("Gclose");
                  }
                },
              ),
            ),
            SizedBox(height: _margin,),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.deepPurpleAccent,
                //todo go high
                child: Text('들어올리기',style: _t,),
                onPressed: (){
                  if(socket.connected){
                    sendControl("Gup");
                  }
                },
              ),
            ),
            SizedBox(height: _margin,),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.deepPurpleAccent,
                //todo go high
                child: Text('들어네리기',style: _t,),
                onPressed: (){
                  if(socket.connected){
                    sendControl("Gdown");
                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}


