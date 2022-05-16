import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/repository/play/model/rooms_list.dart';
import 'package:catchchanceio/screen/play/bloc/counter/counter_cubit.dart';
import 'package:catchchanceio/screen/play/bloc/play_bloc.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:catchchanceio/windows/reward_ad_window.dart';
import 'package:division/division.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';

class WaitPad extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/';
  final String stageName;
  WaitPad({
    required this.stageName
  });

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => CounterCubit(),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HookBuilder(
              builder: (_) {
                final userState =
                    useBloc<AuthenticationBloc, AuthenticationState>(
                        onEmitted: (_, prev, curr) {
                  return prev.user != curr.user ||
                      prev.laserRewardAdCount != curr.laserRewardAdCount ||
                      prev.timeRewardAdCount != curr.timeRewardAdCount;
                }).state;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OneItemAdBox(
                      leftCount: userState.user.itemPlayTime,
                      imageUrl: '${_imagePath}icons/item_addtime.png',
                      adCount: userState.timeRewardAdCount,
                      onPressed: () async {
                        showConfirmRewardAd(
                            context,
                            userState.exchangeAd['item_time'] as int,
                            "addtime",
                            (bool value)async{
                              if(value != null && value){

                                final bool result = await Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: RewardAdWindow(
                                          userId: userState.user.uId,
                                          rewardType: "itemPlayTime",
                                          amount: userState.exchangeAd['item_time'] as int,
                                        )));
                                if (result != null && result) {
                                  showAdResult(context, userState.exchangeAd['item_time'] as int, "addtime");
                                }
                                context.read<AuthenticationBloc>().add(TimeAdRewardEvent());
                              }
                            });
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 35,),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      File('${_imagePath}play2/waiting_pad.png'),
                      fit: BoxFit.contain,
                    ),
                    Visibility(
                      visible: false,
                      child: HookBuilder(
                        builder: (ctx) {
                          final state = useBloc<PlayBloc, PlayState>(
                              onEmitted: (_, prev, curr) =>
                                  prev.reserves != curr.reserves).state;
                          final turn = state.reserves.indexWhere(
                              (element) => element['uid'] == state.userData.uId);
                          return Txt(
                              state.connection == Connection.waiting && turn != -1
                                  ? '${state.userData.uName} 의 대기순번은 ${turn + 1}번 입니다.'
                                  : '게임 시작 전, 아이템을 준비하세요.\n게임이 시작되면 보충할 수 없습니다.',
                              style: TxtStyle()
                                ..textColor(Colors.white)
                                ..fontSize(12)
                                ..fontWeight(FontWeight.w600)
                                ..textAlign.center());
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right:10,
                  top: 70,
                  child: CustomButton(
                    defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_e.png',
                    pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_d.png',
                    onPressed: (){
                      _showGuideImageSlide(context: context,stageName: stageName);
                    },
                    width: 80,
                    text: Text(AppConfig.lang=='kor' ? '성공방법' : 'How To',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),

                  ),
                ),
                Positioned(
                    bottom: 5,
                    child: HookBuilder(
                      builder: (ctx) {

                        final userState =
                        useBloc<AuthenticationBloc, AuthenticationState>(
                        onEmitted: (_, prev, curr)=>prev.user != curr.user).state;

                        final playBloc = useBloc<PlayBloc, PlayState>(
                            onEmitted: (_, prev, curr) {
                          if (prev.connection != curr.connection &&
                              curr.connection == Connection.your_turn) {
                            showDialog(
                                    barrierColor: Colors.black.withOpacity(0.3),
                                    context: context,
                                    builder: (context) => StartDialogView())
                                .then((value) {
                              if (value != null && value as bool) {
                                context.read<PlayBloc>().add(StartGameEvent());
                              } else {
                                context.read<PlayBloc>().add(const EndGameEvent(false));
                              }
                            });
                          }
                          if (prev.orders != curr.orders &&
                              curr.orders == Orders.want_to_wait) {
                            showDialog(
                                    barrierColor: Colors.black.withOpacity(0.3),
                                    context: context,
                                    builder: (context) => ReserveDialogView())
                                .then((value) {
                              if (value != null && value as bool) {
                                context.read<PlayBloc>().add(ReserveGameEvent());
                              }
                            });
                          }
                          return prev.reserves != curr.reserves ||
                              prev.connection != curr.connection || prev.currentMachine != curr.currentMachine;
                        }).state;
                        final turn = playBloc.reserves.indexWhere(
                            (element) =>
                                element['uid'] == playBloc.userData.uId);
                        return GestureDetector(
                          onTap: () async {
                            if (playBloc.connection ==
                                    Connection.waiting &&
                                turn != -1) {
                              context.read<PlayBloc>().add(const EndGameEvent(false));
                            } else if (playBloc.connection ==
                                Connection.waiting) {
                              context.read<PlayBloc>().add(StartGameEvent());
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/${playBloc.currentMachine.mCoin}.png'),width: 14,),
                                          Text('${playBloc.currentMachine.mCoin == "play_coin" ? userState.user.uPlayCoin :
                                          playBloc.currentMachine.mCoin == "play_coin_purple" ? userState.user.itemPurpleCoin : userState.user.itemGoldCoin} ${AppConfig.lang=='kor' ? '포인트 보유중' : 'Play point'}',
                                            style: const TextStyle(color: Colors.white,fontSize: 12),)
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        children: [
                                          CustomButton(
                                            defaultImageFilePath:turn != -1 ? '${_imagePath}play2/btn_3_e.png' : '${_imagePath}play2/btn_1_e.png',
                                            pressedImageFilePath:turn != -1 ? '${_imagePath}play2/btn_3_d.png' : '${_imagePath}play2/btn_1_e.png',
                                            onPressed: () async{
                                              if (playBloc.connection ==
                                                  Connection.waiting &&
                                                  turn != -1) {
                                                context.read<PlayBloc>().add(const EndGameEvent(false));
                                              } else if (playBloc.connection ==
                                                  Connection.waiting) {
                                                context.read<PlayBloc>().add(StartGameEvent());
                                              }
                                            },
                                            text: Row(
                                              children: [
                                                Visibility(
                                                  visible: turn != -1,
                                                  // btnState==BtnState.READY,
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(right: 7),
                                                    child: SpinKitRing(
                                                      color: Colors.black,
                                                      size: 25,
                                                      lineWidth: 3,
                                                    ),
                                                  ),
                                                ),
                                                if (AppConfig.lang =='kor') Text(
                                                  turn != -1 ? '대기취소' : '게임시작',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 20
                                                  ),
                                                ) else Text(
                                                  turn != -1 ? 'Cancel' : 'Start',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 20
                                                  ),
                                                ),
                                                if (playBloc.connection ==
                                                    Connection.waiting &&
                                                    turn == -1)
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(left: 5),
                                                        child: Image.file(
                                                          File('${AppConfig.appDocDirectory!.path}/osgame/icons/${playBloc.currentMachine.mCoin}.png'),
                                                          width: 20,
                                                        ),
                                                      ),
                                                      Text(
                                                        playBloc.currentMachine.mPrice.toString(),
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black),
                                                      )
                                                    ],
                                                  )
                                                else
                                                  const Text('')
                                              ],
                                            ),
                                            width: 154,
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                  const SizedBox(height:5,),
                                  Row(
                                    children: [
                                      CustomButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        defaultImageFilePath: '${_imagePath}play2/btn_2_e.png',
                                        pressedImageFilePath: '${_imagePath}play2/btn_2_d.png',
                                        text: Text(AppConfig.lang=='kor' ? '방 나가기' : 'exit',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                                        width: 144,
                                      ),
                                      const SizedBox(width:10,),
                                      CustomButton(
                                        onPressed: (){
                                          _showRoomList(
                                            context,
                                            machineList: playBloc.machineList,
                                            selectedMachine: playBloc.currentMachine,
                                            select: (RoomsList machine){
                                              context.read<PlayBloc>().add(ConnectToServerEvent(machine,playBloc.userData));
                                            }
                                          );
                                        },
                                        defaultImageFilePath: '${_imagePath}play2/btn3_e.png',
                                        pressedImageFilePath: '${_imagePath}play2/btn3_d.png',
                                        text: Text(AppConfig.lang=='kor' ? '다른 방으로' : 'other room',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                                        width: 144,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )),
                ],
             )
          ],
        ),
      ),
    );
  }

  Future<void> _showRoomList(BuildContext context,
      {required List<RoomsList> machineList, required RoomsList selectedMachine,
    required Function select,}) async{

    // machineList.removeWhere((element) => element.mId == selectedMachine.mId);

    await showDialog(
      context: context,
      builder: (_){
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 306,
                  height: 306*(1129/1064),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(
                          File('${AppConfig.appDocDirectory!.path}/osgame/play2/list_popup.png'),
                        ),
                      )
                  ),
                  child:  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (AppConfig.lang=='kor') Text('현위치 : ${selectedMachine.mId}번 방',style: const TextStyle(color: appMainColor,fontSize: 16,fontWeight: FontWeight.bold),)
                          else Text('Room : No. ${selectedMachine.mId}',style: const TextStyle(color: appMainColor,fontSize: 16,fontWeight: FontWeight.bold),),
                          Row(
                            children: [
                              // CustomButton(
                              //   pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_d.png',
                              //   defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_e.png',
                              //   onPressed: (){
                              //
                              //   },
                              //   text: const Text('새로고침',style: TextStyle(color: Colors.black,fontSize:14,fontWeight: FontWeight.bold)),
                              //   width: 75,
                              // ),
                              const SizedBox(width: 12,),
                              CustomButton(
                                pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/play2/btn_exit_yellow_d.png',
                                defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/play2/btn_exit_yellow_e.png',
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                width: 30,
                              ),
                            ],
                          )
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: machineList.map((machine){
                              if(machine.mId == selectedMachine.mId){
                                return const SizedBox();
                              }else{
                                return Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/play2/room_list.png'),width: 300,),
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: 90,
                                              child: Center(child: Text('${machine.mId}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 17),))
                                          ),
                                          Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/play2/list_divider.png',),width: 2,),
                                          const SizedBox(width: 36,),
                                          Text(AppConfig.lang=='kor' ? '입장가능' : 'Open', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 17),),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                CustomButton(
                                                  pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_d.png',
                                                  defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_e.png',
                                                  onPressed: (){
                                                    Navigator.of(context).pop();
                                                    select(machine);
                                                  },
                                                  text: Text(AppConfig.lang=='kor' ? '입장' : 'Join', style: const TextStyle(color: Colors.black,fontSize:17,fontWeight: FontWeight.bold)),
                                                  width: 70,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }
                            }).toList()
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

  Future<void> showAdResult(
      BuildContext context, int count, String type) async {
    await showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: _ShowAdResult(count, type),
          );
        });
  }
}

