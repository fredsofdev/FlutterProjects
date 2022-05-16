import 'dart:io';

import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:flutter/material.dart';

class MyLoginScreen extends StatefulWidget {
  final String loginProvider;


  const MyLoginScreen({ required this.loginProvider});

  @override
  _MyLoginScreenState createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/logo/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 연동 계정',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File('$_imagePath${'${widget.loginProvider}_logo.png'}'),
              fit: BoxFit.cover,
              width: 100,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              '${widget.loginProvider} 계정으로 연동 중입니다.',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5),
            )
          ],
        ),
      ),
    );
  }
}
