import 'dart:async';
import 'dart:io';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/music/effect_music_player.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/repository/authentication/shop_repository.dart';
import 'package:catchchanceio/screen/inventory/inventory_screen.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:catchchanceio/widgets/buttons/gesture_detector_with_effect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:page_transition/page_transition.dart';
import 'cubit/exchange_cubit.dart';

class ExchangeScreen extends StatelessWidget {
  final String myId;
  final String productName;

  const ExchangeScreen(this.myId, {this.productName = ""});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return BlocProvider(
      create: (_) => ExchangeCubit(ShopRepository(), myId),
      child: _ExchangeScreen(productName: productName),
    );
  }
}

class _ExchangeScreen extends StatefulWidget {
  final String productName;

  const _ExchangeScreen({ required this.productName}) : super();
  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<_ExchangeScreen>
    with TickerProviderStateMixin {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/exchange/';
  String _currentOrder = 'hot';
  int _currentTabIndex = 0;
  late String searchText;
  bool isLoading = false;

  late TabController _tabController;
  BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();
  EffectMusicPlayer effectMusicPlayer = EffectMusicPlayer();
  Map<String, dynamic> _maxLimit = {};

  Map<int, String> tabName = {0: '편의점 / 마트', 1: '카페', 2: '도서', 3: '게임 / 이모티콘'};




  void goTabByIndex(int index){
    setState(() {
      _currentTabIndex = index;
      _tabController
          .animateTo(_currentTabIndex);
      context
          .read<ExchangeCubit>()
          .changeScreen(
          sortType: _currentTabIndex ==
              0
              ? SortType.MART
              : _currentTabIndex == 1
              ? SortType.CAFE
              : _currentTabIndex ==
              2
              ? SortType.BOOK
              : SortType.EMO);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    backgroundMusicPlayer.playLoop('a_exchange');
    if(widget.productName.isNotEmpty){
      searchCommend();
    }
  }

  Future<void> searchCommend()async{
    await Future.delayed(const Duration(milliseconds: 500));
    context
        .read<ExchangeCubit>()
        .search(widget.productName);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  String _currentSearchWord = '';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    SystemChrome.setEnabledSystemUIOverlays([]);


    return LoadingOverlay(
      isLoading: isLoading,
      color: Colors.black,
      progressIndicator: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(appMainColor),
      ),
      child: Scaffold(
        // resizeToAvoidBottomPadding:false,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              DefaultTabController(
                length: 4,
                child: ScrollConfiguration(
                  behavior: NoGlowScrollBehavior(),
                  child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        MartTab(),
                        CafeTab(),
                        BookstoreTab(),
                        OtherTab()
                      ]),
                ),
              ),
              //todo  navigation button group
              Positioned(
                  top: (MediaQuery.of(context).size.height * 0.1)+20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(File('${_imagePath}btns/nav_frame.png'),width:96,),
                      Column(
                        children: [
                          const SizedBox(height: 20,),
                          GestureDetector(
                            onTap: (){
                              effectMusicPlayer.playOnce('click_main_ui');
                              goTabByIndex(0);
                            },
                            child: IndexedStack(
                              index: _currentTabIndex==0 ? 1 : 0,
                              children: [
                                Image.file(File('${_imagePath}btns/nav_mart_off.png'),width: 86,),
                                Image.file(File('${_imagePath}btns/nav_mart_on.png'),width: 86,),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2,),
                          GestureDetector(
                            onTap: (){
                              effectMusicPlayer.playOnce('click_main_ui');
                              goTabByIndex(1);
                            },
                            child: IndexedStack(
                              index: _currentTabIndex==1 ? 1 : 0,
                              children: [
                                Image.file(File('${_imagePath}btns/nav_cafe_off.png'),width: 86,),
                                Image.file(File('${_imagePath}btns/nav_cafe_on.png'),width: 86,),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2,),
                          GestureDetector(
                            onTap: (){
                              effectMusicPlayer.playOnce('click_main_ui');
                              goTabByIndex(2);
                            },
                            child: IndexedStack(
                              index: _currentTabIndex==2 ? 1 : 0,
                              children: [
                                Image.file(File('${_imagePath}btns/nav_book_off.png'),width: 86,),
                                Image.file(File('${_imagePath}btns/nav_book_on.png'),width: 86,),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2,),
                          GestureDetector(
                            onTap: (){
                              effectMusicPlayer.playOnce('click_main_ui');
                              goTabByIndex(3);
                            },
                            child: IndexedStack(
                              index: _currentTabIndex==3 ? 1 : 0,
                              children: [
                                Image.file(File('${_imagePath}btns/nav_game_off.png'),width: 86,),
                                Image.file(File('${_imagePath}btns/nav_game_on.png'),width: 86,),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2,),
                        ],
                      )
                    ],
                  )
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: sw,
                  height: sh * 0.52,
                  color: const Color(0xff363636),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.file(
                            File('$_imagePath/header.png'),
                            width: sw,
                            fit: BoxFit.contain,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: sw * 0.01,
                                right: sw * 0.01,
                                top: sw * 0.015),
                            width: sw,
                            height: sw * 0.1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_currentTabIndex != 0) {
                                        _currentTabIndex--;
                                        _tabController
                                            .animateTo(_currentTabIndex);
                                        context
                                            .read<ExchangeCubit>()
                                            .changeScreen(
                                                sortType: _currentTabIndex == 0
                                                    ? SortType.MART
                                                    : _currentTabIndex == 1
                                                        ? SortType.CAFE
                                                        : _currentTabIndex == 2
                                                            ? SortType.BOOK
                                                            : SortType.EMO);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: sw * 0.18,
                                    height: sw * 0.1,
                                    color: Colors.transparent,
                                  ),
                                ),
                                Container(
                                  width: sw * 0.5,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: appMainColor, width: 2))),
                                  child: GestureDetector(
                                      onTap: () {
                                        showSelectTabWindow(context,
                                            (int index) {
                                          setState(() {
                                            _currentTabIndex = index;
                                            _tabController
                                                .animateTo(_currentTabIndex);
                                            context
                                                .read<ExchangeCubit>()
                                                .changeScreen(
                                                    sortType: _currentTabIndex ==
                                                            0
                                                        ? SortType.MART
                                                        : _currentTabIndex == 1
                                                            ? SortType.CAFE
                                                            : _currentTabIndex ==
                                                                    2
                                                                ? SortType.BOOK
                                                                : SortType.EMO);
                                          });
                                        });
                                      },
                                      child: Center(
                                          child: Text(
                                        tabName[_currentTabIndex].toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: sw * 0.05),
                                      ))),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_currentTabIndex != 3) {
                                        _currentTabIndex++;
                                        _tabController
                                            .animateTo(_currentTabIndex);
                                        context
                                            .read<ExchangeCubit>()
                                            .changeScreen(
                                                sortType: _currentTabIndex == 0
                                                    ? SortType.MART
                                                    : _currentTabIndex == 1
                                                        ? SortType.CAFE
                                                        : _currentTabIndex == 2
                                                            ? SortType.BOOK
                                                            : SortType.EMO);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: sw * 0.18,
                                    height: sw * 0.1,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      BlocBuilder<AuthenticationBloc, AuthenticationState>(
                        buildWhen: (p, c) => p.user != c.user,
                        builder: (context, state) {
                          _maxLimit = state.user.uRewards;
                          return SizedBox(
                            width: sw,
                            child: Row(
                              children: [
                                SetOrderButton(
                                  text: '인기순',
                                  isActive: _currentOrder == 'hot',
                                  onPressed: () {
                                    setState(() {
                                      _currentOrder = 'hot';
                                      _currentSearchWord = "";
                                    });
                                    context
                                        .read<ExchangeCubit>()
                                        .changeScreen(sort: Sort.POPULAR);
                                  },
                                ),
                                // SetOrderButton(
                                //   text: '낮은 가격',
                                //   isActive: _currentOrder=='low' ? true : false,
                                //   onPressed: (){
                                //     setState(() {
                                //       _currentOrder='low';
                                //       _currentSearchWord = "";
                                //     });
                                //     context.read<ExchangeCubit>().changeScreen(sort: Sort.LOW);
                                //   },
                                // ),
                                // SetOrderButton(
                                //   text: '높은 가격',
                                //   isActive: _currentOrder=='high' ? true : false,
                                //   onPressed: (){
                                //     setState(() {
                                //       _currentOrder='high';
                                //       _currentSearchWord = "";
                                //     });
                                //     context.read<ExchangeCubit>().changeScreen(sort: Sort.HIGH);
                                //   },
                                // ),

                                SetOrderButton(
                                  text: '브랜드',
                                  isActive: _currentOrder == 'brand',
                                  onPressed: () {
                                    setState(() {
                                      _currentOrder = 'brand';
                                      _currentSearchWord = "";
                                    });
                                    context
                                        .read<ExchangeCubit>()
                                        .changeScreen(sort: Sort.BRAND);
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showSearchDialog(context,
                                          submit: (String value) {
                                        setState(() {
                                          _currentSearchWord = value;
                                        });
                                        if (value.toString().isNotEmpty) {
                                          context
                                              .read<ExchangeCubit>()
                                              .search(value.toString());
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: 25,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(color: Colors.grey)),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                              ),
                                              width: sw * 0.25,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    _currentSearchWord,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ))
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  //context.read<ExchangeCubit>().search(searchText);
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  SystemChrome
                                                      .setEnabledSystemUIOverlays(
                                                          []
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.search,
                                                  size: 15,
                                                  color: Colors.grey,
                                                )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                )),
                              ],
                            ),
                          );
                        },
                      ),
                      BlocBuilder<ExchangeCubit, ExchangeState>(
                        builder: (context, state) {
                          return Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 4, left: 8, right: 8, bottom: 2),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: state.current
                                          .map(
                                            (e) => OneProductBox(
                                              productUrl:
                                                  e['img_url_s'].toString(),
                                              price: e['price']
                                                  as Map<String, dynamic>,
                                              title: e['brand_name'].toString(),
                                              content: e['title'].toString(),
                                              id: e['id'].toString(),
                                              itemPressed: () {
                                                showDetailOfProduct(context,
                                                    url: e['img_url_s']
                                                        .toString(),
                                                    title:
                                                        e['title'].toString(),
                                                    content: e['brand_name']
                                                        .toString(),
                                                    price: e['price']
                                                        as Map<String, dynamic>,
                                                    userRewards: _maxLimit,
                                                    id: e['id'].toString(),
                                                    exchangeCoupon: () {
                                                  showConfirmBuying(context,
                                                      title:
                                                          e['title'].toString(),
                                                      content: e['brand_name']
                                                          .toString(),
                                                      price: e['price'] as Map<
                                                          String, dynamic>,
                                                      id: e['id'].toString(),
                                                      uId: state.myId,
                                                      loading: (bool loading) =>
                                                          setState(() =>
                                                              isLoading =
                                                                  loading),
                                                      isGotoInvent: () async {
                                                        await Navigator.push(
                                                            context,
                                                            PageTransition(
                                                                type:
                                                                    PageTransitionType
                                                                        .fade,
                                                                child: InventoryScreen(
                                                                    state
                                                                        .myId)));
                                                        backgroundMusicPlayer
                                                            .playLoop(
                                                                'a_exchange');
                                                      });
                                                });
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  )));
                        },
                      )
                    ],
                  ),
                ),
              ),
              //todo appbar
              ScreenAppBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class MartTab extends StatefulWidget {
  @override
  _MartTabState createState() => _MartTabState();
}

