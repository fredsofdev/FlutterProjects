import 'dart:io';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/screen/service/service_screen.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/dialog/os_dialog.dart';
import 'package:catchchanceio/widgets/etc/my_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/setting/';
  BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
  EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xff2f294f),
            image: DecorationImage(
                image: FileImage(File('${_imagePath}bg.png')),
                fit: BoxFit.cover)),
        child: Column(
          children: [
            //todo appbar
            ScreenAppBar(
              buttons: [],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(
                  top: 30, left: 20, right: 20, bottom: 3),
              width: double.infinity,
              color: const Color(0xff2f294f),
              child: Column(
                children: [
                  OneSettingList(
                    text: '배경음',
                    value: AppConfig.setting.backgroundSound,
                    onChanged: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('setting_backgroundSound',
                          !prefs.getBool('setting_backgroundSound')!);
                      AppConfig.setting.backgroundSound =
                          prefs.getBool('setting_backgroundSound')!;
                      if (AppConfig.setting.backgroundSound) {
                        backgroundMusicPlayer.unMute();
                      } else {
                        backgroundMusicPlayer.mute();
                      }
                    },
                  ),
                  OneSettingList(
                    text: '효과음',
                    value: AppConfig.setting.soundEffect,
                    onChanged: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('setting_soundEffect',
                          !prefs.getBool('setting_soundEffect')!);
                      AppConfig.setting.soundEffect =
                          prefs.getBool('setting_soundEffect')!;
                      if (AppConfig.setting.soundEffect) {
                        effectMusicPlayer.unMute();
                      } else {
                        effectMusicPlayer.mute();
                      }
                      setState(() {});
                    },
                  ),
                  OneSettingList(
                    text: '진동',
                    value: AppConfig.setting.vibrate,
                    onChanged: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool(
                          'setting_vibrate', !prefs.getBool('setting_vibrate')!);
                      AppConfig.setting.vibrate =
                          prefs.getBool('setting_vibrate')!;
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 95,
                        height: 36,
                        child: RaisedButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showCustomDialog(
                                context: context,
                                contentText: '정말 로그아웃 하시겠습니까?',
                                confirmText: '로그아웃',
                                rejectText: '취소',
                                onConfirm: () {
                                  //todo logout with firebase
                                  context
                                      .read<AuthenticationBloc>()
                                      .add(AuthenticationLogoutRequested());
                                });
                          },
                          color: Colors.white70,
                          child: const Text(
                            '로그아웃',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 95,
                        height: 36,
                        child: RaisedButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: ServiceScreen()));
                          },
                          color: appMainColor,
                          child: const Text(
                            '고객센터',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class OneSettingList extends StatefulWidget {
  final String text;
  final bool value;
  final Function onChanged;

  const OneSettingList({required this.onChanged, required this.text, required this.value});

  @override
  _OneSettingListState createState() => _OneSettingListState();
}

class _OneSettingListState extends State<OneSettingList> {
  TextStyle ts = const TextStyle(
      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 18),
      width: double.infinity,
      height: 60,
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xffae9dcc), Color(0xff2f294f)])),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.text,
            style: ts,
          ),
          MySwitch(
            value: widget.value,
            onChanged: (value) {
              widget.onChanged();
            },
          )
        ],
      ),
    );
  }
}
