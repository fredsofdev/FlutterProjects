import 'dart:async';
import 'dart:io';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/hooks/gif_hook.dart';
import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/repository/play/connection_repository.dart';
import 'package:catchchanceio/repository/play/play_repository.dart';
import 'package:catchchanceio/screen/play/bloc/counter/counter_cubit.dart';
import 'package:catchchanceio/screen/play/bloc/play_bloc.dart';
import 'package:catchchanceio/vibrate/app_vibration.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:catchchanceio/widgets/buttons/press_button_image.dart';
import 'package:catchchanceio/widgets/texts/os_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';

class PlayPad extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final jSw = sw * 0.38;

    final playBloc = useBloc<PlayBloc, PlayState>(
        onEmitted: (_, p, c) =>
        // p.stageOn != c.stageOn ||
            p.connection != c.connection).state;

    return BlocProvider(
      create: (_) => CounterCubit(),
      child: SizedBox(
        width: sw,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [

            Image.file(
              File('${_imagePath}game_pad.png'),
              width: sw,
              fit: BoxFit.contain,
            ),


            /// X Y directional control
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: jSw,
                height: jSw,
                margin: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Image.file(File('${_imagePath}joy_bg.png')),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: PressButtonImage(
                                alignment: Alignment.topCenter,
                                depressImg: Image.file(
                                  File('${_imagePath}up_d.png'),
                                  width: jSw / 1.65,
                                ),
                                pressImg: Image.file(
                                  File('${_imagePath}up_e.png'),
                                  width: jSw / 1.65,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.forward));
                                  AppVibration.vibrate();
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                  AppVibration.cancel();
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: PressButtonImage(
                                alignment: Alignment.bottomCenter,
                                depressImg: Image.file(
                                  File('${_imagePath}down_d.png'),
                                  width: jSw / 1.65,
                                ),
                                pressImg: Image.file(
                                  File('${_imagePath}down_e.png'),
                                  width: jSw / 1.65,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(const SendControlEvent(
                                      Controls.backward));
                                  AppVibration.vibrate();
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                  AppVibration.cancel();
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: PressButtonImage(
                                alignment: Alignment.centerLeft,
                                depressImg: Image.file(
                                  File('${_imagePath}left_d.png'),
                                  width: jSw / 3,
                                ),
                                pressImg: Image.file(
                                  File('${_imagePath}left_e.png'),
                                  width: jSw / 3,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.left));
                                  AppVibration.vibrate();
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                  AppVibration.cancel();
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: PressButtonImage(
                                alignment: Alignment.centerRight,
                                depressImg: Image.file(
                                  File('${_imagePath}right_d.png'),
                                  width: jSw / 3,
                                ),
                                pressImg: Image.file(
                                  File('${_imagePath}right_e.png'),
                                  width: jSw / 3,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.right));
                                  AppVibration.vibrate();
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                  AppVibration.cancel();
                                },
                              ),
                            ),
                          ],
                        ),

                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: sw * 0.035,
              right: sw * 0.236,
              child: SizedBox(height: sw * 0.34, child: Grab()),
            ),

            Positioned(
              bottom: sw * 0.006,
              right: sw * 0.06,
              child: SizedBox(
                  width: sw * 0.15,
                  height: sw * 0.41,
                  child: DragButton(sw * 0.13)),
            ),

            // Visibility(
            //   visible: playBloc.connection == Connection.playing &&
            //       playBloc.stageOn,
            //   child: Positioned(
            //     left: (sw / 2) - ((sw * 0.3) / 2),
            //     bottom: sh * 0.51,
            //     child: Image.file(
            //       File(
            //           '${AppConfig.appDocDirectory!.path}/osgame/play2/portal/${playBloc.currentMachine.mStage}.png'
            //       ),
            //       width: sw * 0.3,
            //     ),
            //   ),
            // ),
            Visibility(
              visible: playBloc.connection == Connection.playing,
              child: Positioned(
                  bottom: sw*0.33,
                  child: IgnorePointer(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/play2/interior/${AppConfig.stageMapping[playBloc.currentMachine.mStage]}1.png'),width: sw,),
                        // Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/play2/interior/${AppConfig.stageMapping[playBloc.currentMachine.mStage]}2.png'),width: sw,),
                      ],
                    ),
                  )
              ),
            ),


            Align(
                child: TimeBox()
            ),

          ],
        ),
      ),
    );
  }
}


