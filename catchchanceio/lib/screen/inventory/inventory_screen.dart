import 'dart:io';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/repository/authentication/inventory_repository.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/dialog/os_dialog.dart';
import 'package:catchchanceio/widgets/texts/os_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'cubit/inventory_cubit.dart';

class InventoryScreen extends StatelessWidget {
  final String myId;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return BlocProvider(
      create: (_) => InventoryCubit(InventoryRepository(), myId),
      child: _InventoryScreen(),
    );
  }

  const InventoryScreen(this.myId);
}

class _InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<_InventoryScreen> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/inventory/';
  int _selectedTabIndex = 0;

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;

  BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      _videoController = VideoPlayerController.file(File(
          '${AppConfig.appDocDirectory!.path}/osgame/screen/inventory/bg.mp4'));
      _initializeVideoPlayerFuture = _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.play();
    }
    backgroundMusicPlayer.playLoop('a_inventory');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: FileImage(File('${_imagePath}bg.png')),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            _buildBackgroundVideo(),
            Column(
              children: [
                //todo appbar
                ScreenAppBar(),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTapNavButton(
                              tapName: AppConfig.lang=='kor' ? '아이템 보관함' : 'My item',
                              isSelected: _selectedTabIndex == 0,
                              onPressed: () {
                                //todo on Tap 1
                                context
                                    .read<InventoryCubit>()
                                    .changeScreen(Screens.ITEM);
                                setState(() {
                                  _selectedTabIndex = 0;
                                });
                              }),
                          const SizedBox(
                            width: 8,
                          ),
                          _buildTapNavButton(
                              tapName:  AppConfig.lang=='kor' ? '보상' : 'Reward',
                              isSelected: _selectedTabIndex == 1,
                              onPressed: () {
                                //todo on Tap 1
                                context
                                    .read<InventoryCubit>()
                                    .changeScreen(Screens.PRIZE);
                                setState(() {
                                  _selectedTabIndex = 1;
                                });
                              }),
                          const SizedBox(
                            width: 8,
                          ),
                          _buildTapNavButton(
                              tapName: AppConfig.lang=='kor' ? '쿠폰 보관함' : 'Coupon',
                              isSelected: _selectedTabIndex == 2,
                              onPressed: () {
                                //todo on Tap 1
                                context
                                    .read<InventoryCubit>()
                                    .changeScreen(Screens.COUPON);
                                setState(() {
                                  _selectedTabIndex = 2;
                                });
                              }),
                          const SizedBox(
                            width: 8,
                          ),
                          _buildTapNavButton(
                              tapName: AppConfig.lang=='kor' ? '사용 보관함' : 'Used',
                              isSelected: _selectedTabIndex == 3,
                              onPressed: () {
                                //todo on Tap 1
                                context
                                    .read<InventoryCubit>()
                                    .changeScreen(Screens.USED);
                                setState(() {
                                  _selectedTabIndex = 3;
                                });
                              }),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        width: sw,
                        height: 1.8,
                        color: Colors.grey,
                      ),
                      BlocBuilder<InventoryCubit, InventoryState>(
                        buildWhen: (p,c)=>p.currentData!=c.currentData,
                        builder: (context, state) {
                          if (state.screens == Screens.ITEM) {
                            //todo item list ...
                            const int len = 2;
                            int count = 60 - len;
                            if (count < 0) {
                              count = 0;
                            }

                            return BlocBuilder<AuthenticationBloc,
                                    AuthenticationState>(
                                buildWhen: (p, c) => p.user != c.user,
                                builder: (context, state) {
                                  return ListExpanded(
                                    children: [
                                      // OneInventoryBoxPrizeOrItem(
                                      //     type: 'item',
                                      //     subType: 'reset',
                                      //     leftCount:state.user.itemRotationCount
                                      // ),
                                      OneInventoryBoxPrizeOrItem(
                                          type: 'item',
                                          subType: 'play_coin_purple',
                                          leftCount: state.user.itemPurpleCoin),
                                      OneInventoryBoxPrizeOrItem(
                                          type: 'item',
                                          subType: 'play_coin_gold',
                                          leftCount: state.user.itemGoldCoin),
                                      OneInventoryBoxPrizeOrItem(
                                          type: 'item',
                                          subType: 'item_addtime',
                                          leftCount: state.user.itemPlayTime),
                                      ...List.generate(
                                          count,
                                          (index) =>
                                              const OneInventoryBoxCoupon(
                                                isEmpty: true,
                                              )),
                                    ],
                                  );
                                });
                          }
                          else if (state.screens == Screens.PRIZE) {
                            //todo prize list ...
                            const int len = 6;
                            int count = 60 - len;
                            if (count < 0) {
                              count = 0;
                            }

                            return BlocBuilder<AuthenticationBloc,
                                AuthenticationState>(
                              buildWhen: (p, c) => p.user != c.user,
                              builder: (context, state) {
                                return ListExpanded(
                                  children: [
                                    OneInventoryBoxPrizeOrItem(
                                        type: 'prize',
                                        subType: 'forest',
                                        leftCount: state.user.uRewards['stage1']
                                            as int),
                                    OneInventoryBoxPrizeOrItem(
                                        type: 'prize',
                                        subType: 'desert',
                                        leftCount: state.user.uRewards['stage2']
                                            as int),
                                    OneInventoryBoxPrizeOrItem(
                                        type: 'prize',
                                        subType: 'mine',
                                        leftCount: state.user.uRewards['stage3']
                                            as int),
                                    OneInventoryBoxPrizeOrItem(
                                        type: 'prize',
                                        subType: 'sea',
                                        leftCount: state.user.uRewards['stage4']
                                            as int),
                                    OneInventoryBoxPrizeOrItem(
                                        type: 'prize',
                                        subType: 'dia',
                                        leftCount: state.user.uRewards['stage5']
                                            as int),
                                    ...List.generate(
                                        count,
                                        (index) => const OneInventoryBoxCoupon(
                                              isEmpty: true,
                                            )),
                                  ],
                                );
                              },
                            );
                          }
                          else {
                            //todo used , unused coupon list ...
                            final int len = state.currentData.length;
                            print(len);
                            print(state.screens);
                            int count = 60 - len;
                            if (count < 0) {
                              count = 0;
                            }

                            return ListExpanded(
                              children: state.currentData
                                  .map((e) => OneInventoryBoxCoupon(
                                      title: e['title'].toString(),
                                      content: e['desc'].toString(),
                                      productImgUrl: e['img_url'].toString(),
                                      id: e['id'].toString(),
                                      type: e['type'].toString(),
                                      productId: e['product_id'].toString(),
                                      isUsed: e['is_used'] as bool,
                                      barcodeImgUrl:
                                          e['barcode_img_url'].toString(),
                                      leftCount: 1))
                                  .toList()
                                    ..addAll(List.generate(
                                        count,
                                        (index) => const OneInventoryBoxCoupon(
                                              isEmpty: true,
                                            ))),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapNavButton(
      {required Function onPressed,
      required String tapName,
      required bool isSelected}) {
    final sw = MediaQuery.of(context).size.width;
    return Opacity(
      opacity: isSelected ? 1 : 1,
      child: SizedBox(
        width: sw * 0.215,
        height: 32,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                  color: isSelected ? Colors.white : const Color(0xff8f8f8f),
                  width: isSelected ? 2 : 1)),
          padding: EdgeInsets.zero,
          onPressed: () {
            onPressed();
          },
          color: isSelected ? appMainColor : Colors.black,
          child: Text(
            tapName,
            style: TextStyle(
                color: isSelected ? Colors.black87 : const Color(0xff8f8f8f),
                fontSize: sw * 0.03,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundVideo() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox.expand(
            child: FittedBox(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(File('${_imagePath}bg.png')),
                    fit: BoxFit.cover)),
          );
        }
      },
    );
  }
}

class ListExpanded extends StatelessWidget {
  final List<Widget> children;

  const ListExpanded({required this.children});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(10),
      child: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            children: children),
      ),
    ));
  }
}