class OneItemAdBox extends StatelessWidget {
  final int adCount;
  final int leftCount;
  final String imageUrl;
  final Function onPressed;

  OneItemAdBox(
      {required this.adCount,
      required this.leftCount,
      required this.imageUrl,
      required this.onPressed}
      );

  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File('${_imagePath}item_box.png'),
              width: 100,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10,right: 14),
              child: Image.file(
                File(imageUrl),
                width: 70,
              ),
            ),
            Positioned(
                bottom: 7,
                right: 2.2,
                child: Container(
                    width: 30,
                    color: Colors.transparent,
                    child: Center(
                        child: Text(
                      leftCount > 99 ? '99+' : leftCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5),
                    ))))
          ],
        ),
        if (adCount == 0)
          CustomButton(
            defaultImageFilePath: '$_imagePath${makeFilename('btn_ad_e.png')}',
            pressedImageFilePath: '$_imagePath${makeFilename('btn_ad_e_pressed.png')}',
            width: 100,
            height: 50,
            onPressed: () {
              if (adCount == 0) onPressed();
            },
          )
        else
          Image.file(
            File('$_imagePath${makeFilename('btn_ad_d.png')}'),
            width: 100,
            height: 50,
          ),
        if (adCount != 0)
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '다음 획득까지 $adCount분',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              )
            ],
          )
      ],
    );
  }
}

