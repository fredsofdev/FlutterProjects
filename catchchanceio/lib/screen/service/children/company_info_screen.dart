import 'dart:io';

import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:flutter/material.dart';

class CompanyInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회사 정보',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              child: Image.file(
                File(
                    '${AppConfig.appDocDirectory!.path}/osgame/logo/compnay_icon_logo.png'),
                width: 200,
              ),
            ),
            _buildList(t: '상호', c: '오렌지스텝'),
            _buildList(t: '주소', c: '경상남도 창원시 진해구 웅동로 166, 301호'),
            _buildList(t: '대표', c: '김현기'),
            _buildList(t: '전화', c: '070-7579-1397'),
            _buildList(t: 'email', c: 'support@orangestep.co.kr'),
          ],
        ),
      ),
    );
  }

  Widget _buildList({required String t, required String c}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: 56,
              height: 24,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Colors.black87),
              child: Center(
                  child: Text(
                t,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ))),
          Expanded(
              child: Container(
                  padding: const EdgeInsets.only(left: 22),
                  child: Text(
                    c,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  )))
        ],
      ),
    );
  }
}