class OneInventoryBoxPrizeOrItem extends StatelessWidget {

  final String type; //todo 'prize' , 'item'
  final String
      subType; //todo prize-> 'forest','desert','mine','dia','sea'  ///// item-> 'reset' ,'laser', 'addtime'
  final bool isEmpty;
  final int leftCount;

  const OneInventoryBoxPrizeOrItem(
      {
      required this.subType,
      required this.type,
      this.isEmpty = false,
      required this.leftCount});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        _showDetailOfItem(context, type, subType, leftCount);
      },
      child: Opacity(
        opacity: isEmpty ? 0.42 : 1,
        child: Container(
          width: sw / 4 - 25,
          height: sw / 4 - 25,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(width: 2),
              image: DecorationImage(
                image: FileImage(File(
                    '${AppConfig.appDocDirectory!.path}/osgame/screen/inventory/item_inven_box.png')),
                fit: BoxFit.cover,
              )),
          child: Visibility(
            visible: !isEmpty,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: type == 'item'
                        ? Image.file(File(
                            '${AppConfig.appDocDirectory!.path}${'/osgame/icons/$subType.png'}'))
                        : Image.file(File(
                            '${AppConfig.appDocDirectory!.path}${'/osgame/icons/prize_$subType.png'}'))),
                Positioned(
                    right: 6,
                    bottom: 3.2,
                    child: TextWithOutline(
                      innerColor: Colors.white,
                      outerColor: Colors.black,
                      text: leftCount.toString(),
                      strokeWidth: 2.5,
                      fontSize: 13,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OneInventoryBoxCoupon extends StatelessWidget {
  final String? title;
  final String? content;
  final String? productImgUrl;
  final String? barcodeImgUrl;
  final String? id;
  final String? type;
  final String? productId;
  final bool? isUsed;
  final bool isEmpty;
  final int? leftCount;

  const OneInventoryBoxCoupon(
      {this.title,
      this.content,
      this.productImgUrl = '',
      this.id,
      this.type,
      this.productId,
      this.isUsed,
      this.barcodeImgUrl = '',
      this.isEmpty = false,
      this.leftCount});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (type == "Coupon") {
          showGifticonDetail(
              context, id, type, productId, isUsed, barcodeImgUrl);
        }
      },
      child: Opacity(
        opacity: isEmpty ? 0.42 : 1,
        child: Container(
          width: sw / 4 - 25,
          height: sw / 4 - 25,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(width: 2),
              image: DecorationImage(
                image: FileImage(File(
                    '${AppConfig.appDocDirectory!.path}/osgame/screen/inventory/item_inven_box.png')),
                fit: BoxFit.cover,
              )),
          child: Visibility(
            visible: !isEmpty,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: Image.network(
                      isEmpty ? '' : productImgUrl!,
                      width: sw / 4 - 20,
                    )),
                Positioned(
                    right: 6,
                    bottom: 3.2,
                    child: TextWithOutline(
                      innerColor: Colors.white,
                      outerColor: Colors.black,
                      text: leftCount.toString(),
                      strokeWidth: 2.5,
                      fontSize: 13,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showGifticonDetail(
    BuildContext? context,
    String? id,
    String? collection,
    String? productId,
    bool? isUsed,
    String? barcodeImgUrl) async {
  showDialog(
      context: context!,
      barrierDismissible: true,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width - 16,
                height: MediaQuery.of(context).size.height - 40,
                color: Colors.blueAccent.withOpacity(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              size: 40,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ],
                    ),
                    Image.network(
                      barcodeImgUrl!,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width - 16,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      isUsed! ? "" : AppConfig.lang =='kor' ?  "사용완료된 쿠폰은 '사용 쿠폰함' 에서 확인" : "Check used cpoupon in Used Tab",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // MySwitch(value: false, onChanged: (value){
                        //   print(value);
                        // })
                        Visibility(
                          visible: !isUsed,
                          child: SizedBox(
                            width: 140,
                            height: 38,
                            child: RaisedButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                showCustomDialog(
                                  context: context,
                                  contentText: AppConfig.lang == 'kor' ? '쿠폰을 사용하셨나요?' : 'Did you use this coupon?',
                                  confirmText:  AppConfig.lang == 'kor' ? '사용완료' : 'Yes',
                                  rejectText:  AppConfig.lang == 'kor' ? '취소' : 'No',
                                  onConfirm: () {
                                    context.read<InventoryCubit>().useData(id!);
                                    Navigator.pop(context);
                                });
                              },
                              color: appMainColor,
                              child: Text(
                                AppConfig.lang == 'kor' ? '쿠폰 사용완료' : 'I used coupon',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ));
}

Future<void> _showDetailOfItem(
    BuildContext context, String type, String subtype, int leftCount) async {
  String title = '';
  String description = '';

  if (type == 'item') {
    if (subtype == 'item_addtime') {
      title = AppConfig.lang=='kor' ? '플레이시간 추가' : 'Adding time';
      description = AppConfig.lang=='kor' ? '시간을 추가하여 성공률을 높이세요!' : 'High up success rate adding time';
    } else if(subtype == 'play_coin_gold') {
      title =  AppConfig.lang=='kor' ? '플레이 코인 골드' : 'Play Coin Gold';
      description =  AppConfig.lang=='kor' ? '골드 코인으로 다양한 방에 접속하세요!' : 'Join rooms using Gold Coin';
    } else if(subtype == 'play_coin_purple'){
      title =  AppConfig.lang=='kor' ? '플레이 코인 퍼플' : 'Play Coin Purple';
      description =  AppConfig.lang=='kor' ? '퍼플 코인으로 다양한 방에 접속하세요!' : 'Join rooms using Purple Coin';
    }
  } else {

    description = (AppConfig.lang =='kor' ?  AppConfig.stageNameMappingKorean[subtype] : AppConfig.stageNameMappingEnglish[subtype])! ;
    if (subtype == 'forest') {
      title = AppConfig.lang=='kor' ? '사과'  : 'apple';
    } else if (subtype == 'desert') {
      title = AppConfig.lang=='kor' ? '사막'  : 'desert';
    } else if (subtype == 'mine') {
      title = AppConfig.lang=='kor' ? '광물'  : 'mine';
    } else if (subtype == 'sea') {
      title = AppConfig.lang=='kor' ? '소라'  : 'conch';
    } else {
      title = AppConfig.lang=='kor' ?  '다이아' : 'dia';
    }
  }



  showDialog(
      context: context,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 260,
                height: 300,
                color: Colors.transparent,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 12),
                        width: double.infinity,
                        color: Colors.grey.shade200.withOpacity(0.94),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.file(
                                      File(
                                          '${AppConfig.appDocDirectory!.path}/osgame/screen/inventory/item_inven_box.png'),
                                      width: 120,
                                    ),
                                    if (type == 'item')
                                      Image.file(
                                        File(
                                            '${AppConfig.appDocDirectory!.path}/osgame/icons/$subtype.gif'),
                                        width: 80,
                                      )
                                    else
                                      Image.file(
                                        File(
                                            '${AppConfig.appDocDirectory!.path}/osgame/icons/prize_$subtype.png'),
                                        width: 110,
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: title.toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)
                                            ),
                                            TextSpan(
                                                text: ': $leftCount ${AppConfig.lang=='kor'? '개' : ''}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple
                                                )
                                            ),
                                            AppConfig.lang=='kor' ? TextSpan(text: ' 보유 중') : TextSpan(text: ''),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: type == 'item' ? 10 : 0),
                                        child: Text(
                                          type == 'item'
                                              ? description.toString()
                                              : '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      if (type == 'item')
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: type == 'item'
                                                      ? AppConfig.lang=='kor' ? '상점' : 'You can buy it in the Shop'
                                                      : '',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color:
                                                          Colors.deepPurple)),
                                              TextSpan(
                                                  text: type == 'item'
                                                      ? AppConfig.lang=='kor' ? '에서 구매 할 수 있습니다.' : ''
                                                      : ''),
                                            ],
                                          ),
                                        )
                                      else
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: AppConfig.lang=='kor' ? description : 'You can get in $description',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color:
                                                          Colors.deepPurple)),
                                              TextSpan(
                                                  text: AppConfig.lang=='kor'?'에서 획득 가능합니다.' : ''),
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 37,
                                  child: RaisedButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    color: appMainColor,
                                    child:  Text(
                                      AppConfig.lang=='kor' ? '확인' : 'Confirm',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
}
