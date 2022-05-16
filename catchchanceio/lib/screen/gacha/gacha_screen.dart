// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:catchchanceio/music/background_music_player.dart';
// import 'package:catchchanceio/repository/authentication/models/app_config.dart';
// import 'package:catchchanceio/repository/authentication/shop_repository.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:video_player/video_player.dart';
//
// import 'cubit/gacha_cubit.dart';
//
// class GachaScreen extends StatelessWidget {
//   final String myId;
//
//   const GachaScreen(this.myId);
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIOverlays([]);
//     return BlocProvider(
//       create: (_) => GachaCubit(ShopRepository(), myId),
//       child: _GachaScreen(),
//     );
//   }
// }
//
// class _GachaScreen extends StatefulWidget {
//   @override
//   _GachaScreenState createState() => _GachaScreenState();
// }
//
// class _GachaScreenState extends State<_GachaScreen> {
//   final _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/screen/gacha/';
//   final _iconImagePath = '${AppConfig.appDocDirectory!.path}/osgame/icons/';
//
//   late VideoPlayerController _idleVideoController;
//   late VideoPlayerController _actionVideoController;
//   late Future<void> _initializeIdleVideoPlayerFuture;
//   late Future<void> _initializeActionVideoPlayerFuture;
//   BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
//
//   final GlobalKey<SelectingRawSectionState> _myKey = GlobalKey();
//   bool _isAction = false;
//   bool _isRouletteSection = true;
//   bool _isRewardFinished = true;
//   bool randomIconOpacity = false;
//   double maxTotalSuccessPercent = 100.0;
//   double totalSuccessPercent = 0.0;
//   Map<String, Map<String, double>> posMap = {
//     'forest': {'posX': 0.0, 'posY': 0.0},
//     'desert': {'posX': 0.0, 'posY': 0.0},
//     'sea': {'posX': 0.0, 'posY': 0.0},
//     'dia': {'posX': 0.0, 'posY': 0.0},
//     'mine': {'posX': 0.0, 'posY': 0.0},
//   };
//
//   //todo functions...
//   double getDoubleInRange() {
//     final Random source = Random();
//     const num start = 0.0;
//     const num end = 0.9;
//     return source.nextDouble() * (end - start) + start;
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _idleVideoController =
//         VideoPlayerController.file(File('${_imagePath}ani_idle.mp4'));
//     _initializeIdleVideoPlayerFuture = _idleVideoController.initialize();
//     _idleVideoController.setLooping(true);
//     _idleVideoController.play();
//
//     _actionVideoController =
//         VideoPlayerController.file(File('${_imagePath}ani_action.mp4'));
//     _initializeActionVideoPlayerFuture = _actionVideoController.initialize();
//     _actionVideoController.setLooping(false);
//
//     //todo setup random position prize icon...
//     posMap.forEach((key, value) {
//       posMap[key]!['posX'] = getDoubleInRange();
//       posMap[key]!['posY'] = getDoubleInRange();
//     });
//     backgroundMusicPlayer.playLoop('a_gacha');
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _idleVideoController.dispose();
//     _actionVideoController.dispose();
//     super.dispose();
//   }
//
//   void resetSelection() {}
//
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           color: Colors.white10,
//           child: Stack(
//             children: [
//               //todo background gacha ani
//               Visibility(
//                 visible: !_isAction,
//                 child: FutureBuilder(
//                   future: _initializeIdleVideoPlayerFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.done) {
//                       return SizedBox.expand(
//                         child: FittedBox(
//                           fit: BoxFit.cover,
//                           child: SizedBox(
//                             width: sw,
//                             height: sh,
//                             child: VideoPlayer(_idleVideoController),
//                           ),
//                         ),
//                       );
//                     } else {
//                       return Container(
//                         width: sw,
//                         height: sh,
//                         color: const Color(0xff0f71a7).withOpacity(0.0),
//                       );
//                     }
//                   },
//                 ),
//               ),
//               Visibility(
//                 visible: _isAction,
//                 child: SizedBox.expand(
//                   child: FutureBuilder(
//                     future: _initializeActionVideoPlayerFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.done) {
//                         return SizedBox.expand(
//                           child: FittedBox(
//                             fit: BoxFit.cover,
//                             child: SizedBox(
//                               width: sw,
//                               height: sh,
//                               child: VideoPlayer(_actionVideoController),
//                             ),
//                           ),
//                         );
//                       } else {
//                         return Container(
//                           width: sw,
//                           height: sh,
//                           color: const Color(0xff0f71a7).withOpacity(0.0),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//
//               Positioned(
//                   bottom: 0,
//                   child: AnimatedOpacity(
//                       opacity: _isRouletteSection ? 1.0 : 0,
//                       duration: _isRouletteSection
//                           ? const Duration(milliseconds: 700)
//                           : const Duration(),
//                       child: IgnorePointer(
//                           ignoring: !_isRouletteSection,
//                           child: RouletteSection(
//                             onGoSelecting: () {
//                               setState(() {
//                                 _isRouletteSection = !_isRouletteSection;
//                               });
//                             },
//                           )))),
//               BlocBuilder<GachaCubit, GachaState>(
//                 builder: (context, state) {
//                   return Positioned(
//                       bottom: 0,
//                       child: AnimatedOpacity(
//                         opacity: !_isRouletteSection ? 1.0 : 0,
//                         duration: !_isRouletteSection
//                             ? const Duration(milliseconds: 700)
//                             : const Duration(),
//                         child: IgnorePointer(
//                           ignoring: _isRouletteSection,
//                           child: SelectingRawSection(
//                             key: _myKey,
//                             onTotalPercentChanged: (double totalPercent) {
//                               setState(() {
//                                 totalSuccessPercent = totalPercent;
//                               });
//                             },
//                             onSelectedCompleted: () {
//                               if (_isRewardFinished) {
//                                 showCustomDialog(
//                                     context: context,
//                                     contentText: '정말 진행을 하시겠습니까?',
//                                     confirmText: '확인',
//                                     rejectText: '취소',
//                                     onConfirm: () {
//                                       setState(() {
//                                         _isRewardFinished = false;
//                                         posMap.forEach((key, value) {
//                                           posMap[key]['posX'] = 0.51;
//                                           posMap[key]['posY'] = 0.458;
//                                         });
//                                         randomIconOpacity = true;
//                                         Timer(
//                                             const Duration(milliseconds: 3000),
//                                             () {
//                                           setState(() {
//                                             randomIconOpacity = false;
//                                           });
//                                         });
//                                         _getStartGacha(
//                                             state.success, state.fail);
//                                       });
//                                     });
//                               }
//                             },
//                             onBackButton: () {
//                               setState(() {
//                                 _isRouletteSection = !_isRouletteSection;
//                               });
//                             },
//                           ),
//                         ),
//                       ));
//                 },
//               ),
//
//               //todo gacha prize animation
//               Container(
//                 width: sw,
//                 height: sw * 1.24,
//                 color: Colors.transparent,
//                 child: Stack(
//                   children: [
//                     AnimatedPositioned(
//                         curve: Curves.easeIn,
//                         duration: const Duration(seconds: 1),
//                         left: posMap['forest']['posX'] * sw - 42,
//                         top: (posMap['forest']['posY'] * sh) - 42,
//                         child: AnimatedOpacity(
//                             duration: const Duration(seconds: 1),
//                             opacity: randomIconOpacity ? 1.0 : 0.0,
//                             child: Image.file(
//                               File('${_iconImagePath}prize_forest.png'),
//                               width: 84,
//                               height: 84,
//                               fit: BoxFit.cover,
//                             ))),
//                     AnimatedPositioned(
//                         curve: Curves.easeIn,
//                         duration: const Duration(seconds: 1),
//                         left: posMap['desert']['posX'] * sw - 42,
//                         top: (posMap['desert']['posY'] * sh) - 42,
//                         child: AnimatedOpacity(
//                             duration: const Duration(seconds: 1),
//                             opacity: randomIconOpacity ? 1.0 : 0.0,
//                             child: Image.file(
//                               File('${_iconImagePath}prize_desert.png'),
//                               width: 84,
//                               height: 84,
//                               fit: BoxFit.cover,
//                             ))),
//                     AnimatedPositioned(
//                         curve: Curves.easeIn,
//                         duration: const Duration(seconds: 1),
//                         left: posMap['sea']['posX'] * sw - 42,
//                         top: posMap['sea']['posY'] * sh - 42,
//                         child: AnimatedOpacity(
//                             duration: const Duration(seconds: 1),
//                             opacity: randomIconOpacity ? 1.0 : 0.0,
//                             child: Image.file(
//                               File('${_iconImagePath}prize_sea.png'),
//                               width: 84,
//                               height: 84,
//                               fit: BoxFit.cover,
//                             ))),
//                     AnimatedPositioned(
//                         curve: Curves.easeIn,
//                         duration: const Duration(seconds: 1),
//                         left: posMap['mine']['posX'] * sw - 42,
//                         top: posMap['mine']['posY'] * sh - 42,
//                         child: AnimatedOpacity(
//                             duration: const Duration(seconds: 1),
//                             opacity: randomIconOpacity ? 1.0 : 0.0,
//                             child: Image.file(
//                               File('${_iconImagePath}prize_mine.png'),
//                               width: 84,
//                               height: 84,
//                               fit: BoxFit.cover,
//                             ))),
//                     AnimatedPositioned(
//                         curve: Curves.easeIn,
//                         duration: const Duration(seconds: 1),
//                         left: posMap['dia']['posX'] * sw - 42,
//                         top: posMap['dia']['posY'] * sh - 42,
//                         child: AnimatedOpacity(
//                             duration: const Duration(seconds: 1),
//                             opacity: randomIconOpacity ? 1.0 : 0.0,
//                             child: Image.file(
//                               File('${_iconImagePath}prize_dia.png'),
//                               width: 84,
//                               height: 84,
//                               fit: BoxFit.cover,
//                             ))),
//                   ],
//                 ),
//               ),
//
//               //todo appbar
//               SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.1,
//                   child: const ScreenAppBar()),
//             ],
//           )),
//     );
//   }
//
//   void _getStartGacha(
//       List<Map<String, dynamic>> data, List<Map<String, dynamic>> fail) {
//     setState(() {
//       _isAction = !_isAction;
//       if (_isAction) {
//         _playActionVideo(data, fail);
//       } else {
//         _playIdleVideo();
//       }
//     });
//   }
//
// //todo mp4 재생 시간
//   final int _actionVideoPlayTime = 8680;
//
//   void _playActionVideo(
//       List<Map<String, dynamic>> data, List<Map<String, dynamic>> fail) {
//     _idleVideoController.pause();
//     _actionVideoController.seekTo(const Duration());
//     _actionVideoController.play();
//     Future.delayed(Duration(milliseconds: _actionVideoPlayTime - 1000), () {
//       setState(() {
//         _isRouletteSection = !_isRouletteSection;
//         posMap.forEach((key, value) {
//           posMap[key]['posX'] = getDoubleInRange();
//           posMap[key]['posY'] = getDoubleInRange();
//         });
//         showResultOfRoulette(context,
//             data: data, fail: fail, successPercent: totalSuccessPercent);
//         totalSuccessPercent = 0.0;
//         _myKey.currentState.resetValue();
//       });
//     });
//
//     Future.delayed(Duration(milliseconds: _actionVideoPlayTime), () {
//       _playIdleVideo();
//       setState(() {
//         _isAction = !_isAction;
//       });
//     });
//   }
//
//   void _playIdleVideo() {
//     _actionVideoController.pause();
//     _idleVideoController.seekTo(const Duration());
//     _idleVideoController.play();
//   }
//
//   void showResultOfRoulette(BuildContext context,
//       {List<Map<String, dynamic>> data,
//       List<Map<String, dynamic>> fail,
//       double successPercent}) {
//     //todo successPercent 를 기준으로 성공 / 실패 결과 리턴!
//     final Random random = Random();
//     final index = random.nextInt(data.length);
//     double getDoubleInRange() {
//       final Random source = Random();
//       const num start = 0.0;
//       const num end = 100.0;
//       return source.nextDouble() * (end - start) + start;
//     }
//
//     bool isSuccess = false;
//     if (successPercent >= getDoubleInRange()) {
//       isSuccess = true;
//       context.read<GachaCubit>().giftSuccess(index);
//     }
//
//     showDialog(
//         context: context,
//         builder: (_) => Center(
//               child: Material(
//                 color: Colors.transparent,
//                 child: Container(
//                   width: 260,
//                   height: 500,
//                   color: Colors.transparent,
//                   child: Column(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         color: Colors.transparent,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             IconButton(
//                                 icon: const Icon(
//                                   Icons.cancel,
//                                   size: 40,
//                                   color: Colors.grey,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 })
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 15, horizontal: 12),
//                           width: double.infinity,
//                           color: Colors.grey.shade200.withOpacity(0.94),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 children: [
//                                   Container(
//                                     width: 220,
//                                     height: 220,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Colors.black54, width: 3),
//                                         image: DecorationImage(
//                                             image: NetworkImage(isSuccess
//                                                 ? data[index]['type_item'] ==
//                                                         "coupon"
//                                                     ? data[index]['img_url_b']
//                                                         .toString()
//                                                     : data[index]['img_url']
//                                                         .toString()
//                                                 : fail[0]['img_url']
//                                                     .toString()),
//                                             fit: BoxFit.cover)),
//                                   ),
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const SizedBox(
//                                           height: 15,
//                                         ),
//                                         Text(
//                                           isSuccess ? '슈퍼보상 당첨!' : '다음 기회에..',
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 24,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         const SizedBox(
//                                           height: 5,
//                                         ),
//                                         Text(
//                                           isSuccess
//                                               ? data[index]['title'].toString()
//                                               : fail[0]['title'].toString(),
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 24,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         const SizedBox(
//                                           height: 3,
//                                         ),
//                                         Text(
//                                           isSuccess
//                                               ? data[index]['s_desc'].toString()
//                                               : fail[0]['s_desc'].toString(),
//                                           style: TextStyle(
//                                               color: Colors.grey.shade700,
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   SizedBox(
//                                     width: 115,
//                                     height: 38,
//                                     child: RaisedButton(
//                                       padding: EdgeInsets.zero,
//                                       onPressed: () {
//                                         Navigator.pop(context);
//                                       },
//                                       color: appMainColor,
//                                       child: const Text(
//                                         '확인',
//                                         style: TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             )).then((value) {
//       setState(() {
//         _isRewardFinished = true;
//       });
//     });
//   }
// }
//
// class RouletteSection extends StatefulWidget {
//   final Function onGoSelecting;
//
//   const RouletteSection({this.onGoSelecting});
//
//   @override
//   _RouletteSectionState createState() => _RouletteSectionState();
// }
//
// class _RouletteSectionState extends State<RouletteSection> {
//   bool _op = false;
//   Timer timer;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     timer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
//       setState(() {
//         _op = !_op;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     timer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     return Container(
//       width: sw,
//       height: sw * 0.84,
//       padding: const EdgeInsets.only(bottom: 8),
//       color: Colors.transparent,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           BlocBuilder<GachaCubit, GachaState>(
//             builder: (context, state) {
//               return Column(
//                 children: [
//                   const _BlueOpacityContainer(
//                     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                     child: Text(
//                       '일정한 확률로 슈퍼보상 획득',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   _BlueOpacityContainer(
//                     width: sw,
//                     padding: const EdgeInsets.only(top: 10, bottom: 20),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: SizedBox(
//                         width: 550,
//                         height: 130,
//                         child: Stack(
//                           children: state.success
//                               .map(
//                                 (e) => OneRewardBox(
//                                   left: e['index'] * 90 as int,
//                                   isOpacity: _op,
//                                   rewardType: e['type_item'].toString(),
//                                   title: e['title'].toString(),
//                                   description: e['s_desc'].toString(),
//                                   imgUrl: e['type_item'] == "coupon"
//                                       ? e['img_url_s'].toString()
//                                       : e['img_url'].toString(),
//                                 ),
//                               )
//                               .toList(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//           _buildButton(
//               text: '재료 선택',
//               onPressed: () {
//                 widget.onGoSelecting();
//               })
//         ],
//       ),
//     );
//   }
// }
//
// class SelectingRawSection extends StatefulWidget {
//   final Function onSelectedCompleted;
//   final Function onBackButton;
//   final Function onTotalPercentChanged;
//
//   const SelectingRawSection(
//       {this.onSelectedCompleted,
//       this.onBackButton,
//       this.onTotalPercentChanged,
//       Key key})
//       : super(key: key);
//
//   @override
//   SelectingRawSectionState createState() => SelectingRawSectionState();
// }
//
// class SelectingRawSectionState extends State<SelectingRawSection> {
//   bool isOk = true;
//   double s1 = 0.0;
//   double s2 = 0.0;
//   double s3 = 0.0;
//   double s4 = 0.0;
//   double s5 = 0.0;
//   int c = 0;
//   final GlobalKey<OnePrizeBoxState> _myKey1 = GlobalKey();
//   final GlobalKey<OnePrizeBoxState> _myKey2 = GlobalKey();
//   final GlobalKey<OnePrizeBoxState> _myKey3 = GlobalKey();
//   final GlobalKey<OnePrizeBoxState> _myKey4 = GlobalKey();
//   final GlobalKey<OnePrizeBoxState> _myKey5 = GlobalKey();
//
//   void resetValue() {
//     _myKey1.currentState.reset();
//     _myKey2.currentState.reset();
//     _myKey3.currentState.reset();
//     _myKey4.currentState.reset();
//     _myKey5.currentState.reset();
//     setState(() {
//       s1 = 0.0;
//       s2 = 0.0;
//       s3 = 0.0;
//       s4 = 0.0;
//       s5 = 0.0;
//       c = 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     return Container(
//       width: sw,
//       padding: const EdgeInsets.only(bottom: 8),
//       height: sw * 0.84,
//       color: Colors.transparent,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       widget.onBackButton();
//                     },
//                     child: Container(
//                         margin: const EdgeInsets.only(right: 10),
//                         child: const Icon(
//                           Icons.keyboard_return_outlined,
//                           color: Colors.white70,
//                           size: 26,
//                         )),
//                   )
//                 ],
//               ),
//               Stack(
//                 children: [
//                   BlocBuilder<GachaCubit, GachaState>(
//                     builder: (context, state) {
//                       return Column(
//                         children: [
//                           _BlueOpacityContainer(
//                               width: sw,
//                               padding:
//                                   const EdgeInsets.only(top: 10, bottom: 15),
//                               child: BlocBuilder<AuthenticationBloc,
//                                   AuthenticationState>(
//                                 buildWhen: (p, c) => p.user != c.user,
//                                 builder: (context, stateAuth) {
//                                   return Column(
//                                     children: [
//                                       SingleChildScrollView(
//                                         scrollDirection: Axis.horizontal,
//                                         child: Row(
//                                           children: [
//                                             OnePrizeBox(
//                                               key: _myKey1,
//                                               prizeName: 'forest',
//                                               myCount: stateAuth.user
//                                                   .uRewards['stage1'] as int,
//                                               percent: state.percents['stage1']
//                                                   as int,
//                                               currentCount: c,
//                                               onNumberChanged:
//                                                   (eachPercent, currentCount) {
//                                                 setState(() {
//                                                   s1 = eachPercent as double;
//                                                   context
//                                                       .read<GachaCubit>()
//                                                       .updateSValue(
//                                                           {"s1": currentCount});
//                                                   widget.onTotalPercentChanged(
//                                                       s1 + s2 + s3 + s4 + s5);
//                                                 });
//                                               },
//                                             ),
//                                             OnePrizeBox(
//                                               key: _myKey2,
//                                               prizeName: 'desert',
//                                               myCount: stateAuth.user
//                                                   .uRewards['stage2'] as int,
//                                               percent: state.percents['stage2']
//                                                   as int,
//                                               currentCount: c,
//                                               onNumberChanged:
//                                                   (eachPercent, currentCount) {
//                                                 setState(() {
//                                                   s2 = eachPercent as double;
//                                                   context
//                                                       .read<GachaCubit>()
//                                                       .updateSValue(
//                                                           {"s2": currentCount});
//                                                   widget.onTotalPercentChanged(
//                                                       s1 + s2 + s3 + s4 + s5);
//                                                 });
//                                               },
//                                             ),
//                                             OnePrizeBox(
//                                               key: _myKey3,
//                                               prizeName: 'mine',
//                                               myCount: stateAuth.user
//                                                   .uRewards['stage3'] as int,
//                                               percent: state.percents['stage3']
//                                                   as int,
//                                               currentCount: c,
//                                               onNumberChanged:
//                                                   (eachPercent, currentCount) {
//                                                 setState(() {
//                                                   s3 = eachPercent as double;
//                                                   context
//                                                       .read<GachaCubit>()
//                                                       .updateSValue(
//                                                           {"s3": currentCount});
//                                                   widget.onTotalPercentChanged(
//                                                       s1 + s2 + s3 + s4 + s5);
//                                                 });
//                                               },
//                                             ),
//                                             OnePrizeBox(
//                                               key: _myKey4,
//                                               prizeName: 'sea',
//                                               myCount: stateAuth.user
//                                                   .uRewards['stage4'] as int,
//                                               percent: state.percents['stage4']
//                                                   as int,
//                                               currentCount: c,
//                                               onNumberChanged:
//                                                   (eachPercent, currentCount) {
//                                                 setState(() {
//                                                   s4 = eachPercent as double;
//                                                   context
//                                                       .read<GachaCubit>()
//                                                       .updateSValue(
//                                                           {"s4": currentCount});
//                                                   widget.onTotalPercentChanged(
//                                                       s1 + s2 + s3 + s4 + s5);
//                                                 });
//                                               },
//                                             ),
//                                             OnePrizeBox(
//                                               key: _myKey5,
//                                               prizeName: 'dia',
//                                               myCount: stateAuth.user
//                                                   .uRewards['stage5'] as int,
//                                               percent: state.percents['stage5']
//                                                   as int,
//                                               currentCount: c,
//                                               onNumberChanged:
//                                                   (eachPercent, currentCount) {
//                                                 setState(() {
//                                                   s5 = eachPercent as double;
//                                                   context
//                                                       .read<GachaCubit>()
//                                                       .updateSValue(
//                                                           {"s5": currentCount});
//                                                   widget.onTotalPercentChanged(
//                                                       s1 + s2 + s3 + s4 + s5);
//                                                 });
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 10,
//                                       ),
//                                       Text(
//                                         '슈퍼보상 당첨 확률 : ${(s1 + s2 + s3 + s4 + s5) <= 100 ? (s1 + s2 + s3 + s4 + s5).toStringAsFixed(2) : 100.0.toString()}%',
//                                         style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold),
//                                       )
//                                     ],
//                                   );
//                                 },
//                               )),
//                         ],
//                       );
//                     },
//                   ),
//                   Visibility(
//                     visible: isOk,
//                     child: GestureDetector(
//                       onTapDown: (d) {
//                         setState(() {
//                           isOk = false;
//                         });
//                       },
//                       child: Container(
//                         width: sw,
//                         height: 185,
//                         color: Colors.black.withOpacity(0.5),
//                         child: Image.file(File(
//                             '${AppConfig.appDocDirectory!.path}/osgame/icons/icon_sc.png')),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           _buildButton(
//               text: '선택 완료',
//               onPressed: () {
//                 if (s1 + s2 + s3 + s4 + s5 <= 0) {
//                   Fluttertoast.showToast(
//                       msg: '재료를 선택해주세요.',
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.CENTER,
//                       backgroundColor: Colors.black.withOpacity(0.7),
//                       textColor: Colors.white,
//                       fontSize: 15.0);
//                 } else {
//                   widget.onSelectedCompleted();
//                 }
//               })
//         ],
//       ),
//     );
//   }
// }
//
// class _BlueOpacityContainer extends StatelessWidget {
//   final double width;
//   final EdgeInsetsGeometry padding;
//   final Widget child;
//
//   const _BlueOpacityContainer({this.width, this.child, this.padding});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: padding,
//       width: width,
//       decoration: BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//             const Color(0xff075fb8),
//             const Color(0xff2f294f).withOpacity(0.0),
//             const Color(0xff075fb8)
//           ])),
//       child: child,
//     );
//   }
// }
//
// class OnePrizeBox extends StatefulWidget {
//   final String prizeName; //todo forest / desert / sea / mine / cube / dia
//   final int percent;
//   final int myCount;
//   final Function onNumberChanged;
//   final int currentCount;
//
//   const OnePrizeBox(
//       {@required this.prizeName,
//       @required this.percent,
//       @required this.myCount,
//       @required this.onNumberChanged,
//       @required this.currentCount,
//       Key key})
//       : super(key: key);
//
//   @override
//   OnePrizeBoxState createState() => OnePrizeBoxState();
// }
//
// class OnePrizeBoxState extends State<OnePrizeBox> {
//   final String _iconImagePath =
//       '${AppConfig.appDocDirectory!.path}/osgame/icons/';
//   final String _imagePath =
//       '${AppConfig.appDocDirectory!.path}/osgame/screen/gacha/';
//   int currentCount = 0;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     currentCount = widget.currentCount;
//   }
//
//   void reset() {
//     setState(() {
//       currentCount = 0;
//     });
//   }
//
//   void _showCountPicker({int number}) {
//     final List<Widget> wlist = [];
//
//     for (int i = 0; i <= number; i++) {
//       final Text t = Text(
//         '$i 개',
//         style: const TextStyle(color: Colors.white, fontSize: 24),
//       );
//       wlist.add(t);
//     }
//
//     showCupertinoModalPopup(
//         context: context,
//         builder: (BuildContext context) {
//           return SizedBox(
//             height: 150,
//             child: ScrollConfiguration(
//               behavior: NoGlowScrollBehavior(),
//               child: CupertinoPicker(
//                 scrollController:
//                     FixedExtentScrollController(initialItem: currentCount),
//                 backgroundColor: const Color(0xff075fb8).withOpacity(0.7),
//                 onSelectedItemChanged: (value) {
//                   setState(() {
//                     currentCount = value;
//                   });
//                   widget.onNumberChanged(
//                       currentCount * widget.percent.toDouble(), currentCount);
//                 },
//                 itemExtent: 40.0,
//                 children: wlist,
//               ),
//             ),
//           );
//         });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Row(
//             children: [
//               Text(
//                 '${widget.percent}%',
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(
//                 width: 16,
//               ),
//             ],
//           ),
//           Container(
//             width: 88,
//             height: 90,
//             color: Colors.transparent,
//             child: Stack(
//               children: [
//                 Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Image.file(
//                       File('${_imagePath}raw_box.png'),
//                       width: 60,
//                     )),
//                 Positioned(
//                     top: 0,
//                     left: 0,
//                     child: Image.file(
//                       File('$_iconImagePath${'prize_${widget.prizeName}.png'}'),
//                       width: 85,
//                       height: 85,
//                       fit: BoxFit.cover,
//                     )),
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 3,
//           ),
//           Row(
//             children: [
//               Text(
//                 '보유수량 : ${widget.myCount}',
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(
//                 width: 16,
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 3,
//           ),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   _showCountPicker(number: widget.myCount);
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.only(right: 5),
//                   width: 70,
//                   height: 30,
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.white, width: 2)),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Icon(
//                         Icons.swap_vert_rounded,
//                         color: Colors.white,
//                         size: 23,
//                       ),
//                       Text(
//                         '$currentCount개',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class OneRewardBox extends StatelessWidget {
//   final String _imagePath =
//       '${AppConfig.appDocDirectory!.path}/osgame/screen/gacha/';
//
//   final String rewardType;
//   final bool isOpacity;
//   final int left;
//   final String title;
//   final String description;
//   final String imgUrl;
//
//   OneRewardBox(
//       {this.isOpacity,
//       this.left,
//       this.rewardType,
//       this.title,
//       this.description,
//       this.imgUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: left.toDouble(),
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Image.file(
//                 File(
//                     '$_imagePath${'${rewardType == 'coupon' ? 'stage1' : 'stage2'}.png'}'),
//                 width: 100,
//               ),
//               Positioned(
//                 bottom: rewardType == 'coupon' ? 37 : 37,
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   child: Image.network(
//                     imgUrl,
//                     width: 45,
//                     height: 45,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               AnimatedOpacity(
//                   duration: const Duration(milliseconds: 1600),
//                   opacity: isOpacity ? 1.0 : 0.0,
//                   child: Image.file(
//                     File(
//                         '$_imagePath${'${rewardType == 'coupon' ? 'stage1' : 'stage2'}_ac.png'}'),
//                     width: 105,
//                   )),
//             ],
//           ),
//           const SizedBox(
//             height: 4,
//           ),
//           SizedBox(
//             width: 90,
//             child: Column(
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 9.6),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 //Text(description,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:10),overflow: TextOverflow.ellipsis)
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Widget _buildButton({String text, Function onPressed}) {
//   final String _imagePath =
//       '${AppConfig.appDocDirectory!.path}/osgame/screen/gacha/';
//   return GestureDetector(
//     onTap: () {
//       onPressed();
//     },
//     child: Stack(
//       alignment: Alignment.center,
//       children: [
//         Image.file(
//           File('${_imagePath}btn.png'),
//           width: 120,
//         ),
//         Text(
//           text,
//           style: TextStyle(
//               color: Colors.grey.shade800,
//               fontWeight: FontWeight.bold,
//               fontSize: 17),
//         )
//       ],
//     ),
//   );
// }
