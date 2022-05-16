import 'dart:io';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/repository/authentication/shop_repository.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:catchchanceio/widgets/buttons/gesture_detector_with_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:video_player/video_player.dart';

import 'cubit/shop_cubit.dart';

class ShopScreen extends StatelessWidget {
  final String myId;

  const ShopScreen(this.myId);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShopCubit(ShopRepository(), myId),
      child: _ShopScreen(),
    );
  }
}

class _ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<_ShopScreen> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/shop/';

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
  Map<String, dynamic> _maxLimit = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (mounted) {
      _videoController = VideoPlayerController.file(
          File('${AppConfig.appDocDirectory!.path}/osgame/screen/shop/bg.mp4'));
      _initializeVideoPlayerFuture = _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.play();
    }
    backgroundMusicPlayer.playLoop('a_shop');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoController.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return BlocListener<ShopCubit, ShopState>(
      listenWhen: (p, c) {
        if (p.resultToast != c.resultToast && c.resultToast.isNotEmpty) {
          Fluttertoast.showToast(
              msg: c.resultToast,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.black.withOpacity(0.7),
              textColor: Colors.white,
              fontSize: 15.0);
        }
        return true;
      },
      listener: (context, state) {},
      child: Scaffold(
        body: LoadingOverlay(
          color: Colors.black,
          progressIndicator: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(appMainColor),
          ),
          isLoading: _isLoading,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(File('${_imagePath}bg.png')),
                    fit: BoxFit.cover)),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                //todo background...
                _buildBackgroundVideo(),

                Positioned(
                    bottom: sh * 0.36,
                    right: 0,
                    child: Image.file(
                      File('${_imagePath}shop_npc.gif'),
                      height: sh * 0.54,
                    )),

                Positioned(
                  bottom: 0,
                  child: Container(
                      padding: EdgeInsets.only(
                          top: sw * 0.045,
                          left: sw * 0.022,
                          right: sw * 0.022,
                          bottom: 3),
                      width: sw,
                      height: sw * 1.01,
                      color: const Color(0xff363636),
                      child: BlocBuilder<ShopCubit, ShopState>(
                          builder: (context, state) {
                        if (state.items.isNotEmpty) {
                          return BlocBuilder<AuthenticationBloc, AuthenticationState>(
                            buildWhen: (p, c) => p.user != c.user,
                            builder: (context, stateUser){
                              _maxLimit = stateUser.user.uRewards;
                              return ScrollConfiguration(
                                behavior: NoGlowScrollBehavior(),
                                child: Column(
                                  children: state.items
                                      .map(
                                        (e) => OneProductBox(
                                      price: e['price'] as Map<String,dynamic>,
                                      itemType: e['type'].toString(),
                                      itemName: e['title'].toString(),
                                      content: e['f_desc'].toString(),
                                      imageUrl: e['img_url'].toString(),
                                      userRewards: _maxLimit,
                                      buy: (int count) async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await context
                                            .read<ShopCubit>()
                                            .buyItem(e['id'].toString(), count);
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                    ),
                                  ).toList(),
                                ),
                              );
                            },
                          );

                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      })),
                ),

                Positioned(
                    bottom: sw * 0.93,
                    child: Image.file(
                      File('${_imagePath}line.gif'),
                      width: sw,
                    )),

                //todo appbar
                ScreenAppBar(),
              ],
            ),
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

