
import 'dart:io';

import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/repository/authentication/friend_repository.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/repository/authentication/models/user_data.dart';
import 'package:catchchanceio/screen/profile/view_profile.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/dialog/os_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:page_transition/page_transition.dart';
import 'cubit/friend_cubit.dart';

class FriendsScreen extends StatelessWidget {
  final UserData myId;

  const FriendsScreen(this.myId);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendCubit(FriendRepository(), myId),
      child: _FriendsScreenView(),
    );
  }
}

class _FriendsScreenView extends StatefulWidget {
  @override
  _FriendsScreenViewState createState() => _FriendsScreenViewState();
}

class _FriendsScreenViewState extends State<_FriendsScreenView> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/friends/';
  int _currentPageIndex = 0;
  BackgroundMusicPlayer backgroundMusicPlayer = BackgroundMusicPlayer();

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    backgroundMusicPlayer.playLoop('a_friend');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        color: Colors.black,
        progressIndicator: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appMainColor),
        ),
        isLoading: isLoading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xff222038),
              image: DecorationImage(
                  image: FileImage(
                    File('${_imagePath}bg.png'),
                  ),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              ScreenAppBar(),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: Container(
                width: double.infinity,
                color: const Color(0xff2f294f),
                child: Column(
                  children: [
                    HeaderNavTab(
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _currentPageIndex,
                        children: [
                          FPage1(
                            isLoading: (bool loading) {
                              setState(() {
                                isLoading = loading;
                              });
                            },
                          ),
                          FPage2(),
                          FPage3(),
                          FPage4(),
                          FPage5(),
                        ],
                      ),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class FPage1 extends StatelessWidget {
  final Function isLoading;

  const FPage1({required this.isLoading}) : super();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendCubit, FriendState>(
      buildWhen: (prev, curr)=> prev.friends!=curr.friends,
      builder: (context, state) {
        if (state.friends.isNotEmpty) {
          return Container(
            padding:
                const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 3),
            width: double.infinity,
            color: Colors.transparent,
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  children: state.friends
                      .map(
                        (e) => OneFriendList(
                          nickname: e.uName,
                          isOnline: e.uOnline,
                          profileImgUrl: e.uImgSmall,
                          isLoading: (bool loading) {
                            isLoading(loading);
                          },
                          id: e.uId,
                          imgTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child:
                                        ViewProfile(e.uId, state.myData.uId)));
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        } else {
          return Center(
              child: Text(
            AppConfig.lang=='kor' ? "검색 결과가 없습니다." : 'No result',
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ));
        }
      },
    );
  }
}

class FPage2 extends StatelessWidget {
  final gColors = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors1 = [
    const Color(0xff2f294f).withOpacity(0.0),
    const Color(0xffae9dcc).withOpacity(0.6)
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendCubit, FriendState>(
      buildWhen: (prev, curr)=> prev.searches!=curr.searches,
      builder: (context, state) {
        return Container(
          padding:
              const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 3),
          width: double.infinity,
          color: Colors.transparent,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 40,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gColors)),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 5),
                        width: 212,
                        height: 34,
                        color: const Color(0xff2f294f),
                        child: TextField(
                          onChanged: (val) {
                            context.read<FriendCubit>().updateSearchName(val);
                          },
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            isDense: true,
                            fillColor: Colors.grey.shade300,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                            hintText: AppConfig.lang=='kor'? '닉네임 입력' : 'type nickname',
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<FriendCubit>().searchUsers();
                      context.read<FriendCubit>().updateSearchName("");
                      FocusScope.of(context).unfocus();
                      SystemChrome.setEnabledSystemUIOverlays([]);
                    },
                    child: Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gColors1)),
                      child: Center(
                        child: Icon(
                          Icons.search,
                          size: 24,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                  visible: state.searches.isEmpty,
                  child: Text(
                    AppConfig.lang=='kor' ? '검색 결과가 없습니다.':'No result',
                    style:const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  )),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, right: 10, bottom: 3),
                child: ScrollConfiguration(
                  behavior: NoGlowScrollBehavior(),
                  child: SingleChildScrollView(
                    child: Column(
                      children: state.searches
                          .map(
                            (e) => OneFriendListWithBtn(
                              nickname: e.uName,
                              profileImgUrl: e.uImgSmall,
                              id: e.uId,
                              onTapImg: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: ViewProfile(
                                            e.uId, state.myData.uId)));
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ))
            ],
          ),
        );
      },
    );
  }
}

class FPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return BlocBuilder<FriendCubit, FriendState>(
      buildWhen: (prev, curr)=> prev.sends!=curr.sends,
      builder: (context, state) {
        if (state.sends.isNotEmpty) {
          return Container(
            padding:
                const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 3),
            width: double.infinity,
            color: Colors.transparent,
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  children: state.sends
                      .map(
                        (e) => ApplyingFriendList(
                          nickname: e.uName,
                          profileImgUrl: e.uImgSmall,
                          id: e.uId,
                          onTapImg: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child:
                                        ViewProfile(e.uId, state.myData.uId)));
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        } else {
          return Center(
              child: Text(
            AppConfig.lang=='kor' ? '검색 결과가 없습니다.':'No result',
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ));
        }
      },
    );
  }
}

class FPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendCubit, FriendState>(
      buildWhen: (prev, curr)=> prev.receives!=curr.receives,
      builder: (context, state) {
        if (state.receives.isNotEmpty) {
          return Container(
            padding:
                const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 3),
            width: double.infinity,
            color: Colors.transparent,
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  children: state.receives
                      .map(
                        (e) => ReceivingFriendList(
                          nickname: e.uName,
                          profileImgUrl: e.uImgSmall,
                          id: e.uId,
                          onTabImg: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child:
                                        ViewProfile(e.uId, state.myData.uId)));
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        } else {
          return  Center(
              child: Text(
            AppConfig.lang=='kor' ? '검색 결과가 없습니다.':'No result',
            style:const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ));
        }
      },
    );
  }
}

class FPage5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendCubit, FriendState>(
      buildWhen: (prev, curr)=> prev.recommends!=curr.recommends,
      builder: (context, state) {
        if (state.recommends.isNotEmpty) {
          return Container(
            padding:
                const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 3),
            width: double.infinity,
            color: Colors.transparent,
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  children: state.recommends
                      .map(
                        (e) => OneFriendListWithBtn(
                          nickname: e.uName,
                          profileImgUrl: e.uImgSmall,
                          id: e.uId,
                          onTapImg: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child:
                                        ViewProfile(e.uId, state.myData.uId)));
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        } else {
          return Center(
              child: Text(
            AppConfig.lang=='kor' ?'검색결과가 없습니다' : "No result",
            style: const  TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ));
        }
      },
    );
  }
}

class HeaderNavTab extends StatefulWidget {
  final Function onPageChanged;

  const HeaderNavTab({required this.onPageChanged});

  @override
  _HeaderNavTabState createState() => _HeaderNavTabState();
}

class _HeaderNavTabState extends State<HeaderNavTab> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/friends/';
  int _selectedIndex = 0;

  void _changeIndex(int index) {
    widget.onPageChanged(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: sw,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              child: Image.file(
            File('${_imagePath}h_frame.png'),
            width: sw,
          )),
          Positioned(
              left: 0,
              child: OneHeaderTabBtn(
                text: AppConfig.lang=='kor'? '내친구' : 'Friends',
                index: 0,
                isSelected: _selectedIndex == 0,
                width: (sw / 5) * 0.97,
                onPressed: () => _changeIndex(0),
              )),
          Positioned(
              left: sw * 0.17,
              child: OneHeaderTabBtn(
                text: AppConfig.lang=='kor'? '친구찾기' : 'Search',
                index: 1,
                isSelected: _selectedIndex == 1,
                width: (sw / 5) * 1.15,
                onPressed: () => _changeIndex(1),
              )),
          Positioned(
              left: sw * 0.374,
              child: OneHeaderTabBtn(
                text: AppConfig.lang=='kor'? '보낸신청' : 'Send',
                index: 2,
                isSelected: _selectedIndex == 2,
                width: (sw / 5) * 1.15,
                onPressed: () => _changeIndex(2),
              )),
          Positioned(
              left: sw * 0.575,
              child: OneHeaderTabBtn(
                text: AppConfig.lang=='kor'? '받은신청' : 'Received',
                index: 3,
                isSelected: _selectedIndex == 3,
                width: (sw / 5) * 1.15,
                onPressed: () => _changeIndex(3),
              )),
          Positioned(
              right: 0,
              child: OneHeaderTabBtn(
                text: AppConfig.lang=='kor'? '추천친구' : 'Recommend',
                index: 4,
                isSelected: _selectedIndex == 4,
                width: (sw / 5) * 1.12,
                onPressed: () => _changeIndex(4),
              )),
        ],
      ),
    );
  }
}

