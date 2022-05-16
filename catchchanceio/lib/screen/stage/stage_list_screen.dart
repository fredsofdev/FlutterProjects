import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/hooks/video_hook.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/screen/play/play_screen.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:catchchanceio/widgets/etc/route_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:video_player/video_player.dart';

class StageListScreen extends HookWidget {
  // final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/screen/stage_list/';
  final BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final double sw = MediaQuery
        .of(context)
        .size
        .width;
    final double sh = MediaQuery
        .of(context)
        .size
        .height;


    final videoController1 =
    useVideoController(videoUrl: '/osgame/screen/main/bg/bg.mp4');
    final videoFuture1 = useMemoized(() => videoController1.initialize());

    final stateAuth = useBloc<AuthenticationBloc,AuthenticationState>(onEmitted: (_,p,c)=>p.user!=c.user);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [

            FutureBuilder(
              future: videoFuture1,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox.expand(
                    child: FittedBox(
                      child: SizedBox(
                        width: sw,
                        height: sh,
                        child: VideoPlayer(videoController1),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    width: sw,
                    height: sh,
                    color: const Color(0xffffffff),
                  );
                }
              },
            ),

            SizedBox(
              width: sw,
              height: sh,
              child: Column(
                children: [
                  //todo appbar
                  ScreenAppBar(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.only(top: 34),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            Text(AppConfig.lang=='kor' ? '스테이지 선택' : 'Stage List',style: TextStyle(color: appMainColor,fontWeight: FontWeight.bold,fontSize: 25),),
                            const SizedBox(height:20,),
                            Row(
                              children: [
                                _buildPointBox(type: 'purple',point: stateAuth.state.user.itemPurpleCoin),
                                const SizedBox(width: 1,),
                                _buildPointBox(type: 'gold',point: stateAuth.state.user.itemGoldCoin),
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: false,
                              child: CustomButton(
                                defaultImageFilePath:
                                '${AppConfig.appDocDirectory!.path}/osgame/screen/room_list/btn_game_e.gif',
                                pressedImageFilePath:
                                '${AppConfig.appDocDirectory!.path}/osgame/screen/room_list/btn_game_d.png',
                                onPressed: () {
                                  _showGuideVideo(
                                      context: context,
                                      isShowBtn: false
                                  );
                                },
                                width: 60 * (166 / 205),
                                height: 60,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            CustomButton(
                              defaultImageFilePath:
                              '${AppConfig.appDocDirectory!.path}/osgame/screen/room_list/${makeFilename('btn_joy_e.gif')}',
                              pressedImageFilePath:
                              '${AppConfig.appDocDirectory!.path}/osgame/screen/room_list/${makeFilename('btn_joy_d.png')}',
                              onPressed: () {
                                _showGuideImageSlide(
                                    context: context);
                              },
                              width: 70 * (166 / 217),
                              height: 70,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 4),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            OneStageList(stageType: 'stage2',pointType: 'blue',onPress: () async{
                              backgroundMusicPlayer.playLoop('in_game_mine');
                              videoController1.pause();
                              await Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType
                                        .fade,
                                    child: PlayScreen(
                                        user: stateAuth.state.user,stage: "stage2",)));
                              backgroundMusicPlayer.playLoop('a_main');
                              videoController1.play();
                              }),  //todo purple, blue, gold
                            OneStageList(stageType: 'stage1',pointType: 'blue',onPress: ()async{
                              backgroundMusicPlayer.playLoop('in_game_mine');
                              videoController1.pause();
                              await Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType
                                          .fade,
                                      child: PlayScreen(
                                        user: stateAuth.state.user,stage: "stage1",)));
                              backgroundMusicPlayer.playLoop('in_game_forest');
                              videoController1.play();
                            }),
                            OneStageList(stageType: 'stage3',pointType: 'blue',onPress: ()async{
                              backgroundMusicPlayer.playLoop('in_game_mine');
                              videoController1.pause();
                              await Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType
                                          .fade,
                                      child: PlayScreen(
                                        user: stateAuth.state.user,stage: "stage3",)));
                              backgroundMusicPlayer.playLoop('a_main');
                              videoController1.play();
                            }),
                            OneStageList(stageType: 'stage4',pointType: 'purple',onPress: ()async{
                              backgroundMusicPlayer.playLoop('in_game_sea');
                              videoController1.pause();
                              await Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType
                                          .fade,
                                      child: PlayScreen(
                                        user: stateAuth.state.user,stage: "stage4",)));
                              backgroundMusicPlayer.playLoop('a_main');
                              videoController1.play();
                            }),
                            OneStageList(stageType: 'stage5',pointType: 'purple',onPress: () async{
                              backgroundMusicPlayer.playLoop('in_game_dia');
                              videoController1.pause();
                              await Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType
                                          .fade,
                                      child: PlayScreen(
                                        user: stateAuth.state.user,stage: "stage5",)));
                              backgroundMusicPlayer.playLoop('a_main');
                              videoController1.play();
                            }),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPointBox({required String type, required int point}){
  return Stack(
    children: [
        Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/screen/stage_list/point_box.png',),width: 75,),
        Positioned(
            left: 6,
            child: Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/play_coin_$type.png'),width: 15,)
        ),
        Positioned(
            top: 1.5,
            right: 3,
            child: Container(
              width: 50,
              color: Colors.transparent,
              child: Center(
                child:Text('$point',style: const TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),),
              ),
            )
        )
    ],
  );
}

