import 'dart:io';
import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/screen/mail/mail_screen.dart';
import 'package:catchchanceio/screen/profile/profile_screen.dart';
import 'package:catchchanceio/screen/setting/setting_screen.dart';
import 'package:catchchanceio/style/clipper/os_clipper.dart';
import 'package:catchchanceio/widgets/etc/route_widget.dart';
import 'package:catchchanceio/widgets/texts/os_marquee.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:page_transition/page_transition.dart';

class ScreenAppBar extends HookWidget {

  final List<Buttons> buttons;
  final bool isMain;
  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();
  final String _appBarPath =
      '${AppConfig.appDocDirectory!.path}/osgame/appbar/';
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main/';
  final String _iconPath = '${AppConfig.appDocDirectory!.path}/osgame/icons/';

   ScreenAppBar(
      {
        this.buttons = const [Buttons.mail,Buttons.settings],
        this.isMain = false,
      });

  @override
  Widget build(BuildContext context) {


    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final h1 = sw * 0.05;
    // final h1 = 40.0;

    final bloc = useBloc<AuthenticationBloc, AuthenticationState>(
        onEmitted: (_, p, c) => p.user != c.user);

    return SizedBox(
      height: sh * 0.2,
      child: Column(
        children: [
          SizedBox(height: h1,),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                File('$_imagePath/ui/app_bar.png'),
                fit: BoxFit.cover,
                width: sw,
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18,7,0,7),
                      child: IndexedStack(
                        index: isMain ? 1 : 0,
                        children: [
                          BackButtonPolygonBox(),
                          GestureDetector(
                            onTapDown: (d) {
                              effectMusicPlayer.playOnce('click_main_ui');
                            },
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: ProfileScreen()));
                            },
                            child: ProfileImagePolygonBox(
                              url: bloc.state.user.uImgBig,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0,(h1*0.2),0,0),
                          child: SizedBox(
                            width: sw * 0.805,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Image.file(
                                  File('${_imagePath}ui/info_box_grey.png'),
                                  height: h1,
                                  width: sw * 0.24,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: sw * 0.035,
                                  child: Container(
                                    width: sw * 0.18,
                                    height: h1,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        bloc.state.user.uName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    left: sw * 0.23,
                                    child: Image.file(
                                      File('$_appBarPath/info_box1.png'),
                                      height: h1,
                                    )),
                                Positioned(
                                    left: sw * 0.25,
                                    child: Image.file(
                                      File('${_iconPath}play_coin.png'),
                                      height: h1 * 0.85,
                                    )),
                                Positioned(
                                  left: sw * 0.315,
                                  child: SizedBox(
                                    width: sw * 0.12,
                                    child: Center(
                                      child: Text(
                                        '${bloc.state.user.uPlayCoin}/${bloc.state.exchangeAd['max_auto_charge']}',
                                        style: TextStyle(
                                            fontSize:
                                            bloc.state.user.uPlayCoin.toString().length > 3
                                                ? 10
                                                : 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xffffc715)),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: sw * 0.454,
                                  child: Container(
                                    color: Colors.transparent,
                                    width: sw * 0.1,
                                    child: Center(
                                      child: HookBuilder(builder: (_) {
                                        final state =
                                            useBloc<AuthenticationBloc, AuthenticationState>(
                                                onEmitted: (_, p, c) =>
                                                p.rewardTime != c.rewardTime).state;
                                        return Text(
                                          ((state.rewardTime ~/ 60).toString().length > 1
                                              ? '${state.rewardTime ~/ 60}:'
                                              : '0${state.rewardTime ~/ 60}:') +
                                              ((state.rewardTime % 60).toString().length > 1
                                                  ? '${state.rewardTime % 60}'
                                                  : '0${state.rewardTime % 60}'),
                                          style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        );
                                      }),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  left: sw * 0.6,
                                  child: SizedBox(
                                    width: h1 * 3.2,
                                    child: Row(

                                      mainAxisAlignment: MainAxisAlignment.end,

                                      children: buttons.map((e){
                                        if(e == Buttons.settings){
                                          return Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: GestureDetector(
                                                onPanDown: (d) {
                                                  effectMusicPlayer.playOnce('click_main_ui');
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type: PageTransitionType.fade,
                                                          child: SettingScreen()));
                                                },
                                                child: Image.file(
                                                  File('${_imagePath}ui/btn_setting.png'),
                                                  height: h1,
                                                )),
                                          );
                                        }else{
                                          return Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: GestureDetector(
                                                onPanDown: (d) {
                                                  effectMusicPlayer.playOnce('click_main_ui');
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type: PageTransitionType.fade,
                                                          child: MailScreen(
                                                            myId: bloc.state.user.uId,
                                                            isNotice: false,
                                                          )));
                                                },
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Image.file(
                                                      File('${_imagePath}ui/btn_mail.png'),
                                                      height: h1,
                                                    ),
                                                    Visibility(
                                                      visible: bloc.state.user.isNewMail,
                                                      child: Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration: BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius: BorderRadius.circular(10)),
                                                      ),
                                                    )
                                                  ],
                                                )),
                                          );
                                        }

                                      }).toList(),
                                    ),
                                  ),
                                ),

                                // Visibility(
                                //   visible: isShowMail,
                                //   child: Positioned(
                                //       left: sw * 0.62,
                                //       child: GestureDetector(
                                //           onPanDown: (d) {
                                //             effectMusicPlayer.playOnce('click_main_ui');
                                //           },
                                //           onTap: () {
                                //             Navigator.push(
                                //                 context,
                                //                 PageTransition(
                                //                     type: PageTransitionType.fade,
                                //                     child: MailScreen(
                                //                       myId: bloc.state.user.uId,
                                //                       isNotice: false,
                                //                     )));
                                //           },
                                //           child: Stack(
                                //             alignment: Alignment.topRight,
                                //             children: [
                                //               Image.file(
                                //                 File('${_imagePath}ui/btn_mail.png'),
                                //                 height: h1,
                                //               ),
                                //               Visibility(
                                //                 visible: bloc.state.user.isNewMail,
                                //                 child: Container(
                                //                   width: 8,
                                //                   height: 8,
                                //                   decoration: BoxDecoration(
                                //                       color: Colors.red,
                                //                       borderRadius: BorderRadius.circular(10)),
                                //                 ),
                                //               )
                                //             ],
                                //           ))),
                                // ),
                                // Visibility(
                                //   visible: isShowSetting,
                                //   child: Positioned(
                                //       left: sw * 0.71,
                                //       child: GestureDetector(
                                //           onPanDown: (d) {
                                //             effectMusicPlayer.playOnce('click_main_ui');
                                //           },
                                //           onTap: () {
                                //             Navigator.push(
                                //                 context,
                                //                 PageTransition(
                                //                     type: PageTransitionType.fade,
                                //                     child: SettingScreen()));
                                //           },
                                //           child: Image.file(
                                //             File('${_imagePath}ui/btn_setting.png'),
                                //             height: h1,
                                //           ))),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: h1*0.4,),
                        Row(
                          children: [
                            SizedBox(width: sw*0.03,),
                            Image.file(
                              File('${_imagePath}ui/icon_mic.png'),
                              width: sw * 0.05,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 5, right: 4),
                                color: Colors.transparent,
                                height: sw * 0.06,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onPanDown: (d) {
                                      effectMusicPlayer.playOnce('click_main_ui');
                                    },
                                    onTap: () {
                                      if (buttons.contains(Buttons.mail)) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MailScreen(
                                                myId: bloc.state.user.uId,
                                                isNotice: true,
                                              )),
                                        );
                                      }
                                    },
                                    child: RoutWidget(
                                      child: OSMarquee(
                                        text: bloc.state.notice.isNotEmpty
                                            ? '${bloc.state.notice[0]['title']}  ${bloc.state.notice[1]['title']}  ${bloc.state.notice[2]['title']}'
                                            : "Hello !!!",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );

  }

}