class _MartTabState extends State<MartTab> with TickerProviderStateMixin {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/exchange/mart/';
  final String _crImagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/character2/';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Container(
      width: sw,
      height: sh,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: FileImage(File('${_imagePath}bg.png')),
              fit: BoxFit.cover)),
      child: Stack(
        children: [
          Positioned(
              bottom: sh * 0.40,
              right: 0,
              child: Image.file(
                File('${_crImagePath}mart_npc.gif'),
                fit: BoxFit.contain,
                height: sh * 0.5,
              )),
          Positioned(
              bottom: sh * 0.52,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.file(
                    File('${_imagePath}o.gif'),
                    width: sw,
                  )
                ],
              )),
        ],
      ),
    );
  }
}

class CafeTab extends StatefulWidget {
  @override
  _CafeTabState createState() => _CafeTabState();
}

class _CafeTabState extends State<CafeTab> with TickerProviderStateMixin {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/exchange/cafe/';
  final String _crImagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/character2/';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Container(
      width: sw,
      height: sh,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: FileImage(File('${_imagePath}bg.png')),
              fit: BoxFit.cover)),
      child: Stack(
        children: [
          Positioned(
              bottom: sh * 0.42,
              right: 0,
              child: Image.file(
                File('${_crImagePath}cafe_npc.gif'),
                fit: BoxFit.contain,
                height: sh * 0.48,
              )),
          Positioned(
              bottom: sh * 0.52,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.file(
                    File('${_imagePath}o.gif'),
                    width: sw,
                  )
                ],
              )),
        ],
      ),
    );
  }
}