// class OneShopBox extends StatelessWidget {
//   final String itemType;
//   final int coinPrice;
//   final String itemName;
//   final String content;
//   final Function buy;
//   final String imageUrl;
//
//   OneShopBox({
//     this.coinPrice,
//     this.itemType,
//     this.itemName,
//     this.content,
//     this.buy,
//     this.imageUrl
//   });
//
//   final String _imagePath1 = '${AppConfig.appDocDirectory!.path}/osgame/screen/shop/';
//   final String _imagePath2 = '${AppConfig.appDocDirectory!.path}/osgame/icons/';
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     return GestureDetectorWithEffect(
//       onTap: (){
//         showDetailOfItem(context,
//             imageUrl: imageUrl,
//             itemType: itemType,
//             coinPrice: coinPrice,
//             content:content,
//             title: itemName,
//             buy: (int count){
//               buy(count);
//             });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           image: DecorationImage(
//             image: FileImage(File('${_imagePath1}small_product_box.png'))
//           )
//         ),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Positioned(
//                 top:sw*0.017,
//                 child: ClipRRect(
//                     borderRadius: BorderRadius.circular(sw*0.03),
//                     // child: Image.network(imageUrl,width: sw*0.24,)
//                     child: Image.file(File('${AppConfig.appDocDirectory!.path}${'/osgame/icons/item_$itemType.png'}'),width: sw*0.24,)
//                 )
//             ),
//             Positioned(
//                 left:3,
//                 top:sw*0.31,
//                 child:Text(itemName,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: sw*0.032),)
//             ),
//             Positioned(
//               bottom: sw*0.0000,
//               left: sw*0.15,
//               child: Row(
//                 children: [
//                   Image.file(File('${_imagePath2}play_coin.png'),width: sw*0.035,),
//                   const SizedBox(width: 2,),
//                   Text('$coinPrice개', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: sw*0.036),)
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class OneProductBox extends StatelessWidget {
  final String itemType;
  final Map<String, dynamic> price;
  final String itemName;
  final String content;
  final Function buy;
  final String imageUrl;
  final Map<String, dynamic> userRewards;

  OneProductBox(
      {required this.itemType,
      required this.price,
      required this.itemName,
      required this.content,
      required this.buy,
      required this.imageUrl,
      required this.userRewards
      });

  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/icons/';

  @override
  Widget build(BuildContext context) {
    price.removeWhere((key, value) => value == 0);
    return GestureDetectorWithEffect(
      onTap: () => showDetailOfItem(context,
          imageUrl: imageUrl,
          price: price,
          itemType: itemType,
          content: content,
          userRewards: userRewards,
          title: itemName, buy: (int count) {
        buy(count);
      }),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(4),
        width: double.infinity,
        height: 80,
        color: const Color(0xffc4c4c4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File('$_imagePath/$itemType.gif'),
                )),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: '$itemName\n',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.5)),
                          const TextSpan(text: ''),
                          TextSpan(
                              text: content,
                              style: const TextStyle(fontSize: 12.2)),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 3,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          // children: price.entries.map((key, value) => ).toList(),
                          children: price.entries.map((e) {
                            return Container(
                              margin: const EdgeInsets.only(left: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Image.file(
                                    File(
                                        '${_imagePath}prize_${AppConfig.stageMapping[e.key]}.png'),
                                    width: 35,
                                  ),
                                  const SizedBox(
                                    width: 0,
                                  ),
                                  Text(
                                    'x${e.value}',
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'fpt',
                                        fontStyle: FontStyle.normal),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showDetailOfItem(BuildContext context,
    {required String imageUrl,
    required String itemType,
    required String title,
    required String content,
    required Map<String, dynamic> price,
     int? amount,
    required Map<String, dynamic> userRewards,
    required Function buy}) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: DetailOfItem(
            imageUrl: imageUrl,
            itemType: itemType,
            title: title,
            content: content,
            price: price,
            userRewards: userRewards,
            buy: buy,
          ),
        );
      });
}

class DetailOfItem extends HookWidget {
  final String imageUrl;
  final String itemType;
  final String title;
  final String content;
  final Map<String, dynamic> price;
  final Function buy;
  final Map<String, dynamic> userRewards;

  const DetailOfItem(
      { Key? key,
      required this.imageUrl,
      required this.itemType,
      required this.title,
      required this.content,
      required this.price,
      required this.buy,
      required this.userRewards,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, int> rewards = {};
    price.forEach((key, value) {
      rewards[key] = userRewards[key] as int;
    });
    //final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/icons/';
    final count = useState(1);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15 ,horizontal: 12),

      width: 300,
      height: 300*(1708/706),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File('${AppConfig.appDocDirectory!.path}/osgame/screen/shop/frame1_long.png'))
        )
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_e.png',
                  pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/btn_exit_d.png',
                  width: 28,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 15,left: 12,right:12,bottom: 5),
              width: double.infinity,
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 175,
                        height: 175,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey, width: 0.9)
                        ),
                        child: Center(
                            // child: Image.network(imageUrl,width: 192,height: 192,fit: BoxFit.cover,)
                            child: Image.file(
                          File(
                              '${AppConfig.appDocDirectory!.path}${'/osgame/icons/$itemType.png'}'),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Container(
                    width: 250,
                    height:220,
                    padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 15),
                    decoration: BoxDecoration(
                        color: const Color(0xff545454),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                      children: [
                        Text(AppConfig.lang == 'kor' ? '내 보유수량 / 필요수량' : 'Possession / Requirement',style: const TextStyle(color:Colors.white,fontSize:13,fontWeight: FontWeight.bold),),
                        const SizedBox(height: 15,),
                        Expanded(
                            child:Column(
                              children: rewards.entries.map((e) {
                                return _buildOnePrizeList(rewardEvent: e, priceEvent: price[e.key]*count.value as int);
                              }).toList(),
                            )
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          count.value = count.value > 1 ? count.value - 1 : 1;
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(6)
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.remove,
                              size: 28,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // ignore: sized_box_for_whitespace
                      Container(
                        width: 70,
                        child: Center(
                            child: Text(
                          '${count.value}${AppConfig.lang=='kor' ? '개' : ''}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        )),
                      ),
                      GestureDetector(
                        onTap: () {
                          count.value = count.value < 10 ? count.value + 1 : 10;
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 28,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  CustomButton(
                    pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_d.png',
                    defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_e.png',
                    text: Text(AppConfig.lang =='kor' ? '구매하기' : 'Purchase',style: TextStyle(color: Colors.black87,fontSize:17,fontWeight:FontWeight.bold),),
                    onPressed: () {
                      buy(count.value);
                      Navigator.pop(context);
                    },
                    width: 130,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}



Widget _buildOnePrizeList({dynamic rewardEvent, required int priceEvent}){

  var color = Colors.white;
  if(rewardEvent.value as int < priceEvent) color = Colors.red;

  return Container(
    margin:const EdgeInsets.only(top:5),
    width: 220,
    height: 44,
    decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
            bottom: BorderSide(color: Colors.white,width: 2)
        )
    ),
    child: Row(
      children: [
        Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/icons/prize_${AppConfig.stageMapping[rewardEvent.key]}.png'),),
        Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: rewardEvent.value.toString(),
                    style: TextStyle(color: color,fontSize: 21,fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      const TextSpan(text: ' / ', style: TextStyle(color: Colors.white)),
                      TextSpan(text: priceEvent.toString(), style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                )
              ],
            )
        )
      ],
    ),
  );
}