class _ShowAdResult extends StatelessWidget {
  final int count;
  final String type;

  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';

  _ShowAdResult(this.count, this.type);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.file(
            File('${_imagePath}alert_bg.png'),
            fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.file(
                  File(
                      '${AppConfig.appDocDirectory!.path}${'/osgame/icons/item_$type.png'}'),
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  type == "addtime"
                      ? '시간추가 $count개 획득'
                      : type == "laser"
                          ? '레이저 $count개 획득!'
                          : "",
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 4),
              width: 85,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.file(
                  File('${_imagePath}btn_touch.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ReserveDialogView extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';

  @override
  Widget build(BuildContext context) {
    // final ticker = useSingleTickerProvider();
    // final gifConLaser = useGifController(provider: ticker, duration: 2000);
    //
    // useEffect(() {
    //   gifConLaser.repeat(min: 0, max: 39);
    //   return null;
    // }, []);

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
                Image.file(File('${_imagePath}dialog_frame.png'),
                    width: 320, fit: BoxFit.contain),
                Positioned(
                  top: 30,
                  child: HookBuilder(builder: (context) {
                    final counter = useBloc<CounterCubit, int>().state;
                    useEffect(() {
                      context.read<CounterCubit>().startTimer(5);
                      return null;
                    }, []);

                    if (counter == 0) {
                      Navigator.pop(context, false);
                    }
                    return Row(
                      children: [
                        CustomButton(
                          defaultImageFilePath:
                              '${_imagePath}btn_1_e.png',
                          pressedImageFilePath:
                              '${_imagePath}btn_1_d.png',
                          width: 115,
                          text: IgnorePointer(
                              child: Text(
                                '$counter 대기하기',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                              ),
                          )),
                          onPressed: () {
                            if (counter > 0) {
                              context.read<CounterCubit>().cancelTimer();
                              Navigator.pop(context, true);
                            }
                          },
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButton(
                              defaultImageFilePath:
                                  '${_imagePath}btn_2_e.png',
                              pressedImageFilePath:
                                  '${_imagePath}btn_2_d.png',
                              width: 115,
                              onPressed: () {
                                if (counter > 0) {
                                  context.read<CounterCubit>().cancelTimer();
                                  Navigator.pop(context, false);
                                }
                              },
                            ),
                            const IgnorePointer(
                              child: Text(
                                '나가기',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                Positioned(
                  bottom: 35,
                  child: Txt("먼저 플레이중인 유저가 있습니다.\n기다리시겠습니까?",
                      style: TxtStyle()
                        ..textColor(Colors.white)
                        ..fontSize(14)
                        ..fontWeight(FontWeight.w600)
                        ..textAlign.center()),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 25),
                  // child: GifImage(
                  //   width: 170,
                  //   controller: gifConLaser,
                  //   image: FileImage(File('${_imagePath}sd1.gif')),
                  // ),
                  child:  Image.file(File('${_imagePath}sd1.png'),width: 170,)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartDialogView extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';

  @override
  Widget build(BuildContext context) {
    // final ticker = useSingleTickerProvider();
    // final gifConLaser = useGifController(provider: ticker, duration: 2000);
    //
    // useEffect(() {
    //   gifConLaser.animateTo(39);
    //   // gifConLaser.repeat(min: 0, max: 39);
    //   return null;
    // }, []);

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
                Image.file(File('${_imagePath}dialog_frame.png'),
                    width: 320, fit: BoxFit.contain),
                Positioned(
                  top: 30,
                  child: HookBuilder(builder: (context) {
                    final counter = useBloc<CounterCubit, int>().state;
                    useEffect(() {
                      context.read<CounterCubit>().startTimer(5);
                      return null;
                    }, []);
                    if (counter == 0) {
                      Navigator.pop(context, false);
                    }
                    return Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButton(
                              defaultImageFilePath:
                                  '${_imagePath}btn_1_e.png',
                              pressedImageFilePath:
                                  '${_imagePath}btn_1_d.png',
                              width: 115,
                              onPressed: () {
                                if (counter > 0) {
                                  context.read<CounterCubit>().cancelTimer();
                                  Navigator.pop(context, true);
                                }
                              },
                            ),
                            IgnorePointer(
                                child: Text(
                              '$counter 시작하기',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ))
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButton(
                              defaultImageFilePath:
                                  '${_imagePath}btn_2_e.png',
                              pressedImageFilePath:
                                  '${_imagePath}btn_2_d.png',
                              width: 115,
                              onPressed: () {
                                if (counter > 0) {
                                  context.read<CounterCubit>().cancelTimer();
                                  Navigator.pop(context, false);
                                }
                              },
                            ),
                            const IgnorePointer(
                              child: Text(
                                '취소하기',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                // Container(
                //     padding: const EdgeInsets.only(left: 25),
                //     child: Image.file(File('${_imagePath}dialog_cr.png'),width: 140,)
                // ),
                Positioned(
                  bottom: 35,
                  child: Txt("닉네임의 순서가 되었어요",
                      style: TxtStyle()
                        ..textColor(Colors.white)
                        ..fontSize(14)
                        ..fontWeight(FontWeight.w600)
                        ..textAlign.center()),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  // child: GifImage(
                  //   width: 180,
                  //   controller: gifConLaser,
                  //   image: FileImage(File('${_imagePath}sd2.gif')),
                  // ),
                  child:  Image.file(File('${_imagePath}sd2.png'),width: 180,)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowConfirmRewardView extends StatelessWidget {
  final String type;
  final int count;

  const ShowConfirmRewardView(this.type, this.count);


  @override
  Widget build(BuildContext context) {
    return Align(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            File(
                '${AppConfig.appDocDirectory!.path}/osgame/play2/ad_frame.png'),
            width: 300,
          ),
          Positioned(
            right: 15,
            top: 14,
            child: CustomButton(
              width: 22,
              onPressed: () {
                Navigator.pop(context, false);
              },
              pressedImageFilePath:
              '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_d.png',
              defaultImageFilePath:
              '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_e.png',
            ),
          ),
          Positioned(
              top: 70,
              child: Text(
                '보상형 광고를 시청하고\n${type == "addtime" ? "시간추가 아이템" : "플레이 포인트"} $count개를\n획득하시겠습니까?',
                style: const TextStyle(
                    height: 1.8,
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
          ),
          Positioned(
            top: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.file(
                  File(
                      '${AppConfig.appDocDirectory!.path}/osgame/screen/inventory/item_inven_box.png'),
                  width: 100,
                ),
                Image.file(
                  File(
                      type=='addtime' ? '${AppConfig.appDocDirectory!.path}/osgame/icons/item_addtime.png' : '${AppConfig.appDocDirectory!.path}/osgame/icons/play_coin.png'),
                  width: 76,
                ),
                Positioned(
                    right: 8,
                    bottom: 6,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )
                )
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            child: CustomButton(
              text: const Text(
                '광고보기',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              width: 150,
              onPressed: () async {
                Navigator.pop(context,true);

              },
              pressedImageFilePath:
              '${AppConfig.appDocDirectory!.path}/osgame/play2/btn_1_d.png',
              defaultImageFilePath:
              '${AppConfig.appDocDirectory!.path}/osgame/play2/btn_1_e.png',
            ),
          ),
        ],
      ),
    );
  }
}


// ignore: avoid_void_async
void _showGuideImageSlide({required BuildContext context,required String stageName}) async {
  final _path = '${AppConfig.appDocDirectory!.path}/osgame/video/';
  await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(60),
        backgroundColor: Colors.transparent,
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 0.474,
              viewportFraction: 1.0,
              enableInfiniteScroll: false
          ),
          items: [
            if (AppConfig.lang=='kor') Image.file(File('${_path+stageName}.png')) else Image.file(File('${_path+stageName}_en.png')),
          ],
        ),
      ));
}