class Grab extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';

  @override
  Widget build(BuildContext context) {
    // final tickerProvider = useSingleTickerProvider();
    // final gifController =
    //     useGifController(provider: tickerProvider, duration: 700);

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(
          File('$_imagePath/yellow_ring.png'),
          fit: BoxFit.cover,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File('${_imagePath}grab_bg.png'),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width*0.308,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.306,
              height: MediaQuery.of(context).size.width*0.306,
              child: Stack(
                children: [
                  HookBuilder(builder: (context) {
                    final index = useState(0);
                    final playState =
                    useBloc<PlayBloc, PlayState>(onEmitted: (_, p, c) {
                      if (p.isClawOpen != c.isClawOpen) {
                        AppVibration.cancel();
                        index.value = 0;
                      }
                      if (p.start != c.start && c.start == Start.start){
                        index.value = 0;
                      }
                      return p.isClawOpen != c.isClawOpen;
                    }).state;
                    if (playState.isClawOpen) {
                      return GestureDetector(
                        onTap: () async {
                          if (index.value == 0) {
                            //todo crane_sound.mp4
                            index.value = 1;
                            final EffectMusicPlayer ef = EffectMusicPlayer();
                            ef.playOnce('crane_sound');
                            AppVibration.vibrate();
                            context.read<PlayBloc>().add(const SendControlEvent(Controls.grab));
                            // gifController.reset();
                            // gifController.animateTo(0);
                          }
                        },
                        child: IndexedStack(
                          index: index.value,
                          children: [
                            Image.file(
                              File('$_imagePath${makeFilename('grab.png')}'),
                              fit: BoxFit.cover,
                            ),
                            Image.file(
                              File('$_imagePath${makeFilename('grab_wait.png')}'),
                              fit: BoxFit.cover,
                            ),

                          ],
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () async{
                          if (index.value == 0) {
                            //todo crane_sound.mp4
                            index.value = 1;
                            final EffectMusicPlayer ef = EffectMusicPlayer();
                            ef.playOnce('crane_sound');
                            AppVibration.vibrate();
                            context.read<PlayBloc>().add(const SendControlEvent(Controls.release));
                            // gifController.reset();
                            // gifController.animateTo(0);
                          }
                        },
                        child: IndexedStack(
                          index: index.value,
                          children: [
                            Image.file(
                              File('$_imagePath${makeFilename('ungrab.png')}'),
                              fit: BoxFit.cover,
                            ),
                            Image.file(
                              File('$_imagePath${makeFilename('grab_wait.png')}'),
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                  // IgnorePointer(
                  //   child: GifImage(
                  //     controller: gifController,
                  //     image: FileImage(File('${_imagePath}btn_effect_trans.gif')),
                  //     fit: BoxFit.contain,
                  //   )
                  // ),
                ],
              ),
            ),

          ],
        )
      ],
    );
  }
}


class TimeBox extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    final gifConStart = useAnimationController(lowerBound: 0,upperBound: 80,initialValue: 0,duration: Duration(seconds: 2000));

    final addTimeLimit = useState(2);
    final playTime = useBloc<CounterCubit,int>(onEmitted: (_,p,c){

      if(p!=c && c == 5){
        context.read<PlayBloc>().add(const SendControlEvent(Controls.capStart));
      }

      if(p!=c && c == 1){
        context.read<PlayBloc>().add(const SendControlEvent(Controls.submit));
        // playBloc1.add(const EndGameEvent(false));
      }
      return p!=c;
    }).state;

    final playBloc =
        useBloc<PlayBloc, PlayState>(onEmitted: (_, p, c) {

          if(p.start != c.start && c.start == Start.start){
            gifConStart.reset();
            addTimeLimit.value = 2;

            gifConStart.animateTo(80, duration: Duration(milliseconds: 2000)).then((_){
              print("Started game");
              context.read<PlayBloc>().add(SetStartNoneEvent());
              context.read<CounterCubit>().startTimer(int.parse(c.currentMachine.mPlayTimeSec!));
            });
            return true;
          }
          if(p.start != c.start && c.start == Start.reset){
            return true;
          }
          if (p.popUps != c.popUps && c.popUps != PopUps.initial) {
            context.read<CounterCubit>().cancelTimer();
          }

          return p.start != p.start;
        }).state;

    final userState = useBloc<AuthenticationBloc, AuthenticationState>(
        onEmitted: (_, p, c) => p.user != c.user).state;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Positioned(
            bottom: sh * 0.31,
            left: sw * 0.5-34,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (playTime > 9) Image.file(File('${_imagePath}timer_frame.png'),width: 68,) else Image.file(File('${_imagePath}timer_frame_red.png'),width: 68,),
                    Text(AppConfig.lang == 'kor' ? '$playTime초': '$playTime s',style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)
                  ],
                ),
                IgnorePointer(
                  ignoring: !(playTime < 10 && playTime > 2 &&
                      userState.user.itemPlayTime != 0 && addTimeLimit.value != 0),
                  child: AnimatedOpacity(
                    opacity: playTime < 10 && playTime > 2 &&
                        userState.user.itemPlayTime != 0 && addTimeLimit.value != 0? 1.0 : 0.0,
                    duration: const Duration(),
                    child: Column(
                      children: [
                        Image.file(File('${_imagePath}timer.png'),width: 40,),
                        IgnorePointer(
                          ignoring: userState.user.itemPlayTime == 0,
                          child: CustomButton(
                            defaultImageFilePath : '$_imagePath${makeFilename('add_time_btn_e.png')}' ,
                            pressedImageFilePath : '$_imagePath${makeFilename('add_time_btn_d.png')}',
                            width: 60,
                            onPressed: () async {
                              final result = await context.read<PlayBloc>().addPlayTime();
                              if (result == AddItemResult.SUCCESS) {
                                context.read<PlayBloc>().add(const SendControlEvent(Controls.capCancel));
                                context.read<CounterCubit>().addTime(10);
                                addTimeLimit.value = addTimeLimit.value - 1;
                                // context.read<PlayBloc>().add(const SendControlEvent(Controls.cancelCap));
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 3,),
                        TextWithOutline(
                          text: '${addTimeLimit.value}/2',
                          innerColor: Colors.white,
                          outerColor: Colors.black87,
                          strokeWidth: 1.2,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: playBloc.start != Start.none,
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black38,
                  ),
                ),
              ),
              Visibility(
                visible: playBloc.start == Start.reset && !gifConStart.isAnimating,
                child: const TextWithOutline(
                  text: '초기화 중...',
                  innerColor: Colors.white,
                  outerColor: Colors.black87,
                  strokeWidth: 1.2,
                  fontSize: 18,
                ),
              ),
              Opacity(
                opacity: playBloc.start == Start.start ? 1 : 0,
                // child: AppConfig.isGif ? GifImage(
                //   width: 220,
                //   controller: gifConStart,
                //   image: FileImage(File('${_imagePath}startimg.gif')),
                // ) :
                child: Image.file(File('${_imagePath}startimg.png'),width: 220,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class DragButton extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';
  final double size;

  DragButton(this.size) : super();

  @override
  Widget build(BuildContext context) {
    final valueListener = useState(0.0);
    final isGoing = useState(false);
    final playBloc = useBloc<PlayBloc, PlayState>(
        onEmitted: (_, p, c) => p.isClawOpen != c.isClawOpen).state;
    if (playBloc.isClawOpen) {
      return Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.keyboard_arrow_down_sharp,color: Color(0xff645516),size: 20,),
            Container(
                padding: const EdgeInsets.fromLTRB(0.15, 0, 0.15, 0),
                child: Image.file(
                  File('${_imagePath}line_d.png'),
                  fit: BoxFit.cover,
                )),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          const Icon(Icons.keyboard_arrow_down_sharp,color: appMainColor,size: 20,),
          Text(AppConfig.lang=='kor'?'집게 내리기' : 'down' ,style: const TextStyle(color: Colors.white,fontSize: 11),),
          Stack(
            children: [
              Image.file(
                File('${_imagePath}line_e.png'),
                fit: BoxFit.cover,
              ),
              AnimatedBuilder(
                animation: valueListener,
                builder: (context, child) {
                  return Positioned(top: valueListener.value * 50, child: child!);
                },
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy >= 0.0) {
                      valueListener.value =
                      (valueListener.value + details.delta.dy * 1.4 / 110)
                          .clamp(.0, 1.0);
                      if (valueListener.value >= 0.3 && !isGoing.value) {
                        context.read<PlayBloc>().add(const SendControlEvent(Controls.down));
                        isGoing.value = true;
                      }
                    }
                  },
                  onVerticalDragEnd: (details) {
                    if (valueListener.value > 0.04) {
                      Timer.periodic(const Duration(milliseconds: 2), (timer) {
                        valueListener.value = valueListener.value - 0.02;
                        if (valueListener.value < 0.03) {
                          valueListener.value = 0.0;
                          timer.cancel();
                          context.read<PlayBloc>().add(const SendControlEvent(Controls.stop));
                          isGoing.value = false;
                        }
                      });
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(size * 0.08, size * 0.08, size * 0.06, 0),
                    child: Image.file(
                      File('${_imagePath}toggle.png'),
                      width: size,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}