class BookstoreTab extends StatefulWidget {
  @override
  _BookstoreTabState createState() => _BookstoreTabState();
}

class _BookstoreTabState extends State<BookstoreTab>
    with TickerProviderStateMixin {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/exchange/bookstore/';
  final String _crImagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/character2/';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Container(
      width: sw,
      height: sh,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: FileImage(File('${_imagePath}bg.png')),
              fit: BoxFit.cover)),
      child: Stack(
        children: [
          Positioned(
              bottom: sh * 0.315,
              right: 0,
              child: Image.file(
                File('${_crImagePath}bookstore_npc.gif'),
                fit: BoxFit.contain,
                height: sh * 0.58,
              )),

          Positioned(
              bottom: sh * 0.52,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.file(
                    File('${_imagePath}o.gif'),
                    width: sw,
                  )
                ],
              )),

          // Positioned(
          //   bottom: sw*1.1,
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       GifImage(
          //         controller: o1c,
          //         image: AssetImage('./assets/res/bookstore_o.gif'),
          //         fit: BoxFit.contain,
          //         width: sw,
          //       ),
          //
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}

class OtherTab extends StatefulWidget {
  @override
  _OtherTabState createState() => _OtherTabState();
}

class _OtherTabState extends State<OtherTab> with TickerProviderStateMixin {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/exchange/other/';
  final String _crImagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/character2/';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Container(
      width: sw,
      height: sh,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: FileImage(File('${_imagePath}bg.png')),
              fit: BoxFit.cover)),
      child: Stack(
        children: [
          Positioned(
              bottom: sh * 0.395,
              right: 0,
              child: Image.file(
                File('${_crImagePath}other_npc.gif'),
                fit: BoxFit.contain,
                height: sh * 0.48,
              )),

          Positioned(
              bottom: sh * 0.52,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.file(
                    File('${_imagePath}o.gif'),
                    width: sw,
                  )
                ],
              )),
        ],
      ),
    );
  }
}

