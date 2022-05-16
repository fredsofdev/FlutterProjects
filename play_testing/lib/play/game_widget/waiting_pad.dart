
import 'package:carousel_slider/carousel_slider.dart';
import 'package:division/division.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:play_testing/color.dart';
import 'package:play_testing/custom_buttons.dart';
import 'package:play_testing/hooks/gif_hook.dart';
import 'package:play_testing/play/bloc/counter/counter_cubit.dart';
import 'package:play_testing/play/bloc/play_bloc.dart';
import 'package:play_testing/rooms_list.dart';

class WaitPad extends HookWidget {
  final String stageName;
  WaitPad({
    this.stageName
  });

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => CounterCubit(),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 35,),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/play/waiting_pad.png',
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
                  top: 90,
                  child: CustomButton(
                    defaultImageFilePath: 'assets/play/btn_e.png',
                    pressedImageFilePath: 'assets/play/btn_d.png',
                    onPressed: (){
                      _showGuideImageSlide(context: context,stageName: stageName);
                    },
                    width: 100,

                  ),
                ),
                Positioned(
                    bottom: 5,
                    child: HookBuilder(
                      builder: (ctx) {

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
                                          Image.asset('assets/icons/${playBloc.currentMachine.mCoin}.png',width: 14,),
                                          Text('1000 포인트 보유중', style: const TextStyle(color: Colors.white,fontSize: 12),)
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                            defaultImageFilePath:turn != -1 ? 'assets/play/btn_3_e.png' : 'assets/play/btn_1_e.png',
                                            pressedImageFilePath:turn != -1 ? 'assets/play/btn_3_d.png' : 'assets/play/btn_1_e.png',
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
                                                Text(
                                                  turn != -1 ? '대기취소' : '게임시작',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 20),
                                                ),
                                                if (playBloc.connection ==
                                                    Connection.waiting &&
                                                    turn == -1)
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(left: 5),
                                                        child: Image.asset(
                                                          'assets/icons/${playBloc.currentMachine.mCoin}.png',
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
                                        defaultImageFilePath: 'assets/play/btn_2_e.png',
                                        pressedImageFilePath: 'assets/play/btn_2_d.png',
                                        text: const Text('방 나가기',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
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
                                        defaultImageFilePath: 'assets/play/btn3_e.png',
                                        pressedImageFilePath: 'assets/play/btn3_d.png',
                                        text: const Text('다른 방으로',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
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
      {List<RoomsList> machineList, RoomsList selectedMachine,
    Function select,}) async{

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
                        image: AssetImage(
                          'assets/play/list_popup.png',
                        ),
                      )
                  ),
                  child:  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('현위치 : ${selectedMachine.mId}번 방',style: const TextStyle(color: appMainColor,fontSize: 16,fontWeight: FontWeight.bold),),
                          Row(
                            children: [
                              // CustomButton(
                              //   pressedImageFilePath: '${AppConfig.appDocDirectory.path}/osgame/screen/main/etc/btn1_d.png',
                              //   defaultImageFilePath: '${AppConfig.appDocDirectory.path}/osgame/screen/main/etc/btn1_e.png',
                              //   onPressed: (){
                              //
                              //   },
                              //   text: const Text('새로고침',style: TextStyle(color: Colors.black,fontSize:14,fontWeight: FontWeight.bold)),
                              //   width: 75,
                              // ),
                              const SizedBox(width: 12,),
                              CustomButton(
                                pressedImageFilePath: 'assets/play/btn_exit_yellow_d.png',
                                defaultImageFilePath: 'assets/play/btn_exit_yellow_e.png',
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
                                      Image.asset('assets/play/room_list.png',width: 300,),
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: 90,
                                              child: Center(child: Text('${machine.mId}번',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 17),))
                                          ),
                                          Image.asset('assets/play/list_divider.png',width: 2,),
                                          const SizedBox(width: 36,),
                                          const Text('입장가능',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 17),),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                CustomButton(
                                                  pressedImageFilePath: 'assets/screen/btn1_d.png',
                                                  defaultImageFilePath: 'assets/screen/btn1_e.png',
                                                  onPressed: (){
                                                    Navigator.of(context).pop();
                                                    select(machine);
                                                  },
                                                  text: const Text('입장',style: TextStyle(color: Colors.black,fontSize:17,fontWeight: FontWeight.bold)),
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
      {@required this.adCount,
      @required this.leftCount,
      @required this.imageUrl,
      this.onPressed});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/play/item_box.png',
              width: 100,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10,right: 14),
              child: Image.asset(
                imageUrl,
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
            defaultImageFilePath: 'assets/play/btn_ad_e.png',
            pressedImageFilePath: 'assets/play/btn_ad_e_pressed.png',
            width: 100,
            height: 50,
            onPressed: () {
              if (adCount == 0) onPressed();
            },
          )
        else
          Image.asset(
            'assets/play/btn_ad_d.png',
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

class _ShowAdResult extends HookWidget {
  final int count;
  final String type;

  _ShowAdResult(this.count, this.type);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            'assets/play/alert_bg.png',
            fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  
                      'assets/play//osgame/icons/item_$type.png',
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
                child: Image.asset(
                  'assets/play/btn_touch.png',
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
                Image.asset('assets/play/dialog_frame.png',
                    width: 320, fit: BoxFit.contain),
                Positioned(
                  top: 30,
                  child: HookBuilder(builder: (context) {
                    final counter = useBloc<CounterCubit, int>();
                    useEffect(() {
                      counter.startTimer(5);
                      return null;
                    }, []);

                    if (counter.state == 0) {
                      Navigator.pop(context, false);
                    }
                    return Row(
                      children: [
                        CustomButton(
                          defaultImageFilePath:
                              'assets/play/btn_1_e.png',
                          pressedImageFilePath:
                              'assets/play/btn_1_d.png',
                          width: 115,
                          text: IgnorePointer(
                              child: Text(
                                '${counter.state} 대기하기',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                              ),
                          )),
                          onPressed: () {
                            if (counter.state > 0) {
                              counter.cancelTimer();
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
                                  'assets/play/btn_2_e.png',
                              pressedImageFilePath:
                                  'assets/play/btn_2_d.png',
                              width: 115,
                              onPressed: () {
                                if (counter.state > 0) {
                                  counter.cancelTimer();
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
                                    fontSize: 15),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartDialogView extends HookWidget {

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
                Image.asset('assets/play/dialog_frame.png',
                    width: 320, fit: BoxFit.contain),
                Positioned(
                  top: 30,
                  child: HookBuilder(builder: (context) {
                    final counter = useBloc<CounterCubit, int>();
                    useEffect(() {
                      counter.startTimer(5);
                      return null;
                    }, []);
                    if (counter.state == 0) {
                      Navigator.pop(context, false);
                    }
                    return Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButton(
                              defaultImageFilePath:
                                  'assets/play/btn_1_e.png',
                              pressedImageFilePath:
                                  'assets/play/btn_1_d.png',
                              width: 115,
                              onPressed: () {
                                if (counter.state > 0) {
                                  counter.cancelTimer();
                                  Navigator.pop(context, true);
                                }
                              },
                            ),
                            IgnorePointer(
                                child: Text(
                              '${counter.state} 시작하기',
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
                                  'assets/play/btn_2_e.png',
                              pressedImageFilePath:
                                  'assets/play/btn_2_d.png',
                              width: 115,
                              onPressed: () {
                                if (counter.state > 0) {
                                  counter.cancelTimer();
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
                //     child: Image.asset('${_imagePath}dialog_cr.png'),width: 140,)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowConfirmRewardView extends HookWidget {
  final String type;
  final int count;

  const ShowConfirmRewardView(this.type, this.count);


  @override
  Widget build(BuildContext context) {
    return Align(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            
                'assets/play/ad_frame.png',
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
              'assets/screen/btn_exit_d.png',
              defaultImageFilePath:
              'assets/screen/btn_exit_e.png',
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
                Image.asset(
                  
                      'assets/screen/item_inven_box.png',
                  width: 100,
                ),
                Image.asset(
                  
                      type=='addtime' ? 'assets/icons/item_addtime.png' : 'assets/icons/play_coin.png',
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
              'assets/play/btn_1_d.png',
              defaultImageFilePath:
              'assets/play/btn_1_e.png',
            ),
          ),
        ],
      ),
    );
  }
}



// ignore: avoid_void_async
void _showGuideImageSlide({BuildContext context,String stageName}) async {
  final _path = 'assets/video/';
  await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(60),
        backgroundColor: Colors.red,
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 0.474,
              viewportFraction: 1.0,
              enableInfiniteScroll: false
          ),
          items: [
            Image.asset('${_path+stageName}.png'),
          ],
        ),
      ));
}