class OneHeaderTabBtn extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/friends/';
  final int index;
  final String text;
  final bool isSelected;
  final double width;
  final Function onPressed;

  OneHeaderTabBtn(
      {required this.text, required this.index, required this.isSelected, required this.width, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isSelected ? 1.0 : 0.0,
            child: Image.file(
                File(index == 0
                    ? '${_imagePath}h_nav1.png'
                    : index > 0 && index < 4
                        ? '${_imagePath}h_nav2.png'
                        : '${_imagePath}h_nav3.png'),
                width: width),
          ),
          Text(
            text,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 12.2),
          )
        ],
      ),
    );
  }
}

class OneFriendList extends StatelessWidget {
  final String profileImgUrl;
  final String nickname;
  final bool isOnline;
  final String id;
  final Function imgTap;
  final Function isLoading;

  OneFriendList(
      {required this.isOnline,
      required this.nickname,
      required this.profileImgUrl,
      required this.id,
      required this.imgTap,
      required this.isLoading});

  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/friends/';
  final gColors = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors2 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors3 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final double listHeight = 56;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: sw,
      height: listHeight,
      child: Row(
        children: [
          Container(
            width: listHeight,
            height: listHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gColors2,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                imgTap();
              },
              child: Center(
                child: Image.network(
                  profileImgUrl,
                  width: listHeight - 8,
                  height: listHeight - 8,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
                    return Image.asset('assets/images/icons/friends.png');
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(),
              height: listHeight,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(),
                gradient: LinearGradient(
                  colors: gColors,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: 3,
                    decoration:
                        BoxDecoration(gradient: LinearGradient(colors: gColors3)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              nickname,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              isOnline ? 'online' : '',
                              style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            BlocBuilder<FriendCubit, FriendState>(
                              buildWhen: (prev, curr)=> prev.listItems!=curr.listItems,
                              builder: (contexts, state) {
                                return GestureDetector(
                                    onTap: () {
                                      showGiftDialog(
                                          contexts: context,
                                          nickname: nickname,
                                          profileImgUrl: profileImgUrl,
                                          data: state.listItems,
                                          id: id,
                                          sendGift: () async {
                                            isLoading(true);
                                            final result = await context
                                                .read<FriendCubit>()
                                                .giveCoupon(id);
                                            isLoading(false);
                                            Fluttertoast.showToast(
                                                msg: result
                                                    ? AppConfig.lang=='kor' ? '$nickname 에게 아이템을 보냈습니다.' : 'The item has been sent to $nickname'
                                                    : AppConfig.lang=='kor' ? '전송 실패.' : 'Failed to send',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor:
                                                    Colors.black.withOpacity(0.7),
                                                textColor: Colors.white,
                                                fontSize: 15.0
                                            );
                                          },
                                          setSelected: () {
                                            context
                                                .read<FriendCubit>()
                                                .resetSelected();
                                          },
                                          selectItem:
                                              (String id, bool isSelected) {
                                            context
                                                .read<FriendCubit>()
                                                .selectItem(id, isSelected);
                                          });
                                    },
                                    child: Image.file(
                                      File('${_imagePath}btn_gift.png'),
                                      width: 20,
                                    ));
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                                onTap: () {
                                  showCustomDialog(
                                    context: context,
                                    contentText: AppConfig.lang=='kor' ? '$nickname 님을 친구삭제 하시겠습니까?' : 'Do you want to delete $nickname?',
                                    rejectText: AppConfig.lang=='kor' ? '취소' : 'No',
                                    confirmText: AppConfig.lang=='kor' ? '확인' : 'Yes',
                                    onConfirm: () {
                                      //todo delete 구문 실행
                                      context
                                          .read<FriendCubit>()
                                          .deleteFriend(id);
                                    }, onReject: (){},
                                  );
                                },
                                child: Image.file(
                                  File('${_imagePath}btn_delete.png'),
                                  width: 20,
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 3,
                    decoration:
                        BoxDecoration(gradient: LinearGradient(colors: gColors3)),
                  ),
                ],
              ),
          ))
        ],
      ),
    );
  }
}

class OneFriendListWithBtn extends StatefulWidget {
  final String profileImgUrl;
  final String nickname;
  final String id;
  final Function onTapImg;