void showSelectTabWindow(BuildContext context, Function onTap) {
  const TextStyle _ts = TextStyle(
      color: Color(0xff363636), fontWeight: FontWeight.bold, fontSize: 17);
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
            child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: 220,
                      height: 300,
                      decoration: BoxDecoration(
                          color: appMainColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetectorWithEffect(
                            onTap: () {
                              onTap(0);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black12, width: 2))),
                              child: const Center(
                                  child: Text(
                                '편의점 / 마트',
                                style: _ts,
                              )),
                            ),
                          ),
                          GestureDetectorWithEffect(
                            onTap: () {
                              onTap(1);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black12, width: 2))),
                              child: const Center(
                                  child: Text(
                                '카페',
                                style: _ts,
                              )),
                            ),
                          ),
                          GestureDetectorWithEffect(
                            onTap: () {
                              onTap(2);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black12, width: 2))),
                              child: const Center(
                                  child: Text(
                                '도서',
                                style: _ts,
                              )),
                            ),
                          ),
                          GestureDetectorWithEffect(
                            onTap: () {
                              onTap(3);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(10),
                              child: const Center(
                                  child: Text(
                                '게임 / 이모티콘',
                                style: _ts,
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                          icon: const Icon(Icons.cancel),
                          iconSize: 30,
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ],
                )),
          ));
}




