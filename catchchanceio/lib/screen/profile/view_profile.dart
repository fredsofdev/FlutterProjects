import 'dart:io';

import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/repository/authentication/friend_repository.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/view_profile_cubit.dart';

class ViewProfile extends StatelessWidget {
  final String userId;
  final String myId;

  const ViewProfile(this.userId, this.myId);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return BlocProvider(
      create: (_) => ViewProfileCubit(FriendRepository(), userId, myId),
      child: _ViewProfile(),
    );
  }
}

class _ViewProfile extends StatefulWidget {
  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<_ViewProfile> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/profile/';
  final TextStyle _basicTextStyle =
      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  final double _w1 = 85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(File('${_imagePath}bg.png')),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              ScreenAppBar(),
              Expanded(
                child: ScrollConfiguration(
                  behavior: NoGlowScrollBehavior(),
                  child: SingleChildScrollView(
                    child: BlocBuilder<ViewProfileCubit, ViewProfileState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 38,
                            ),
                            ProfileImageCircleBox(
                                url: state.userData.uImgBig, onPressed: () {}),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.userData.uName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      if (state.relationship ==
                                          Relationship.UNKNOWN) {
                                        context
                                            .read<ViewProfileCubit>()
                                            .sendFriendRequest();
                                      }
                                    },
                                    child: Image.asset(
                                        state.relationship ==
                                                Relationship.UNKNOWN
                                            ? "assets/images/icons/add_friend.png"
                                            : state.relationship ==
                                                    Relationship.FRIEND
                                                ? "assets/images/icons/friends.png"
                                                : "assets/images/icons/request.png",
                                        width: 20,
                                        height: 20))
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: _w1,
                                          child: Center(
                                              child: Text(
                                            '플레이 횟수',
                                            style: _basicTextStyle.copyWith(
                                                fontSize: 14),
                                          ))),
                                      SizedBox(
                                          width: _w1,
                                          child: Center(
                                              child: Text(
                                            '성공 횟수',
                                            style: _basicTextStyle.copyWith(
                                                fontSize: 14),
                                          ))),
                                      SizedBox(
                                          width: _w1,
                                          child: Center(
                                              child: Text(
                                            '성공 확률',
                                            style: _basicTextStyle.copyWith(
                                                fontSize: 14),
                                          ))),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Image.file(
                                    File('${_imagePath}line.png'),
                                    width: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 280,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: _w1,
                                          child: Center(
                                              child: Text(
                                            '${state.userData.uTotalPlayCount} 회',
                                            style: _basicTextStyle.copyWith(
                                                fontSize: 18),
                                          ))),
                                      SizedBox(
                                          width: _w1,
                                          child: Center(
                                              child: Text(
                                            '${state.userData.uWins} 회',
                                            style: _basicTextStyle.copyWith(
                                                fontSize: 18),
                                          ))),
                                      SizedBox(
                                          width: _w1,
                                          child: Center(
                                              child: state.userData
                                                          .uTotalPlayCount ==
                                                      0
                                                  ? Text(
                                                      '0%',
                                                      style: _basicTextStyle
                                                          .copyWith(
                                                              fontSize: 18),
                                                    )
                                                  : Text(
                                                      '${((state.userData.uWins / state.userData.uTotalPlayCount) * 100).toStringAsFixed(2)}%',
                                                      style: _basicTextStyle
                                                          .copyWith(
                                                              fontSize: 18),
                                                    ))),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Text(
                                  '스테이지 플레이',
                                  style: _basicTextStyle.copyWith(fontSize: 14),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Image.file(
                                    File('${_imagePath}line.png'),
                                    width: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 300,
                                  child: Wrap(
                                    runSpacing: 12,
                                    children: [
                                      StageInfoBox(
                                        successRate:
                                            ((state.userData.uStage1Wins /
                                                        state.userData
                                                            .uStage1Total) *
                                                    100)
                                                .toDouble(),
                                        stageName: 'state1',
                                        stagePath: "forest",
                                      ),
                                      StageInfoBox(
                                        successRate:
                                            ((state.userData.uStage2Wins /
                                                        state.userData
                                                            .uStage2Total) *
                                                    100)
                                                .toDouble(),
                                        stageName: 'state2',
                                        stagePath: "desert",
                                      ),
                                      StageInfoBox(
                                        successRate:
                                            ((state.userData.uStage3Wins /
                                                        state.userData
                                                            .uStage3Total) *
                                                    100)
                                                .toDouble(),
                                        stageName: 'state3',
                                        stagePath: "mine",
                                      ),
                                      StageInfoBox(
                                        successRate:
                                            ((state.userData.uStage4Wins /
                                                        state.userData
                                                            .uStage4Total) *
                                                    100)
                                                .toDouble(),
                                        stageName: 'state4',
                                        stagePath: "sea",
                                      ),
                                      StageInfoBox(
                                        successRate:
                                            ((state.userData.uStage5Wins /
                                                        state.userData
                                                            .uStage5Total) *
                                                    100)
                                                .toDouble(),
                                        stageName: 'state5',
                                        stagePath: "dia",
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class ProfileImageCircleBox extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/profile/';
  final Function onPressed;
  final String url;

  ProfileImageCircleBox({required this.url, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            File('${_imagePath}img_frame.png'),
            width: 240,
            fit: BoxFit.contain,
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(38.0),
              child: Image.network(
                url,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
              )),
        ],
      ),
    );
  }
}

class StageInfoBox extends StatelessWidget {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/stage_list/';
  final String stageName;
  final String stagePath;
  final double successRate;

  StageInfoBox({required this.stageName, required this.successRate, required this.stagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.file(
            File('${_imagePath + stagePath}_card.png'),
            width: 98,
            fit: BoxFit.contain,
          ),
          Positioned(
              bottom: 5,
              child: Text(
                '${successRate.toStringAsFixed(2)}%',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ))
        ],
      ),
    );
  }
}
