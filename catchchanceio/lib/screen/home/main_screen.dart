import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/hooks/life_cycle_hook.dart';
import 'package:catchchanceio/hooks/video_hook.dart';
import 'package:catchchanceio/methods/my_method.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/screen/exchange/exchange_screen.dart';
import 'package:catchchanceio/screen/friends/friends_screen.dart';
import 'package:catchchanceio/screen/inventory/inventory_screen.dart';
import 'package:catchchanceio/screen/shop/shop_screen.dart';
import 'package:catchchanceio/screen/stage/stage_list_screen.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:catchchanceio/widgets/etc/route_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:video_player/video_player.dart';

class MainScreen extends HookWidget {

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => MainScreen());
  }

  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main';
  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();
  final BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();


  final ScrollController _popularItemListScrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final videoController =
    useVideoController(videoUrl: '/osgame/screen/main/bg/bg.mp4');
    final bloc = useBloc<AuthenticationBloc, AuthenticationState>(
        onEmitted: (_, p, c) => p.user.uId != c.user.uId);
    useEffect((){
      backgroundMusicPlayer.playLoop('a_main');
      // AppFCM.setFCM(uniqueId: bloc.state.user.uId);
      return ;
    },[]);
    final videoFuture = useMemoized(() => videoController.initialize());

    final animation = useAnimationController(duration: const Duration(milliseconds: 250),initialValue: -154, lowerBound: -154,upperBound: 96);

    return WillPopScope(
      onWillPop: () async {
        context.read<AuthenticationBloc>().setUserOffline();
        return Future.value(true);
      },
      child: Scaffold(
        body: Container(
          width: sw,
          height: sh,
          decoration: BoxDecoration(
              color: const Color(0xff0f71a7),
              image: DecorationImage(
                  image: FileImage(File('$_imagePath/bg/bg_snapshot.png')),
                  fit: BoxFit.cover)),
          child: Stack(
            children: [
              //todo background video
              FutureBuilder(
                future: videoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: sw,
                          height: sh,
                          child: VideoPlayer(videoController),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      width: sw,
                      height: sh,
                      color: const Color(0xff0f71a7).withOpacity(0.0),
                    );
                  }
                },
              ),
              //todo msh bubble
              Positioned(
                  top:100,
                  left: (sw*0.5)-(130),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 5,left: 8,right: 30,bottom: 45),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File('$_imagePath/ui/msg_bubble.png')),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(AppConfig.lang=='kor'?'캐치찬스 2차 베타 테스트' : 'CatchChance Beta Test',style:const TextStyle(color:Colors.amberAccent,fontSize: 13,fontWeight: FontWeight.bold),),
                             const SizedBox(height: 4,),
                             Text(AppConfig.lang=='kor'?'현재 베타 테스트 진행중입니다.' : 'Now Beta test',style: const TextStyle(color:Colors.white,fontSize: 12,fontWeight: FontWeight.bold),),
                             Text(AppConfig.lang=='kor'?'베타 테스트 종료후 얻은 보상/포인트는\n모두 초기화 됩니다.':'All reward will be reset after the test',style:const TextStyle(color:Colors.tealAccent,fontSize: 12,fontWeight: FontWeight.bold),),
                             Text(AppConfig.lang=='kor'?'(테스트기간 내 쿠폰 사용 가능)':'',style:const TextStyle(color:Colors.white,fontSize: 12,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      )
                    ],
                  )
              ),

              //todo character
              Positioned(
                  bottom: (-1)*sh*0.15,
                  left: (-1) * sh * 0.1,
                  child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 1200),
                      opacity: 1.0,
                      child:
                      RoutWidget(
                        child: Image.file(
                          File('$_imagePath/bg/cr.gif'),
                          fit: BoxFit.contain,
                          height: sh * 0.95,
                        ),
                      )
                  )
              ),

              //todo 가챠 버튼
              // Positioned(
              //     bottom: sw * 0.56,
              //     right: 5,
              //     child: Visibility(
              //       visible: false,
              //       child: GoGachaButton(
              //         onPressed: () async {
              //           await Navigator.push(
              //               context,
              //               PageTransition(
              //                   type: PageTransitionType.fade,
              //                   child: GachaScreen(state.user.uId)));
              //           backgroundMusicPlayer.playLoop('a_main');
              //         },
              //       ),
              //     )),
              // //todo nav_bar
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: MainNavBar(videoController),
              // ),

              Align(
                alignment: Alignment.bottomCenter,
                child: MainNavBar(videoController)
              ),

              //todo popular items list 인기 상품 리스트.
              Visibility(
                // ignore: avoid_bool_literals_in_conditional_expressions
                visible: AppConfig.lang=='kor' ? true : false,
                child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, snapshot) {
                      return Positioned(
                        left: animation.value,
                        bottom: sw*0.36,
                        child: HookBuilder(
                            builder: (context) {
                              final topUsers = useBloc<AuthenticationBloc,AuthenticationState>(onEmitted: (_,p,c) => p.topUsers!=c.topUsers||p.user!=c.user);
                              return Stack(
                                children: [
                                  Image.file(File('$_imagePath/etc/pup_frame.png'),width: 250,height: 70,fit: BoxFit.fill,),
                                  Container(
                                    padding: const EdgeInsets.only(right:21,left: 25),
                                    width: 250,
                                    height: 70,
                                    child: SingleChildScrollView(
                                      controller: _popularItemListScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: topUsers.state.popularCoupons.map((coupon){
                                          return GestureDetector(
                                            onTap: ()async{
                                              await Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType.fade,
                                                      child: ExchangeScreen(topUsers.state.user.uId,productName: coupon['search_word'].toString(),)));
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: Image.network(coupon['img_url_s'].toString(),width: 45,height: 45,fit: BoxFit.cover,),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),

                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                        ),
                      );
                    }
                ),
              ),

              //todo popular items list button
              Visibility(
                // ignore: avoid_bool_literals_in_conditional_expressions
                visible: AppConfig.lang=='kor' ? true : false,
                child: Positioned(
                  bottom: sw*0.37,
                  left: 0,
                  child: GestureDetector(
                      onTap: (){
                        effectMusicPlayer.playOnce('click_main_ui');
                        if(animation.value == 96) {
                          _popularItemListScrollController.animateTo(0, duration:const Duration(seconds: 1), curve:Curves.linear,);
                          animation.reverse();
                          //animation.value = -154.0;
                        }else{
                          _popularItemListScrollController.animateTo(_popularItemListScrollController.position.maxScrollExtent, duration:const Duration(seconds: 10), curve:Curves.linear,);
                          animation.forward();
                          //animation.value = 96.0;
                        }
                      },
                      child: Image.file(File('$_imagePath/etc/pup_btn.png'),width: 120,)
                  ),
                ),
              ),


              HookBuilder(
                builder: (context) {
                  final state = useBloc<AuthenticationBloc,AuthenticationState>(onEmitted: (_,p,c)=>p.user!=c.user).state;
                  return Positioned(
                      right: 0,
                      bottom: sw * 0.55,
                      child: GestureDetector(
                        onTapDown: (d) {
                          effectMusicPlayer.playOnce('click_main_ui');
                        },
                        onTap: () async {
                          showConfirmRewardAd(context, state.exchangeAd['play_coin'] as int, "playcoin",(bool call)async{
                            if(call!=null&&call) {
                              //광고 카운트 체크크
                             final flag = await checkMaxAdvertisementCount();
                             if(flag){
                               final bool result = false;
                               // final bool result = await Navigator.push(context,
                               //     PageTransition(type: PageTransitionType.fade,
                               //         child: RewardAdWindow(
                               //           userId: state.user.uId,
                               //           rewardType: "u_playCoin",
                               //           amount: state
                               //               .exchangeAd['play_coin'] as int,)));

                               showAdResult(
                                   context, state.exchangeAd['play_coin'] as int,
                                   result);
                             }else{
                               Fluttertoast.showToast(
                                   msg: AppConfig.lang=='kor' ? "하루 광고 시청 횟수를 초과 하였습니다." : 'Max advertisement count' ,
                                   toastLength: Toast.LENGTH_SHORT,
                                   gravity: ToastGravity.CENTER,
                                   backgroundColor:
                                   Colors.black.withOpacity(0.7),
                                   textColor: Colors.white,
                                   fontSize: 15.0);
                             }
                            }
                          });
                          //todo 페이스북 광고
                          // await Navigator.push(
                          //     context,
                          //     PageTransition(
                          //         type: PageTransitionType.fade,
                          //         child: FaceBookAdScreen())
                          // );

                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(File('$_imagePath/ui/btn_free_ad.png'),width: 114,),
                            Positioned(
                              bottom: 12,
                              right: 10,
                              child: Column(
                                children: [
                                  RoutWidget(child: Image.file(File('$_imagePath/ui/ic_free_ad.gif'),width: 65,)),
                                  const SizedBox(height: 4,),
                                  Text(AppConfig.lang=='kor' ? '무료 충전소' : 'Free Charge',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 12),)
                                ],
                              ),
                            )
                          ],
                        ),
                        // child: Image.file(
                        //   File(
                        //     '$_imagePath/ui/btn_free_ad.gif',
                        //   ),
                        //   width: sw * 0.24,
                        //   fit: BoxFit.contain,
                        // )
                      ));
                }
              ),
              //todo ranking button
              Positioned(
                right: 0,
                bottom: sw * 0.765,
                child: GestureDetector(
                  onTap: (){
                    effectMusicPlayer.playOnce('click_main_ui');
                    showRanking(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(File('$_imagePath/ui/btn_free_ad.png'),width: 114,),
                      Positioned(
                          right: 30,
                          child: Column(
                            children: [
                              RoutWidget(child: Image.file(File('$_imagePath/ui/ranking_icon.gif'),width: 35,)),
                              const SizedBox(height: 1,),
                              Text(AppConfig.lang=='kor' ? '랭킹' : 'Rank',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 12),)
                            ],
                          )
                      ),

                    ],
                  ),
                ),
              ),

              //todo show ranking button
              // Positioned(
              //     left: 5,
              //     top: 120,
              //     child: Stack(
              //       alignment: Alignment.center,
              //       children: [
              //         IgnorePointer(child: Image.file(File('$_imagePath/ui/ranking_frame.png'),width: 120,)),
              //         Positioned(top:14,child: Image.file(File('$_imagePath/ui/ranking_icon.gif'),width: 44,)),
              //         GestureDetector(onTap:(){
              //           effectMusicPlayer.playOnce('click_main_ui');
              //           showRanking(context);
              //         },
              //         child: Container(width: 110,height: 80,color: Colors.transparent,))
              //       ],
              //     )
              // ),
              ScreenAppBar(
                isMain: true,
              ),
            ],
          ),

        ),
      ),
    );
  }






  Future<void> showRanking(BuildContext context) async{
    final BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
    backgroundMusicPlayer.playLoop('a_rank');
    await showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        context: context,
        builder: (context2) => Center(
          child: Material(
            color: Colors.transparent,
            child: _ShowTopList(),
          ),
        )
    );
    backgroundMusicPlayer.playLoop('a_main');
  }

  Future<void> showAdResult(
      BuildContext context, int count, bool type) async {
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

  Future<void> showConfirmRewardAd(BuildContext context, int count, String type,
      Function isPressed) async {
    await showDialog(
      barrierColor: Colors.black.withOpacity(0.2),
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ShowConfirmRewardView(type, count)
      ),
    ).then((value){
      isPressed(value);
    });
  }

}
Future<void> showRankingInfo(BuildContext context) async{
  final BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
  backgroundMusicPlayer.playLoop('a_rank');
  await showDialog(
      barrierColor: Colors.black.withOpacity(0.2),
      context: context,
      builder: (context2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _ShowRankingInfo(),
        ),
      )
  );
  backgroundMusicPlayer.playLoop('a_main');
}
class _ShowAdResult extends HookWidget {
  final int count;
  final bool type;

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
                      '${AppConfig.appDocDirectory!.path}${'/osgame/icons/play_coin.png'}'),
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  type ?'플레이 포인트 $count개 획득!': '플레이 포인트 획득 못 했습니다',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
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

