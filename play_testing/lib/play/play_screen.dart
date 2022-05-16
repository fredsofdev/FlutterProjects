import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:play_testing/app_config.dart';
import 'package:play_testing/connection_repository.dart';
import 'package:play_testing/custom_buttons.dart';
import 'package:play_testing/hooks/life_cycle_hook.dart';
import 'package:play_testing/os_dialog.dart';
import 'package:play_testing/play/bloc/counter/counter_cubit.dart';
import 'package:play_testing/play/game_widget/streaming.dart';
import 'package:play_testing/rooms_list.dart';
import 'package:play_testing/user_data.dart';
import 'bloc/play_bloc.dart';
import 'game_widget/game_pad.dart';
import 'game_widget/waiting_pad.dart';

class PlayScreen extends StatelessWidget {
  final UserData user;
  final String stage;

  const PlayScreen({this.user, this.stage});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: BlocProvider(
          create: (_) => PlayBloc(ConnectionRepository(),user),
          // child: _PlayView(machine,user),
          child: _Play(stage),
        ),
      ),
    );
  }
}

class _Play extends HookWidget {

  final String stage;

  _Play(this.stage);


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final playBloc = useBloc<PlayBloc, PlayState>(
        onEmitted: (_, p, c) {
          if (p.popUps != c.popUps && c.popUps != PopUps.initial) {
            _showResultOfGame(context,
                stageName: c.currentMachine.mStage,
                prizeCount: c.currentMachine.mPrize,
                isSuccess: c.popUps == PopUps.success, resultCall: (bool result) {
                  result != null && result
                      ? context.read<PlayBloc>().add(const EndGameEvent(true))
                      : context.read<PlayBloc>().add(const EndGameEvent(false));
                });
          }
          return p.connection != c.connection;
        }).state;
    useLifeCycleUpdate(context, lifeCycleUpdate: (state) {
      if (state == AppLifecycleState.resumed) {
        context.read<PlayBloc>()
            .add(const IsBackgroundEvent(isBackground: false));
      } else {
        context.read<PlayBloc>()
            .add(const IsBackgroundEvent(isBackground: true));
      }
    });

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final isLoading = useState(true);


