import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/widgets/etc/my_switch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketingAgreementScreen extends StatefulWidget {
  @override
  _MarketingAgreementScreenState createState() =>
      _MarketingAgreementScreenState();
}

class _MarketingAgreementScreenState extends State<MarketingAgreementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '광고성 정보 수신동의',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildSwitchList(
                text: '광고성 앱 푸시 수신 동의',
                value: AppConfig.setting.push,
                onChanged: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('setting_push', !prefs.getBool('setting_push')!);
                  AppConfig.setting.push = prefs.getBool('setting_push')!;
                  setState(() {});
                }),
            const Divider(),
            _buildSwitchList(
                text: '광고성 문자 수신 동의',
                value: AppConfig.setting.sms,
                onChanged: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('setting_sms', !prefs.getBool('setting_sms')!);
                  AppConfig.setting.sms = prefs.getBool('setting_sms')!;
                  setState(() {});
                }),
            const Divider(),
            _buildSwitchList(
                text: '광고성 이메일 수신 동의',
                value: AppConfig.setting.email,
                onChanged: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool(
                      'setting_email', !prefs.getBool('setting_email')!);
                  AppConfig.setting.email = prefs.getBool('setting_email')!;
                  setState(() {});
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchList({required String text, required bool value, required Function onChanged}) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          MySwitch(
            value: value,
            onChanged: (value) {
              onChanged();
            },
          )
        ],
      ),
    );
  }
}