class MainNavBar extends HookWidget {

  final BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main';

  final VideoPlayerController controller;

  MainNavBar(this.controller);

  @override
  Widget build(BuildContext context) {

    final isGifAllowed = useState(true);



    final sw = MediaQuery.of(context).size.width;
    final userState = useBloc<AuthenticationBloc,AuthenticationState>(onEmitted: (_,p,c) => p.user!=c.user).state;
    return Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File('$_imagePath/ui/nav_bar.png'),
              width: sw,
              fit: BoxFit.contain,
            ),
            Positioned(
              top: sw * 0.055,
              child: GestureDetector(
                  onTap: () async {
                    effectMusicPlayer.playOnce('click_main_ui');
                    await Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: StageListScreen()));
                    final BackgroundMusicPlayer backgroundMusicPlayer =
                        BackgroundMusicPlayer();
                    backgroundMusicPlayer.playLoop('a_main');
                    controller.play();
                    //context.bloc<AuthenticationBloc>().add(AuthenticationLogoutRequested());
                  },
                  child: RoutWidget(
                    child: Image.file(
                      File('$_imagePath/ui/btn_play.gif'),
                      width: sw * 0.225,
                    ),
                  )),
            ),
            Positioned(
              top: sw * 0.255,
              child: const Text(
                '',
                style: TextStyle(
                    color: Color(0xff545454),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            Positioned(
              left: (-1)*(sw * 0.005),
              bottom: sw * 0.014,
              child: NavBarButton(
                size: sw * 0.18,
                imagePath: !isGifAllowed.value ? '$_imagePath/ui/gc_btn.png' :'$_imagePath/ui/btn_ex.gif',
                text: '쿠폰 교환',
                textMargin: 2.0,
                paddingLeft: sw * 0.007,
                onPressed: () async {
                  await Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: ExchangeScreen(userState.user.uId)
                      )
                  );
                  backgroundMusicPlayer.playLoop('a_main');
                  controller.play();
                },
              ),
            ),
            Positioned(
              left: sw * 0.194,
              bottom: sw * 0.00,
              child: NavBarButton(
                size: sw * 0.18,
                imagePath: !isGifAllowed.value ? '$_imagePath/ui/gc_btn.png' :'$_imagePath/ui/btn_cart.gif',
                paddingLeft: sw * 0.03,
                textMargin: 0.0,
                text: '아이템',
                onPressed: () async {
                  await Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: ShopScreen(userState.user.uId)
                      )
                  );
                  backgroundMusicPlayer.playLoop('a_main');
                  controller.play();
                },
              ),
            ),
            Positioned(
              right: sw * 0.208,
              bottom: sw * 0.00,
              child: NavBarButton(
                size: sw * 0.18,
                imagePath: !isGifAllowed.value ? '$_imagePath/ui/gc_btn.png' : '$_imagePath/ui/btn_inven.gif',
                paddingLeft: sw * 0.00,
                textMargin: 0.0,
                text: '보관함',
                onPressed: () async {
                  await Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: InventoryScreen(userState.user.uId))
                  );
                  backgroundMusicPlayer.playLoop('a_main');
                  controller.play();
                },
              ),
            ),
            Positioned(
              right: sw * 0.0,
              bottom: sw * 0.01,
              child: NavBarButton(
                size: sw * 0.18,
                imagePath: !isGifAllowed.value ? '$_imagePath/ui/gc_btn.png' : '$_imagePath/ui/btn_friend.gif',
                text: '친구',
                textMargin: 4.0,
                paddingLeft: 0.0,
                onPressed: () async {
                  await Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: FriendsScreen(userState.user)));
                  backgroundMusicPlayer.playLoop('a_main');
                  controller.play();
                },
              ),
            ),
          ],
        );

  }
}