    return WillPopScope(
      onWillPop: () async {
        var result = false;
        if (playBloc.connection == Connection.playing) {
          showCustomDialog(
              context: context,
              contentText: "정말로 게임을 나가시겠습니까?",
              confirmText: "나가기",
              rejectText: "취소",
              onConfirm: () {
                result = true;
                Navigator.pop(context);
              });
        }
        else {
          result = true;
        }
        return result;
      },
      child: Stack(
        children: [
          Stack(
            children: [
              IgnorePointer(
                child: SizedBox(
                  width: sw,
                  height: sh * 0.81,
                  child: HookBuilder(
                    builder: (context) {
                      final bloc = useBloc<PlayBloc, PlayState>(
                          onEmitted: (_, p, c) => p.currentMachine != c.currentMachine).state;

                      return bloc.currentMachine != RoomsList.empty ? Streaming(key: ValueKey(bloc.currentMachine.mId),
                          selectedStreamId:  bloc.currentMachine.mId,
                        isLoading: (bool loading){
                        if(loading){
                          isLoading.value = true;
                        }else{
                          isLoading.value = false;
                        }

                        },):const SizedBox();
                    }
                  ),
                ),
              ),
              HookBuilder(builder: (context) {

                final state = useBloc<PlayBloc, PlayState>(
                    onEmitted: (_, p, c) =>
                        p.users != c.users ||
                        p.currentPlayer != c.currentPlayer).state;
                return Visibility(
                  visible: state.users.isNotEmpty,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Visibility(
                              visible: !(state.currentPlayer['name'] == "empty" ||
                                  state.currentPlayer['name'] == "waiting" ||
                                  state.currentPlayer['name'] == null),
                              child: _buildUserCircleImage(
                                  url: state.currentPlayer['url'] == null
                                      ? ""
                                      : state.currentPlayer['url'].toString(),
                                  uId: state.currentPlayer['id'].toString())
                          ),
                          Expanded(
                              child: Container(
                            margin: const EdgeInsets.only(
                              left: 10,
                            ),
                            padding: const EdgeInsets.only(
                              left: 5,
                            ),
                            decoration: const BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        width: 2, color: Colors.white70))),
                            child: ScrollConfiguration(
                              behavior: NoGlowScrollBehavior(),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: state.users
                                      .map((e) => _buildUserCircleImage(
                                          url: e['url'] == null
                                              ? ""
                                              : e['url'].toString(),
                                          uId: e['id'].toString()))
                                      .toList(),
                                ),
                              ),
                            ),
                          )),
                          IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                size: 30,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // effectMusicPlayer.playOnce('click_main_ui');
                                if (state.connection == Connection.playing) {
                                  showCustomDialog(
                                    context: context,
                                    contentText: '정말로 게임을 나가시겠습니까?',
                                    confirmText: '나가기',
                                    rejectText: '취소',
                                    onConfirm: () {
                                      Navigator.pop(context);
                                    });
                                } else {
                                  Navigator.pop(context);
                                }
                              })
                        ],
                      ),
                      const SizedBox(height: 3,),
                    ],
                  ),
                );
              }),
            ],
          ),
          IndexedStack(
            index: playBloc.connection == Connection.playing ? 1 : 0,
            children: [
              WaitPad(stageName: stage),
              PlayPad(),
            ],
          ),

          // Visibility(
          //   visible: isLoading.value,
          //   child: FutureBuilder(
          //     future: videoFuture,
          //     builder: (context, snapshot) {
          //       return snapshot.connectionState == ConnectionState.done
          //         ? Stack(
          //           alignment: Alignment.bottomCenter,
          //           children: [
          //             VideoPlayer(videoController),
          //             const Positioned(
          //               bottom: 20,
          //               child: Text(
          //                 '네트워크 환경에 따라 로딩 시간이 지연될 수 있습니다.',
          //                 style: TextStyle(
          //                     color: Colors.black87,
          //                     fontSize: 11.5,
          //                     fontWeight: FontWeight.bold
          //                 ),
          //               ),
          //             )
          //           ],
          //           )
          //         : Container(
          //             width: sw,
          //             height: sh,
          //             color: Colors.white,
          //           );
          //     }),
          // ),
        ],
      ),
    );
  }

  Future<void> showConfirmRewardAd(BuildContext context, int count, String type,
      Function isPressed) async {
    await showDialog(
      barrierColor: Colors.black.withOpacity(0.2),
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ShowConfirmRewardView(type, count)),
    ).then((value){
      isPressed(value);
    });
  }

  Widget _buildUserCircleImage({String url, String uId}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () {
          //todo
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(url),
          radius: 20,
        ),
      ),
    );
  }

  Future<void> _showResultOfGame(
    BuildContext context, {
    bool isSuccess,
    int prizeCount,
    String stageName,
    Function resultCall,
  }) async {
    final result = await showDialog(
        barrierColor: Colors.black.withOpacity(0.3),
        context: context,
        builder: (context) => EndDialogView(stageName, prizeCount, isSuccess)
    );
    resultCall?.call(result);
  }

  // Future<void> _showChargePointDialog(BuildContext context,
  //     {Function resultShow, String playCoin}) async {
  //   final result = await showDialog(
  //       context: context,
  //       barrierColor: Colors.black.withOpacity(0.3),
  //       builder: (context) => BlocProvider(
  //           create:(_) => CounterCubit(),
  //           child: ChargePointView(playCoin: playCoin,)));
  //   resultShow?.call(result);
  // }
}