  const OneFriendListWithBtn(
      {required this.profileImgUrl, required this.nickname, required this.id, required this.onTapImg});

  @override
  _OneFriendListWithBtnState createState() => _OneFriendListWithBtnState();
}

class _OneFriendListWithBtnState extends State<OneFriendListWithBtn> {
  final gColors = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors2 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors3 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  double listHeight = 56;
  bool isAlready = false;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: sw,
      height: listHeight,
      child: Row(
        children: [
          Container(
            width: listHeight,
            height: listHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gColors2,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                widget.onTapImg();
              },
              child: Center(
                child: Image.network(
                  widget.profileImgUrl,
                  width: listHeight - 8,
                  height: listHeight - 8,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
                    return Image.asset('assets/images/icons/friends.png');
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
              child: Container(
              padding: const EdgeInsets.symmetric(),
              height: listHeight,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(),
                gradient: LinearGradient(
                  colors: gColors,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: 3,
                    decoration:
                        BoxDecoration(gradient: LinearGradient(colors: gColors3)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              widget.nickname,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                          ],
                        ),
                        IgnorePointer(
                          ignoring: isAlready,
                          child: SizedBox(
                            width: 65,
                            height: 26,
                            child: RaisedButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  isAlready = true;
                                });
                                context
                                    .read<FriendCubit>()
                                    .sendFriendRequest(widget.id);
                              },
                              color:
                                  isAlready ? Colors.grey.shade400 : appMainColor,
                              child: Text(
                                isAlready ? AppConfig.lang=='kor'? '신청완료' :'completed' : AppConfig.lang=='kop' ? '친구신청' : 'request',
                                style: TextStyle(
                                    color:
                                        isAlready ? Colors.black : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 3,
                    decoration:
                        BoxDecoration(gradient: LinearGradient(colors: gColors3)),
                  ),
                ],
              ),
          ))
        ],
      ),
    );
  }
}

class ApplyingFriendList extends StatelessWidget {
  final String profileImgUrl;
  final String nickname;
  final String id;
  final Function onTapImg;

  ApplyingFriendList({
    required this.profileImgUrl,
    required this.nickname,
    required this.id,
    required this.onTapImg,
  });