class NavBarButton extends StatelessWidget {
  final double size;
  final String imagePath;
  final String text;
  final double paddingLeft;
  final double textMargin;
  final Function onPressed;

  NavBarButton(
      {required this.size,
      required this.imagePath,
      required this.text,
      required this.paddingLeft,
      required this.textMargin,
      required this.onPressed});

  final EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) {
        effectMusicPlayer.playOnce('click_main_ui');
      },
      onTap: () {
        onPressed();
      },
      child: Container(
        width: size,
        color: Colors.transparent,
        child: Column(
          children: [
            RoutWidget(
              child: Image.file(
                File(imagePath),
                width: size,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: textMargin,
            ),
            Visibility(
              visible: false,
              child: Padding(
                padding: EdgeInsets.only(left: paddingLeft),
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff545454)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class _ShowRankingInfo extends HookWidget {

  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main';

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      width: 320,
      height: 320*(1849/1013)+40,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_e.png',
                pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_d.png',
                onPressed: (){
                  Navigator.pop(context);
                },
                width: 30,
              )
            ],
          ),
          Container(
              padding: const EdgeInsets.only(top: 10,left: 4,right:4,bottom: 5),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(File('${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/m_frame2.png')),
                      fit: BoxFit.cover
                  )
              ),
              width: 320,
              height: 320*(1849/1013),
              child: Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300,width: 1)
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class6.png'),width: 120,),
                            const Text('2000점 이상',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey),)
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300,width: 1)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class5.png'),width: 120,),
                            const Text('1500~1999점 이상',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey),)
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300,width: 1)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class4.png'),width: 120,),
                            const Text('1000~1499점 이상',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey),)
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300,width: 1)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class3.png'),width: 120,),
                            const Text('500~999점 이상',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey),)
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300,width: 1)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class2.png'),width: 120,),
                            const Text('100~499점 이상',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey),)
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300,width: 1)
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class1.png'),width: 120,),
                            const Text('99점 이하',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  Future<void> showHistoryPayOfOther(BuildContext context) async{
    await showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        context: context,
        builder: (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 320,
              height: 320*(1849/1013)+40,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_e.png',
                        pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_d.png',
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        width: 30,
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20,left: 13,right:13,bottom: 5),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File('$_imagePath/etc/m_frame1.png')),
                            fit: BoxFit.cover
                        )
                    ),
                    width: 320,
                    height: 320*(1849/1013),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ProfileImagePolygonBox1(url: 'https://www.computerhope.com/comp/logos/facebook.png',size: 60.0,colorType: 'y',),
                              const SizedBox(height: 5,),
                              const Text('정민1422',style: TextStyle(color: appMainColor,fontSize: 18,fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 16),
                              width: double.infinity,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),

                                  ],
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _buildHistoryList({String? url, required String title, required String content}){
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          color:Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(url!,height: 50,)
          ),
          const SizedBox(width: 10,),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                  Container(margin:const EdgeInsets.symmetric(vertical: 4),width: 150,height: 2,color: Colors.white,),
                  Text(content,style: const TextStyle(color: Colors.black,fontSize: 11,fontWeight: FontWeight.bold),)
                ],
              )
          ),
        ],
      ),

    );
  }
}