enum Buttons{settings,mail}

class BackButtonPolygonBox extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main';

  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();

  BackButtonPolygonBox();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    final boxWidth = sw * 0.15;
    final boxHeight = boxWidth / 1.12834226;

    return GestureDetector(
      onPanDown: (d) {
        effectMusicPlayer.playOnce('click_main_ui');
      },
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: boxWidth + 6,
        height: boxHeight + 6,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipPath(
              clipper:
                  ProfileImageClipper(width: boxWidth, distance: boxWidth / 2),
              child: Container(
                width: boxWidth,
                height: boxHeight,
                decoration: const BoxDecoration(
                  color: Color(0xffaf9879),
                ),
              ),
            ),
            Image.file(
              File('$_imagePath/ui/back_btn_frame.png'),
              width: boxWidth + 6,
              height: boxHeight + 6,
              fit: BoxFit.cover,
            )
          ],
        ),
      ),
    );
  }
}

class ProfileImagePolygonBox extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main';
  final String url;

  ProfileImagePolygonBox({required this.url});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    final boxWidth = sw * 0.15;
    final boxHeight = boxWidth / 1.12834226;

    return Container(
      width: boxWidth + 6,
      height: boxHeight + 6,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipPath(
            clipper:
                ProfileImageClipper(width: boxWidth, distance: boxWidth / 2),
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                  color: const Color(0xff01b7ff),
                  image: DecorationImage(
                      image: NetworkImage(url), fit: BoxFit.cover)),
            ),
          ),
          Image.file(
            File('$_imagePath/ui/pf_frame.png'),
            width: boxWidth + 6,
            height: boxHeight + 6,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}

class ProfileImagePolygonBox1 extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main';
  final String url;
  final double size;
  final String colorType;
  ProfileImagePolygonBox1({required this.url,required this.size,required this.colorType});

  @override
  Widget build(BuildContext context) {
    //final sw = MediaQuery.of(context).size.width;

    final boxWidth = size;
    final boxHeight = size / 1.12834226;

    return Container(
      width: boxWidth + 6,
      height: boxHeight + 6,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipPath(
            clipper:
            ProfileImageClipper(width: boxWidth, distance: boxWidth / 2),
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                  color: const Color(0xff01b7ff),
                  image: DecorationImage(
                      image: NetworkImage(url), fit: BoxFit.cover)),
            ),
          ),
          Image.file(
            File('$_imagePath/etc/prf_frame_$colorType.png'),
            width: boxWidth + 6,
            height: boxHeight + 6,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}