  final gColors = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors2 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors3 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors4 = [
    const Color(0xff2f294f).withOpacity(0.0),
    const Color(0xffae9dcc).withOpacity(0.6)
  ];
  final double listHeight = 56;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: sw,
      color: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: listHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gColors2,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    onTapImg();
                  },
                  child: Center(
                    child: Image.network(
                      profileImgUrl,
                      width: listHeight - 8,
                      height: listHeight - 8,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
                        return Image.asset('assets/images/icons/friends.png');
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.symmetric(),
                height: listHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(),
                  gradient: LinearGradient(
                    colors: gColors,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 3,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gColors3)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                AppConfig.lang=='kor' ? '$nickname 님에게 친구신청을 보냈습니다.' : 'Friend request has been sent',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 3,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gColors3)),
                    ),
                  ],
                ),
              ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 100,
                height: listHeight - 14,
                decoration:
                    BoxDecoration(gradient: LinearGradient(colors: gColors4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 70,
                        height: 30,
                        child: RaisedButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            //todo 신청 취소
                            context.read<FriendCubit>().cancelFriendRequest(id);
                          },
                          color: appMainColor,
                          child: Text(
                            AppConfig.lang=='kor' ? '신청 취소' : 'Cancel',
                            style:const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
}

class ReceivingFriendList extends StatelessWidget {
  final String profileImgUrl;
  final String nickname;
  final String id;
  final Function onTabImg;

  ReceivingFriendList({
    required this.profileImgUrl,
    required this.nickname,
    required this.id,
    required this.onTabImg,
  });

  final gColors = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors2 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors3 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors4 = [
    const Color(0xff2f294f).withOpacity(0.0),
    const Color(0xffae9dcc).withOpacity(0.6)
  ];
  final double listHeight = 56;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: sw,
      color: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: listHeight,
                height: listHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gColors2,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    onTabImg();
                  },
                  child: Center(
                    child: Image.network(
                      profileImgUrl,
                      width: listHeight - 8,
                      height: listHeight - 8,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
                        return Image.asset('assets/images/icons/friends.png');
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.symmetric(),
                height: listHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(),
                  gradient: LinearGradient(
                    colors: gColors,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 3,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gColors3)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                AppConfig.lang=='kor' ? '$nickname 님에게 친구신청을 받았습니다' : 'Request friend form $nickname',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 3,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gColors3)),
                    ),
                  ],
                ),
              ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: listHeight - 14,
                decoration:
                    BoxDecoration(gradient: LinearGradient(colors: gColors4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 70,
                        height: 30,
                        child: RaisedButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            //todo 신청 수락
                            context.read<FriendCubit>().acceptFriendRequest(id);
                          },
                          color: appMainColor,
                          child: Text(
                            AppConfig.lang=='kor' ? '수락' : 'Accept',
                            style:const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 70,
                        height: 30,
                        child: RaisedButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            //todo 신청 취소
                            context.read<FriendCubit>().denyFriendRequest(id);
                          },
                          color: Colors.grey.shade400,
                          child: Text(
                            AppConfig.lang=='kor' ? '거절' : 'Reject',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
}

void showGiftDialog(
    {BuildContext? contexts,
    List<Map<String, dynamic>>? data,
    String? nickname,
    String? profileImgUrl,
    String? id,
    Function? sendGift,
    Function? setSelected,
    Function? selectItem}) {
  final sw = MediaQuery.of(contexts!).size.width;
  final gColors = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors2 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  final gColors3 = [
    const Color(0xffae9dcc).withOpacity(0.6),
    const Color(0xff2f294f).withOpacity(0.0)
  ];
  const double listHeight = 40;
  showDialog(
      context: contexts,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(8),
                width: 285,
                height: 550,
                color: const Color(0xff2f294f),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: sw,
                      height: listHeight,
                      child: Row(
                        children: [
                          Container(
                            width: listHeight,
                            height: listHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gColors2,
                              ),
                            ),
                            child: Center(
                              child: Image.network(
                                profileImgUrl!,
                                width: listHeight - 8,
                                height: listHeight - 8,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
                                  return Image.asset('assets/images/icons/friends.png');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Container(
                            padding: const EdgeInsets.symmetric(),
                            height: listHeight,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(),
                              gradient: LinearGradient(
                                colors: gColors,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 3,
                                  decoration: BoxDecoration(
                                      gradient:
                                          LinearGradient(colors: gColors3)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            AppConfig.lang=='kor'?'$nickname 님에게 선물하기' : 'Send to $nickname',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade400,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(11)),
                                        ),
                                        child: Center(
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(contexts);
                                              },
                                              child: const Icon(
                                                Icons.arrow_back,
                                                color: Colors.redAccent,
                                                size: 20,
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 3,
                                  decoration: BoxDecoration(
                                      gradient:
                                          LinearGradient(colors: gColors3)),
                                ),
                              ],
                            ),
                          ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                     AppConfig.lang =='kor' ? '내 보관함' : 'My item',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                        child: ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.73,
                        children: data!
                            .map((e) => OneGift(
                                  data: e,
                                  select: (String id, bool isSelected) {
                                    selectItem!(id, isSelected);
                                  },
                                ))
                            .toList(),
                      ),
                    )),
                    const SizedBox(height: 9,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 38,
                          child: RaisedButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              sendGift!();
                              Navigator.pop(contexts);
                              //  TODO give gift
                            },
                            color: appMainColor,
                            child: Text(
                              AppConfig.lang =='kor' ? '친구에게 선물하기' : 'Send to friend',
                              style:const  TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )).then((value) {
    setSelected!();
  });
}

class OneGift extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function select;

  const OneGift({
    required this.data,
    required this.select,
  });

  @override
  _OneGiftState createState() => _OneGiftState();
}

class _OneGiftState extends State<OneGift> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      color: Colors.grey.shade200.withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected = !isSelected;
                  });
                  widget.select(widget.data['id'], isSelected);
                },
                child: Container(
                  alignment: Alignment.topCenter,
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(width: 2),
                      image: DecorationImage(
                          //image : FileImage(File(_imagePath+'icon_item_${widget.itemType}.png')),
                          image: NetworkImage(
                            widget.data == null
                                ? ""
                                : widget.data['img_url'].toString(),
                          ),
                          fit: BoxFit.cover)),
                ),
              ),
              IgnorePointer(
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: appMainColor,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            widget.data['title'].toString(),
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13.5),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 1,
          ),
          Text(
            widget.data['desc'].toString(),
            style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}