void showDetailOfProduct(BuildContext context,{required String url,
  required String title,
  required String content,
  required Map<String, dynamic> price,
  required String id,
  required Map<String, dynamic> userRewards,
  required Function exchangeCoupon}){

  final Map<String, int> rewards = {};
  price.forEach((key, value) {
    rewards[key] = userRewards[key] as int;
  });
  final _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/screen/exchange';
  showDialog(
      context: context,
      builder: (_)=> Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.only(top:10,left: 12,right:12,bottom: 5),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(File('$_imagePath/frame1.png')),
                    fit: BoxFit.cover
                )
            ),
            width: 275,
            height: 275*(1488/706),
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
                        }
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.grey, width: 0.9),
                      image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover)
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top:12,bottom: 20),
                    width: 250,
                    child: Center(child: Text(title,style: const TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,))
                ),
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
                      const Text('내 보유수량 / 필요수량',style: TextStyle(color:Colors.white,fontSize:13,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 15,),
                      Expanded(
                        child:SingleChildScrollView(
                          child: Column(
                            children: rewards.entries.map((e) {
                              return _buildOnePrizeList(rewardEvent: e, priceEvent: price[e.key] as int);
                            }).toList(),
                          ),
                        )
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15,),
                CustomButton(
                  pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_d.png',
                  defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_e.png',
                  text:const  Text('교환하기',style: TextStyle(color: Colors.black87,fontSize:17,fontWeight:FontWeight.bold),),
                  onPressed: (){
                    Navigator.pop(context);
                    price.forEach((key, value) {
                      if (rewards[key]! >= (value as num) &&
                          value != null) {
                        rewards.remove(key);
                      }
                    });
                    if (rewards.isEmpty) {
                      exchangeCoupon();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Not enough rewards",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          backgroundColor:
                          Colors.black.withOpacity(0.7),
                          textColor: Colors.white,
                          fontSize: 15.0);
                    }
                  },
                  width: 130,
                )

              ],
            ),
          ),
        ),
      )
  );
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



