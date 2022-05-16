import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:play_testing/app_config.dart';
import 'package:play_testing/color.dart';
import 'package:play_testing/connection_repository.dart';
import 'package:play_testing/custom_buttons.dart';
import 'package:play_testing/os_text.dart';
import 'package:play_testing/play/bloc/counter/counter_cubit.dart';
import 'package:play_testing/play/bloc/play_bloc.dart';

class PlayPad extends HookWidget {

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final jSw = sw * 0.38;

    final playBloc = useBloc<PlayBloc, PlayState>(
        onEmitted: (_, p, c) =>
        p.stageOn != c.stageOn ||
            p.connection != c.connection).state;

    return BlocProvider(
      create: (_) => CounterCubit(),
      child: SizedBox(
        width: sw,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [

            Image.asset(
              'assets/play/game_pad.png',
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
                    Image.asset('assets/play/joy_bg.png'),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: PressButtonImage(
                                alignment: Alignment.topCenter,
                                depressImg: Image.asset(
                                  'assets/play/up_d.png',
                                  width: jSw / 1.65,
                                ),
                                pressImg: Image.asset(
                                  'assets/play/up_e.png',
                                  width: jSw / 1.65,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.forward));
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: PressButtonImage(
                                alignment: Alignment.bottomCenter,
                                depressImg: Image.asset(
                                  'assets/play/down_d.png',
                                  width: jSw / 1.65,
                                ),
                                pressImg: Image.asset(
                                  'assets/play/down_e.png',
                                  width: jSw / 1.65,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(const SendControlEvent(
                                      Controls.backward));
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: PressButtonImage(
                                alignment: Alignment.centerLeft,
                                depressImg: Image.asset(
                                  'assets/play/left_d.png',
                                  width: jSw / 3,
                                ),
                                pressImg: Image.asset(
                                  'assets/play/left_e.png',
                                  width: jSw / 3,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.left));
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: PressButtonImage(
                                alignment: Alignment.centerRight,
                                depressImg: Image.asset(
                                  'assets/play/right_d.png',
                                  width: jSw / 3,
                                ),
                                pressImg: Image.asset(
                                  'assets/play/right_e.png',
                                  width: jSw / 3,
                                ),
                                press: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.right));
                                },
                                depress: () {
                                  context.read<PlayBloc>().add(
                                      const SendControlEvent(Controls.stop));
                                },
                              ),
                            ),
                          ],
                        )

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

            Visibility(
              visible: playBloc.connection == Connection.playing,
              child: Positioned(
                  bottom: sw*0.33,
                  child: IgnorePointer(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/play/interior/${AppConfig.stageMapping[playBloc.currentMachine.mStage]}1.png',width: sw,),
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

class Grab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/play/yellow_ring.png',
          fit: BoxFit.cover,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/play/grab_bg.png',
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
                        index.value = 0;
                      }
                      return p.isClawOpen != c.isClawOpen;
                    }).state;
                    if (playState.isClawOpen) {
                      return GestureDetector(
                        onTap: () {
                          if (index.value == 0) {
                            //todo crane_sound.mp4
                            index.value = 1;
                            context.read<PlayBloc>().add(const SendControlEvent(Controls.grab));
                          }
                        },
                        child: IndexedStack(
                          index: index.value,
                          children: [
                            Image.asset(
                              'assets/play/toggle.png',
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/play/grab_bg.png',
                              fit: BoxFit.cover,
                            ),

                          ],
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          if (index.value == 0) {
                            //todo crane_sound.mp4
                            index.value = 1;
                            context.read<PlayBloc>().add(const SendControlEvent(Controls.release));
                          }
                        },
                        child: IndexedStack(
                          index: index.value,
                          children: [
                            Image.asset(
                              'assets/play/radio_e.png',
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/play/radio_d.png',
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      );
                    }
                  }),
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

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    final addTimeLimit = useState(2);
    final playTime = useBloc<CounterCubit,int>(onEmitted: (_,p,c){
      if(p!=c && c == 2){
        context.bloc<PlayBloc>().add(const SendControlEvent(Controls.capStart));
        context.bloc<PlayBloc>().add(const SendControlEvent(Controls.submit));
        // playBloc1.add(const EndGameEvent(false));
      }
      if(p!=c && c == 1){
        context.bloc<PlayBloc>().add(const SendControlEvent(Controls.capResult));
        // playBloc1.add(const EndGameEvent(false));
      }
      return p!=c;
    });

    final playBloc =
        useBloc<PlayBloc, PlayState>(onEmitted: (_, p, c) {

          if(p.start != c.start && c.start == Start.start){

            addTimeLimit.value = 2;

            context.read<PlayBloc>().add(SetStartNoneEvent());
            playTime.startTimer(int.parse(c.currentMachine.mPlayTimeSec));

            return true;
          }
          if(p.start != c.start && c.start == Start.reset){
            return true;
          }
          if (p.popUps != c.popUps && c.popUps != PopUps.initial) {
            playTime.cancelTimer();
          }

          return p.start != p.start;
        }).state;


    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Positioned(
            bottom: sh * 0.35,
            left: sw * 0.5-34,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (playTime.state > 9) Image.asset('assets/play/timer_frame.png',width: 68,) else Image.asset('assets/play/timer_frame_red.png',width: 68,),
                    Text('${playTime.state}초',style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)
                  ],
                ),
                AnimatedOpacity(
                  opacity: playTime.state < 10 && playTime.state > 2 &&
                       addTimeLimit.value != 0? 1.0 : 0.0,
                  duration: const Duration(),
                  child: Column(
                    children: [
                      CustomButton(
                        defaultImageFilePath:'assets/play/add_time_btn_e.png' ,
                        pressedImageFilePath: 'assets/play/add_time_btn_d.png',
                        width: 60,
                        onPressed: ()async{
                          final result = await context.read<PlayBloc>().addPlayTime();
                          if (result == AddItemResult.SUCCESS) {
                            playTime.addTime(10);
                            addTimeLimit.value = addTimeLimit.value - 1;
                            context.bloc<PlayBloc>().add(const SendControlEvent(Controls.cancelCap));
                          }
                        },
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
            ],
          ),
        ],
      ),
    );
  }
}

class DragButton extends HookWidget {
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
                child: Image.asset(
                  'assets/play/line_d.png',
                  fit: BoxFit.cover,
                )),
          ],
        ),
      );
    } else {
      return Column(

        children: [
          const Icon(Icons.keyboard_arrow_down_sharp,color: appMainColor,size: 20,),
          const Text('집게 내리기',style: TextStyle(color: Colors.white,fontSize: 11),),
          Stack(
            children: [
              Image.asset(
                'assets/play/line_e.png',
                fit: BoxFit.cover,
              ),
              AnimatedBuilder(
                animation: valueListener,
                builder: (context, child) {
                  return Positioned(top: valueListener.value * 50, child: child);
                },
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy >= 0.0) {
                      valueListener.value =
                      (valueListener.value + details.delta.dy * 1.4 / 110)
                          .clamp(.0, 1.0) as double;
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
                    child: Image.asset(
                      'assets/play/toggle.png',
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



