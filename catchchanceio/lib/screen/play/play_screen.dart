import 'dart:async';
import 'dart:io';
import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/hooks/life_cycle_hook.dart';
import 'package:catchchanceio/hooks/video_hook.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/repository/authentication/models/user_data.dart';
import 'package:catchchanceio/repository/play/connection_repository.dart';
import 'package:catchchanceio/repository/play/model/rooms_list.dart';
import 'package:catchchanceio/repository/play/play_repository.dart';
import 'package:catchchanceio/screen/shop/shop_screen.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:catchchanceio/widgets/dialog/os_dialog.dart';
import 'package:catchchanceio/windows/reward_ad_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../bloc/authentication_bloc/authentication_bloc.dart';
import 'bloc/counter/counter_cubit.dart';
import 'bloc/play_bloc.dart';
import 'game_widget/game_pad.dart';
import 'game_widget/streaming.dart';
import 'game_widget/waiting_pad.dart';

class PlayScreen extends StatelessWidget {
  final UserData user;
  final String stage;

  const PlayScreen({required this.user, required this.stage});



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
          create: (_) => PlayBloc(PlayRepository(), ConnectionRepository(),stage,user),
          // child: _PlayView(machine,user),
          child: _Play(stage),
        ),
      ),
    );
  }
}



// ignore: must_be_immutable
class _Play extends HookWidget {
  // final _admobController = NativeAdmobController();
  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();
  final BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
  final String stage;
  final BannerAd myBanner = BannerAd(
    adUnitId: Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716',
    size: AdSize(width: 320, height: 300),
    request: AdRequest(),
    listener: BannerAdListener(
        onAdLoaded: (Ad ad){
          print('Ad loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error){
          ad.dispose();
          print('Ad failed to load: $error');
        }
    ),
  );


  _Play(this.stage);
  // {myBanner.load();}

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    useLifeCycleUpdate(context, lifeCycleUpdate: (state) {
      if (state == AppLifecycleState.resumed) {
        context.read<PlayBloc>().add(const IsBackgroundEvent(isBackground: false));
      } else {
        context.read<PlayBloc>().add(const IsBackgroundEvent(isBackground: true));
      }
    });

    final videoController =
    useVideoController(videoUrl: '/osgame/loading/cam_loader.mp4');
    final videoFuture = useMemoized(() => videoController.initialize());

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final isLoading = useState(true);

    useEffect((){
      myBanner.load();
      return null;
    },[]);

    final isPlayLoading = useState(false);
    final playBloc = useBloc<PlayBloc, PlayState>(onEmitted: (_, p, c) {
      if (p.popUps != c.popUps && c.popUps != PopUps.initial) {
        _showResultOfGame(context,
            stageName: c.currentMachine.mStage!,
            prizeCount: c.currentMachine.mPrize!,
            isSuccess: c.popUps == PopUps.success, resultCall: (bool result) {
              result != null && result
                  ? context.read<PlayBloc>().add(const EndGameEvent(true))
                  : context.read<PlayBloc>().add(const EndGameEvent(false));
            });
      }
      if (p.orders != c.orders && c.orders == Orders.notEnoughCoin) {
        //todo show coin earn ads dialog
        _showChargePointDialog(context, playCoin: c.currentMachine.mCoin!, resultShow: (bool result) async {
          if (result && result != null) {
            String type = "u_playCoin";
            if(c.currentMachine.mCoin == "play_coin_purple"){
              type = "itemPurpleCoin";
            }else if(c.currentMachine.mCoin == "play_coin_gold"){
              type = "itemGoldCoin";
            }
            final result = await Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: RewardAdWindow(
                      userId: c.userData.uId,
                      rewardType: type,
                      amount: c.currentMachine.mPrice!,
                    )
                )
            );

            Fluttertoast.showToast(
                msg: result == true
                    ? AppConfig.lang=='kor' ? "${c.currentMachine.mPrice} 플레이 코인 획득!" : 'Get ${c.currentMachine.mPrice} play coin'
                    : AppConfig.lang=='kor' ? "플레이 코인 획득 실패." : 'failed to get play coin',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.black.withOpacity(0.7),
                textColor: Colors.white,
                fontSize: 15.0);
          }
        });
      }
      if (p.connection != c.connection && c.connection != Connection.disconnected) {
        //Todo Show update dialogk
      }
      if (p.connection != c.connection && c.connection != Connection.waiting) {
        isPlayLoading.value = false;
      }
      return p.connection != c.connection;
    }).state;

    return WillPopScope(
      onWillPop: () async {
        var result = false;
        if (playBloc.connection == Connection.playing) {
          showCustomDialog(
              context: context,
              contentText: AppConfig.lang=='kor' ? "정말로 게임을 나가시겠습니까?" : 'Are you sure you want to leave the game?',
              confirmText: AppConfig.lang=='kor' ?"나가기" : 'Exit',
              rejectText:  AppConfig.lang=='kor' ? "취소" : ' No',
              onConfirm: () {
                result = true;
                Navigator.pop(context);
              });
        }
        else {
          myBanner.dispose();
          result = true;
        }
        return result;
      },
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: (((sh * 0.92)/2)-(sw * 0.8))+(((1.7 - ((sh * 0.92)/sw))+1)*(sh*0.09)),
                ),

                //todo 애드몹 광고 Container
                Container(
                  color: Colors.white,
                  height: sw * 0.8,
                  padding: const EdgeInsets.all(10),
                  child:  AdWidget(
                        ad: myBanner,
                      ),

                  constraints: BoxConstraints(
                    maxHeight: 400,
                    maxWidth: sw,

                  ),
                ),

              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: sh * 0.05,
                color:appMainColor
              ),
              Stack(
                children: [
                  IgnorePointer(
                    child: Container(
                      width: sw,
                      height: sh * 0.89,
                      color: Colors.transparent,
                      child: HookBuilder(
                          builder: (context) {
                            final bloc = useBloc<PlayBloc, PlayState>(
                                onEmitted: (_, p, c) =>p.connectionSession != c.connectionSession).state;
                            return bloc.currentMachine != RoomsList.empty ? Streaming(key: ValueKey(bloc.connectionSession),
                              selectedStreamId:  bloc.currentMachine.mId!,
                              isLoading: (bool loading){
                                if(bloc.connection != Connection.playing){
                                  if (loading) {
                                    isLoading.value = true;
                                    videoController.play();
                                  } else {
                                    isLoading.value = false;
                                    videoController.pause();
                                  }
                                }
                                else{
                                  isPlayLoading.value = loading;
                                }
                              },):const SizedBox();
                          }
                      ),
                    ),
                  ),
                  Visibility(
                      visible: isPlayLoading.value,
                      child: Container(
                        color: Colors.black38,
                        child: const Center(
                          child: Text(
                            "재연결중...",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      )
                  ),

                  HookBuilder(builder: (context) {
                    final indexTurn = useState(AppConfig.setting.backgroundSound ? 1 : 0);
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
                                      uId: state.currentPlayer['id'].toString()
                                  )
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
                                          contentText: AppConfig.lang=='kor' ? "정말로 게임을 나가시겠습니까?" : 'Are you sure you want to leave the game?',
                                          confirmText: AppConfig.lang=='kor' ?"나가기" : 'Exit',
                                          rejectText: AppConfig.lang=='kor' ? "취소" : ' No',
                                          onConfirm: () {
                                            effectMusicPlayer.playOnce('click_main_ui');
                                            Navigator.pop(context);
                                          });
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  })
                            ],
                          ),
                          const SizedBox(height: 3,),
                          Row(
                            children: [
                              IndexedStack(
                                index: indexTurn.value,
                                children: [
                                  //todo mute btn
                                  CustomButton(
                                    pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/icons/off_btn_d.png',
                                    defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/icons/off_btn_e.png',
                                    onPressed: () async{
                                      final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                      prefs.setBool('setting_backgroundSound',
                                          prefs.getBool('setting_backgroundSound')!);
                                      AppConfig.setting.backgroundSound =
                                          prefs.getBool('setting_backgroundSound')!;
                                      if (AppConfig.setting.backgroundSound) {
                                        backgroundMusicPlayer.unMute();
                                        indexTurn.value = 1;
                                      } else {
                                        backgroundMusicPlayer.mute();
                                      }
                                    },
                                    width: 60,
                                  ),
                                  //todo unmute btn
                                  CustomButton(
                                    pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/icons/on_btn_d.png',
                                    defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/icons/on_btn_e.png',
                                    onPressed: () async{
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
                                        indexTurn.value = 0;
                                      }
                                    },
                                    width: 60,
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),



          IndexedStack(
            index: playBloc.connection == Connection.playing ? 1 : 0,
            children: [
              WaitPad(stageName: stage),
              PlayPad(),
            ],
          ),

          Visibility(
            visible: isLoading.value,
            // visible: false,
            child: FutureBuilder(
                future: videoFuture,
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.done
                      ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(videoController),
                      // Positioned(
                      //   top: 30,
                      //   left: 20,
                      //   child: BackButtonPolygonBox(),
                      // ),
                      Positioned(
                        bottom: 20,
                        child: Text(
                          AppConfig.lang=='kor' ? '네트워크 환경에 따라 로딩 시간이 지연될 수 있습니다.' : 'Loading time may be delayed depending on the network.',
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                    ],
                  )
                      : Container(
                    width: sw,
                    height: sh,
                    color: Colors.white,
                  );
                }),
          ),
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

  Widget _buildUserCircleImage({required String url, required String uId}) {
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
        required bool isSuccess,
        required int prizeCount,
        required String stageName,
        required Function resultCall,
      }) async {
    final result = await showDialog(
        barrierColor: Colors.black.withOpacity(0.3),
        context: context,
        builder: (context) => EndDialogView(stageName, prizeCount, isSuccess)
    );
    resultCall.call(result?? false);
  }

  Future<void> _showChargePointDialog(BuildContext context,
      {required Function resultShow, required String playCoin}) async {
    final result = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => BlocProvider(
            create:(_) => CounterCubit(),
            child: ChargePointView(playCoin: playCoin,)));
    resultShow.call(result);
  }
}