void showConfirmBuying(BuildContext context,
    {required String title,
    required String content,
    required Map<String, dynamic> price,
    required String id,
    required String uId,
    required Function loading,
    required Function isGotoInvent}) {
  showDialog(
      context: context,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(

                padding: const EdgeInsets.only(
                    top: 8, left: 12, right: 12, bottom: 10),
                width: 270,
                height: 270*(1022/808),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                        image: FileImage(File('${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/round_frame.png')),
                        fit: BoxFit.contain
                    )
                ),

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
                          width: 24,
                        )
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      content,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      '이 상품으로 교환을 하시겠습니까?',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const Text(
                      '교환한 상품은 보관함에서 사용가능합니다.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: price.entries
                          .map(
                            (e) => Row(
                              children: [
                                Image.file(
                                  File(
                                      '${AppConfig.appDocDirectory!.path}/osgame/icons/prize_${AppConfig.stageMapping[e.key]}.png'),
                                  width: 35,
                                ),
                                Text(
                                  'x${e.value}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                     ),
                    ),
                    const SizedBox(
                      height: 34,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        CustomButton(
                          pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_d.png',
                          defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_e.png',
                          text:const  Text('확인',style: TextStyle(color: Colors.black87,fontSize:17,fontWeight:FontWeight.bold),),
                          onPressed: () async{
                            Navigator.pop(context);
                            //todo buy Coupon
                            loading(true);
                            final ItemPayResult result = await context
                                .read<ExchangeCubit>()
                                .buyCoupon(id);
                            loading(false);
                            if (result == ItemPayResult.NOT_ENOUGH) {
                              Fluttertoast.showToast(
                                  msg: "보유한 보상이 부족합니다",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor:
                                  Colors.black.withOpacity(0.7),
                                  textColor: Colors.white,
                                  fontSize: 15.0);
                            } else if (result == ItemPayResult.FAIL) {
                              Fluttertoast.showToast(
                                  msg: "네트워크 문제 발생",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor:
                                  Colors.black.withOpacity(0.7),
                                  textColor: Colors.white,
                                  fontSize: 15.0);
                            } else {
                              showRecipeOfProduct(context, () {
                                isGotoInvent();
                              });
                            }
                          },
                          width: 110,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ));
}

void showRecipeOfProduct(BuildContext context, Function isGotoInvent) {
  showDialog(
      context: context,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.only(
                    top: 8, left: 12, right: 12, bottom: 10),
                width: 270,
                height: 270*(1022/808),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                        image: FileImage(File('${AppConfig.appDocDirectory!.path}/osgame/screen/dialog/round_frame.png')),
                        fit: BoxFit.contain
                    )
                ),
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
                          width: 24,
                        )
                      ],
                    ),
                    const SizedBox(height: 30,),
                    Image.file(File('${AppConfig.appDocDirectory!.path}/osgame/screen/exchange/sd1.gif'),width: 120,),
                    const SizedBox(height: 8,),
                    const Text(
                      '상품 교환 완료!',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const Text(
                      '보관함에서 상품을 확인하세요.',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        CustomButton(
                          pressedImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_d.png',
                          defaultImageFilePath: '${AppConfig.appDocDirectory!.path}/osgame/screen/main/etc/btn1_e.png',
                          text: const Text(
                            '보관함으로',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          onPressed: (){
                            Navigator.pop(context);
                            isGotoInvent();
                          },
                          width: 117,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ));
}

class OneProductBox extends StatelessWidget {
  final String productUrl;
  final String title;
  final String content;
  final Map<String, dynamic> price;
  final String id;

  final Function itemPressed;

  OneProductBox({
    required this.productUrl,
    required this.title,
    required this.content,
    required this.price,
    required this.id,

    required this.itemPressed,
  });

  final String _imagePath = '${AppConfig.appDocDirectory!.path}/osgame/icons/';

  @override
  Widget build(BuildContext context) {
    return GestureDetectorWithEffect(
      onTap: () => itemPressed(),
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
                child: Image.network(
                  productUrl,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
            ),
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
                              text: title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.5)),
                          const TextSpan(text: '  '),
                          TextSpan(
                              text: content,
                              style: const TextStyle(fontSize: 14.5)
                          ),
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
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

class SetOrderButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool isActive;

  const SetOrderButton({required this.onPressed, required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: SizedBox(
        width: 55,
        height: 20,
        child: RaisedButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            onPressed();
          },
          color: isActive ? appMainColor : Colors.grey.shade400,
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

void showSearchDialog(BuildContext context,
    {required Function submit}) {
  var textName = "";
  showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.23,
                  ),
                  Container(
                    width: 300,
                    height: 220,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '상품 검색',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.black54),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          width: 220,
                          height: 50,
                          child: Center(
                            child: TextField(
                              onChanged: (text) {
                                textName = text;
                              },
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                              controller: TextEditingController(),
                              cursorColor: Colors.black,
                              autofocus: true,
                              decoration: InputDecoration(
                                isDense: true,
                                fillColor: Colors.grey.shade300,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ButtonTheme(
                              minWidth: 100,
                              child: RaisedButton(
                                onPressed: () {
                                  textName;
                                  submit(textName);
                                  Navigator.pop(context);
                                },
                                color: appMainColor,
                                child: const Text(
                                  '검색하기',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            ButtonTheme(
                              minWidth: 100,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                color: Colors.black54,
                                child: const Text(
                                  '취소',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )).then((value) {
    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIOverlays([]);
  });
}