class _ShowTopList extends HookWidget {

  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/main';

  @override
  Widget build(BuildContext context) {

    final users = useBloc<AuthenticationBloc,AuthenticationState>(onEmitted: (_,p,c) => p.user!=c.user);
    return SizedBox(
      width: 320,
      height: 320*(1849/1013)+40,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_e.png',
                pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_d.png',
                onPressed: (){
                  Navigator.pop(context);
                },
                width: 30,
              )
            ],
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 5,left: 13,right:13,bottom: 5),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(File('${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/m_frame2.png')),
                        fit: BoxFit.cover
                    )
                ),
                width: 320,
                height: 320*(1849/1013),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                color: Colors.transparent,
                                width: 320,
                                height: 160,
                              ),
                              Stack(
                                children: [
                                  ProfileImagePolygonBox1(url: users.state.user.uImgBig,size: 54.0,colorType: 'y',),
                                ],
                              ),
                              Positioned(
                                  bottom: 30,
                                  child: Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class${AppConfig.getMyRank(users.state.user.uRankPoint)}.png'),height: 130,)
                              ),
                              Positioned(
                                bottom: 0,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 0,),
                                    Text(users.state.user.uName,style: const TextStyle(color: appMainColor,fontSize: 16,fontWeight: FontWeight.bold),),
                                    const SizedBox(height: 1,),
                                    Text('${users.state.user.uRankPoint}점',style: const TextStyle(color: appMainColor,fontSize: 16,fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        child: HookBuilder(
                          builder: (context) {
                            final topUsers = useBloc<AuthenticationBloc,AuthenticationState>(onEmitted: (_,p,c) => p.topUsers!=c.topUsers);
                            return SingleChildScrollView(
                              child: Column(
                                children: topUsers.state.topUsers.map((user){

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 7),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: const Color(0xff545454),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                            color: Colors.transparent,
                                            width: 25,
                                            child: Text('${user['index']}위',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14,fontStyle: FontStyle.italic,),)
                                        ),
                                        const SizedBox(width: 8,),
                                        Expanded(
                                            child: Row(
                                              children: [
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/class${AppConfig.getMyRank(int.parse(user['u_rankPoint'].toString()))}.png'),height: 58,),
                                                    Positioned(
                                                        bottom:10,
                                                        child: ProfileImagePolygonBox1(url:user['u_imgUrl'].toString(),size: 20,colorType: 'w',)
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 3,),
                                                Expanded(child: Text('${user['u_name']}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),overflow: TextOverflow.ellipsis,)),
                                                const SizedBox(width: 4,),
                                                Text('${user['u_rankPoint']}점',style: const TextStyle(color: appMainColor,fontWeight: FontWeight.bold,fontSize: 12),overflow: TextOverflow.ellipsis,)
                                              ],
                                            )
                                        ),
                                        Visibility(
                                          visible: false,
                                          child: CustomButton(
                                            pressedImageFilePath: '$_imagePath/etc/btn1_d.png',
                                            defaultImageFilePath: '$_imagePath/etc/btn1_e.png',
                                            width: 70,
                                            onPressed: (){
                                              //todo 유저 구매 내역 리스트 dialog
                                              // showHistoryPayOfOther(context);
                                            },
                                            text: const Text('교환목록',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 11),),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        ),
                      )
                    )
                  ],
                )
              ),
              Positioned(
                top:10,
                left:10,
                child: CustomButton(
                  defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_e.png',
                  pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_d.png',
                  text: Text(AppConfig.lang=='kor'? '랭킹 정보' : 'Info',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),),
                  onPressed: (){
                    //todo 랭키 정보 창 호출
                    showRankingInfo(context);
                  },
                  width: 78,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> showHistoryPayOfOther(BuildContext context) async{
    await showDialog(
        barrierColor: Colors.black.withOpacity(0.2),
        context: context,
        builder: (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 320,
              height: 320*(1849/1013)+40,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_e.png',
                        pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_d.png',
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        width: 30,
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20,left: 13,right:13,bottom: 5),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File('$_imagePath/etc/m_frame1.png')),
                            fit: BoxFit.cover
                        )
                    ),
                    width: 320,
                    height: 320*(1849/1013),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ProfileImagePolygonBox1(url: 'https://www.computerhope.com/comp/logos/facebook.png',size: 60.0,colorType: 'y',),
                              const SizedBox(height: 5,),
                              const Text('정민1422',style: TextStyle(color: appMainColor,fontSize: 18,fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 16),
                              width: double.infinity,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),
                                    _buildHistoryList(title: '스타벅스',url:'http://image.gsshop.com/image/91/25/91258181_L1.jpg',content: '아이스 아메리카노 TALL 사이즈'),

                                  ],
                                ),
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _buildHistoryList({required String url, required String title, required String content}){
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          color:Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(url,height: 50,)
          ),
          const SizedBox(width: 10,),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                  Container(margin:const EdgeInsets.symmetric(vertical: 4),width: 150,height: 2,color: Colors.white,),
                  Text(content,style: const TextStyle(color: Colors.black,fontSize: 11,fontWeight: FontWeight.bold),)
                ],
              )
          ),
        ],
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
                AppConfig.lang=='kor' ? '보상형 광고를 시청하고\n${type == "addtime" ? "시간추가 아이템" : "플레이 포인트"} $count개를\n획득하시겠습니까?' :
                'Do you want \n$count ${type == "addtime" ? "time item" : "play point"} ?',
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
              text: Text(
                AppConfig.lang=='kor'?'광고보기' : 'Confirm',
                style: const  TextStyle(
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