class OneStageList extends StatelessWidget {

  final String pointType;
  final String stageType;
  final Function onPress;

  const OneStageList({
    required this.stageType,
    required this.pointType,
    required this.onPress
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final int lv = AppConfig.stageDifficultyLevel[stageType]!;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Stack(
        children: [
          Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/screen/stage_list/${makeFilename('list_${AppConfig.stageMapping[stageType]}.png')}')),
          Positioned(
            right: sw*0.36,
            bottom: sw*0.012,
            child: Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/prize_${AppConfig.stageMapping[stageType]}.png'),width: sw*0.09,),
          ),
          Positioned(
            bottom: sw*0.012,
            right: sw*0.09,
            child: CustomButton(
              defaultImageFilePath:
              '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_e.png',
              pressedImageFilePath:
              '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_d.png',
              text: Row(
                children: [
                  Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/play_coin_$pointType.png',),width: 18,),
                  const SizedBox(width: 4,),
                  Text(AppConfig.lang=='kor' ? '게임시작' : 'Play',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize:12),),
                ],
              ),
              onPressed: (){
               onPress();

              },
              width: 82,
            ),
          ),
          Positioned(
              right: sw*0.06,
              top: sw*0.17,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/screen/stage_list/lv_bg_frame.png'),width: 120,),
                  Row(
                    children: [
                      Text(AppConfig.lang=='kor' ? '난이도' : 'level',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 10),),
                      const SizedBox(width: 3,),
                      Row(
                          children: [
                            Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/star_${lv>=1 ? 'e' : 'd'}.gif'),width:11,),
                            RoutWidget(child: Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/star_${lv>=2 ? 'e' : 'd'}.gif'),width:11,)),
                            RoutWidget(child: Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/star_${lv>=3 ? 'e' : 'd'}.gif'),width:11,)),
                            RoutWidget(child: Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/star_${lv>=4 ? 'e' : 'd'}.gif'),width:11,)),
                            RoutWidget(child: Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/star_${lv>=5 ? 'e' : 'd'}.gif'),width:11,)),
                          ],
                      )
                    ],
                  )
                ],
              )
          )

        ],
      ),
    );
  }
}

// ignore: avoid_void_async
void _showGuideImageSlide({required BuildContext context}) async {
  final _path = '${AppConfig.appDocDirectory!.path}/osgame/video/';
  await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 0.47368,
            viewportFraction: 1,
            enableInfiniteScroll: false
          ),
          items: [
            Image.file(File('${_path}${makeFilename('guide.png')}')),
          ],
        ),
      ));
}

Future<void> _showGuideVideo({required BuildContext context,required bool isShowBtn}) async {
  BackgroundMusicPlayer.instance.pauseLoop();
  await showDialog(
      context: context,
      builder: (_) => AlertDialog(
          backgroundColor: Colors.transparent,
          content: _ShowGuideVideo(isShowBtn:isShowBtn)
      )).then((value) {
    BackgroundMusicPlayer.instance.resumeLoop();
  });
}

class _ShowGuideVideo extends HookWidget {
  final bool isShowBtn;

  const _ShowGuideVideo({
    required this.isShowBtn
  });

  @override
  Widget build(BuildContext context) {
    final videoController =
    useVideoController(videoUrl: '/osgame/video/guide_forest.mp4');
    final videoFuture = useMemoized(() => videoController.initialize());
    useEffect(() {
      videoController.play();
      videoController.addListener(() {
        if (!videoController.value.isPlaying &&
            videoController.value.isInitialized &&
            (videoController.value.duration ==
                videoController.value.position)) {
          Navigator.pop(context);
        }
      });
      return null;
    }, []);

    return FutureBuilder(
      future: videoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
            height: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.black,
                  height: 400,
                  child:  VideoPlayer(videoController),
                ),
                const SizedBox(height: 10,),
                Visibility(
                  visible: isShowBtn,
                  child: GestureDetector(
                    onTap: () async{
                      final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                      final SharedPreferences prefs = await _prefs;
                      await prefs.setBool("isFirst",false);
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                         Icon(Icons.cancel,size: 21,color: Color(0xfff2f2f2),),
                         SizedBox(width: 6,),
                         Text('다시 보지않기',style: TextStyle(color: Color(0xfff2f2f2),fontWeight: FontWeight.bold,fontSize: 19),),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return Container(
            color: const Color(0xffffffff).withOpacity(0.0),
          );
        }
      },
    );
  }
}