// class ChargePointView extends HookWidget {
//   final String _imagePath = '${AppConfig.appDocDirectory.path}/osgame/play2/';
//   final String playCoin;
//
//   ChargePointView({
//     this.playCoin
//   });
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 100.0),
//         child: Material(
//           color: Colors.transparent,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Image.file(
//                 File('${_imagePath}window_frame.png'),
//                 width: 325,
//               ),
//               const Positioned(
//                 top: 10,
//                 right: 115,
//                 child: Text(
//                   "5",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 28),
//                 )
//               ),
//
//               const Positioned(
//                   top: 16,
//                   right: 175,
//                   child: Text(
//                     '남은 시간',
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 14),
//                   )),
//               Positioned(
//                   top: 60,
//                   child: Text(
//                     playCoin == 'play_coin'? '플레이 포인트가 전부 소진되었습니다.\n무료 포인트를 충전 하시겠습니까?' : '플레이 코인을 구매하러\n상점으로 이동 하시겠습니까?',
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 14),
//                     textAlign: TextAlign.center,
//                   )),
//               Positioned(
//                 bottom: 15,
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     HookBuilder(
//                       builder: (context) {
//                         final userState =
//                         useBloc<AuthenticationBloc, AuthenticationState>(
//                             onEmitted: (_, prev, curr) {
//                               return prev.chargeRewardAdCount != curr.chargeRewardAdCount||prev.user!=curr.user;
//                             });
//                         return playCoin == 'play_coin'? Column(
//                           children: [
//                             if (userState.state.chargeRewardAdCount == 0) CustomButton(
//                               onPressed: () {
//                                 userState.add(ChargeAdRewardEvent());
//                                 Navigator.pop(context, true);
//                               },
//                               defaultImageFilePath:
//                               '${_imagePath}btn_yellow_e.png',
//                               pressedImageFilePath:
//                               '${_imagePath}btn_yellow_d.png',
//                               height: 45,
//                               width: 100,
//                               text: const Text(
//                                 '광고 시청',
//                                 style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ) else Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 Image.file(
//                                     File('${_imagePath}btn_grey.png'),
//                                     height: 45,
//                                     width: 100,),
//                                 const Text(
//                                   '광고 시청',
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold),
//                                 )
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 4,
//                             ),
//                             Visibility(
//                               visible: userState.state.chargeRewardAdCount != 0,
//                               child: Text(
//                                 '다음 획득까지 ${userState.state.chargeRewardAdCount}분',
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 15
//                                 ),
//                               ),
//                             )
//                           ],
//                         ) : Column(
//                           children: [
//                             CustomButton(
//                               onPressed: () async{
//                                 Navigator.pop(context, false);
//                                 await Navigator.push(
//                                     context,
//                                     PageTransition(
//                                         type: PageTransitionType.fade,
//                                         child: ShopScreen(userState.state.user.uId)));
//                               },
//                               defaultImageFilePath:
//                               '${_imagePath}btn_yellow_e.png',
//                               pressedImageFilePath:
//                               '${_imagePath}btn_yellow_d.png',
//                               height: 45,
//                               width: 120,
//                               text: const Text(
//                                 '상점으로 이동',
//                                 style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold
//                                 ),
//                               ),
//                             )
//                           ],
//                         );
//                       }
//                     ),
//                     const SizedBox(
//                       width: 40,
//                     ),
//                     CustomButton(
//                       onPressed: () {
//                         // ignore: avoid_print
//                         Navigator.pop(context, false);
//                       },
//                       defaultImageFilePath:
//                       '${_imagePath}btn_red_e.png',
//                       pressedImageFilePath:
//                       '${_imagePath}btn_red_d.png',
//                       height: 45,
//                       width: 100,
//                       text: const Text(
//                         '닫기',
//                         style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class EndDialogView extends HookWidget {
  final String stageName;
  final int prizeCount;
  final bool isSuccess;

  EndDialogView(this.stageName, this.prizeCount, this.isSuccess);

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => CounterCubit(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [

                Image.asset(
                    'assets/play/${isSuccess ? 'success' : 'fail'}_frame.png',
                    width: 320,
                    fit: BoxFit.contain),
                Positioned(
                  top: 30,
                  child: HookBuilder(builder: (context) {
                    final popTrigger = useState(-1);

                    final counter = useBloc<CounterCubit, int>();
                    useEffect(() {
                      counter.startTimer(5);
                      return null;
                    }, []);

                    if (counter.state == 0) {
                      popTrigger.value = 0;
                    }

                    if(popTrigger.value != -1){
                      Navigator.pop(context, popTrigger.value == 1);
                    }

                    return Row(
                      children: [
                        CustomButton(
                          defaultImageFilePath: 'assets/play/btn_1_e.png',
                          pressedImageFilePath: 'assets/play/btn_1_d.png',
                          width: 115,
                          text: IgnorePointer(
                              child: Text(
                                '${counter.state} 이어하기',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              )),
                          onPressed: () {
                            if (counter.state > 0) {
                              counter.cancelTimer();
                              popTrigger.value = 1;
                            }
                          },
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        CustomButton(
                          defaultImageFilePath: 'assets/play/btn_2_e.png',
                          pressedImageFilePath: 'assets/play/btn_2_d.png',
                          width: 115,
                          text:const IgnorePointer(
                          child: Text(
                              '그만하기',
                              style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                              ),
                          ),
                          onPressed: () {
                            if (counter.state > 0) {
                              counter.cancelTimer();
                              popTrigger.value = 0;
                            }
                          },
                        ),
                      ],
                    );
                  }),
                ),
                Positioned(
                    bottom: 20,
                    child: Image.asset(
                          'assets/play/${'msg_${isSuccess ? 'success' : 'fail'}.png'}',
                      width : 180,
                    )),
                Visibility(
                  visible: isSuccess,
                  child: Positioned(
                      top: 140,
                      left: 60,
                      child: Image.asset(
                        'assets/icons/${'prize_${AppConfig.stageMapping[stageName]}.png'}',
                        width: 75,
                      )),
                ),
                Visibility(
                  visible: isSuccess,
                  child: Positioned(
                      top: 200,
                      left: 135,
                      child: Text(
                        'X $prizeCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 23,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'fpt'),
                      )),
                ),
                Positioned(
                    left: isSuccess ? 40 : null,
                    top: isSuccess ? 250 : 250,
                    child: const Text(
                      '게임을 이어 하거나\n대기방으로 나갈수 있어요.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}