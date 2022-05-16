import 'dart:io';

import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:flutter/material.dart';

class GameUsageLevelScreen extends StatefulWidget {
  @override
  _GameUsageLevelScreenState createState() => _GameUsageLevelScreenState();
}

class _GameUsageLevelScreenState extends State<GameUsageLevelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '게임 이용 등급',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(
                  '${AppConfig.appDocDirectory!.path}/osgame/screen/service/gul_12.png'),
              width: 180,
              height: 180,
            ),
            const Text('본 게임은 12세 이용 등급의 게임입니다.')
          ],
        ),
      ),
    );
  }
}