class ChargePointView extends HookWidget {
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';
  final String playCoin;

  ChargePointView({
    required this.playCoin
  });


  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [


              Container(
                width: 325,
                height: 200,
                decoration: BoxDecoration(
                    border: Border.all(color: appMainColor,width: 3),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.9)
                ),
              ),


              // const Positioned(
              //   top: 10,
              //   right: 115,
              //   child: Text(
              //     "5",
              //     style: TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //         fontSize: 28),
              //   )
              // ),
              //
              // Positioned(
              //     top: 16,
              //     right: 178,
              //     child: Text(
              //       AppConfig.lang=='kor' ? '남은 시간' : 'left time',
              //       style : const TextStyle(
              //           color: Colors.black,
              //           fontWeight: FontWeight.w800,
              //           fontSize: 14
              //       ),
              //     )
              // ),
              Positioned(
                  top: 60,
                  child: Text(
                    playCoin == 'play_coin' ?
                    AppConfig.lang=='kor'? '플레이 포인트가 전부 소진되었습니다.\n무료 포인트를 충전 하시겠습니까?' : 'All play points are exhausted.\nDo you want to recharge your free points?'
                        :
                    AppConfig.lang=='kor'? '플레이 포인트를 구매하러\n상점으로 이동 하시겠습니까?' : 'Do you want to go to the store\nto buy play points?',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 15
                    ),
                    textAlign: TextAlign.center,
                  )
              ),
              Positioned(
                bottom: 15,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HookBuilder(
                        builder: (context) {
                          final userState =
                              useBloc<AuthenticationBloc, AuthenticationState>(
                                  onEmitted: (_, prev, curr) {
                                    return prev.chargeRewardAdCount != curr.chargeRewardAdCount||prev.user!=curr.user;
                                  }).state;
                          return playCoin == 'play_coin'? Column(
                            children: [
                              if (userState.chargeRewardAdCount == 0) CustomButton(
                                onPressed: () {
                                  context.read<AuthenticationBloc>().add(ChargeAdRewardEvent());
                                  Navigator.pop(context, true);
                                },
                                defaultImageFilePath:
                                '${_imagePath}btn_yellow_e.png',
                                pressedImageFilePath:
                                '${_imagePath}btn_yellow_d.png',
                                height: 45,
                                width: 100,
                                text: Text(
                                  AppConfig.lang=='kor' ? '광고 시청' : 'view ad',
                                  style:const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ) else Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.file(
                                    File('${_imagePath}btn_grey.png'),
                                    height: 45,
                                    width: 100,
                                  ),
                                  Text(
                                    AppConfig.lang=='kor' ? '광고 시청' : 'view ad',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Visibility(
                                visible: userState.chargeRewardAdCount != 0,
                                child: Text(
                                  AppConfig.lang=='kor' ? '다음 획득까지 ${userState.chargeRewardAdCount}분' : 'Wait ${userState.chargeRewardAdCount}min',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15
                                  ),
                                ),
                              )
                            ],
                          ) : Column(
                            children: [
                              CustomButton(
                                onPressed: () async{
                                  Navigator.pop(context, false);
                                  await Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.fade,
                                          child: ShopScreen(userState.user.uId)
                                      )
                                  );
                                },
                                defaultImageFilePath:
                                '${_imagePath}btn_yellow_e.png',
                                pressedImageFilePath:
                                '${_imagePath}btn_yellow_d.png',
                                height: 45,
                                width: 120,
                                text: Text(
                                  AppConfig.lang=='kor' ?  '상점으로 이동' : 'Go to Shop',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    CustomButton(
                      onPressed: () {
                        // ignore: avoid_print
                        Navigator.pop(context, false);
                      },
                      defaultImageFilePath:
                      '${_imagePath}btn_red_e.png',
                      pressedImageFilePath:
                      '${_imagePath}btn_red_d.png',
                      height: 45,
                      width: 100,
                      text: Text(
                        AppConfig.lang=='kor' ? '닫기' : 'exit',
                        style : const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class EndDialogView extends HookWidget {
  final String stageName;
  final int prizeCount;
  final bool isSuccess;
  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/play2/';
  final String _iconPath = '${AppConfig.appDocDirectory!.path}/osgame/icons/';

  EndDialogView(this.stageName, this.prizeCount, this.isSuccess);

  @override
  Widget build(BuildContext context) {
    final gifController = useAnimationController(duration:Duration(seconds: 1000));

    useEffect(() {
      gifController.animateTo(29);
      return null;
    }, []);

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
                Image.file(
                    File(
                        '$_imagePath${'${isSuccess ? 'success' : 'fail'}_frame.png'}'),
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
                          defaultImageFilePath: '${_imagePath}btn_1_e.png',
                          pressedImageFilePath: '${_imagePath}btn_1_d.png',
                          width: 115,
                          text: IgnorePointer(
                              child: Text(
                                AppConfig.lang=='kor'? '${counter.state} 다시하기' : '${counter.state} Continue',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              )
                          ),
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
                          defaultImageFilePath: '${_imagePath}btn_2_e.png',
                          pressedImageFilePath: '${_imagePath}btn_2_d.png',
                          width: 115,
                          text: IgnorePointer(
                            child: Text(
                              AppConfig.lang=='kor' ? '그만하기' : 'Stop',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                              ),
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
                    child: Image.file(
                      File(
                          '$_imagePath${'msg_${isSuccess ? 'success' : 'fail'}.png'}'),
                      width : 180,
                    )
                ),
                Visibility(
                  visible: isSuccess,
                  child: Positioned(
                      top: 140,
                      left: 60,
                      child: Image.file(
                        File(
                            '$_iconPath${'prize_${AppConfig.stageMapping[stageName]}.png'}'),
                        width: 75,
                      )),
                ),
                Visibility(
                  visible: isSuccess,
                  child: Positioned (
                      top: 200,
                      left: 135,
                      child: Text(
                        'X $prizeCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 23,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'fpt'
                        ),
                      )),
                ),
                Positioned(
                    top: isSuccess ? 80 : 55,
                    right: isSuccess ? -15 : null,
                    // child: GifImage(
                    //   width: 168,
                    //   controller: gifConLaser,
                    //   image: FileImage(File(
                    //       '$_imagePath${isSuccess ? 'sd_success.gif' : 'sd_fail.gif'}')
                    //   ),
                    // ),
                    child: Image.file(File('$_imagePath${isSuccess ? 'sd_success.png' : 'sd_fail.png'}'), width: 180,)
                ),
                Positioned(
                    left: isSuccess ? 40 : null,
                    top: isSuccess ? 250 : 250,
                    child: Text(
                      AppConfig.lang == 'kor' ? '게임을 이어 하거나\n대기방으로 나갈수 있어요.' : 'You can continue the game and get out.',
                      style : const TextStyle(
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

