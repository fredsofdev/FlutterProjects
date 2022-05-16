import 'dart:io';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/profile/';
  final TextStyle _basicTextStyle =
      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  final double _w1 = 85;
  late File mPhoto;
  late String img64;
  bool isLoading = false;


  Future<void> onPhoto() async {
    // ignore: deprecated_member_use
    final XFile? f = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 300, maxWidth: 300);
    setState(() {
      isLoading = true;
    });
    String result = "네트워크 에러 발생";
    if(f != null) {
      print(f.path);
      final File image = File(f.path);
      print(image.path);
      result = await context.read<AuthenticationBloc>().updateImg(image);
    }
    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(
        msg: result,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 15.0);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return LoadingOverlay(
      isLoading: isLoading,
      color: Colors.black,
      progressIndicator: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(appMainColor),
      ),
      child: Scaffold(
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
                      child:
                          BlocBuilder<AuthenticationBloc, AuthenticationState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              const SizedBox(
                                height: 38,
                              ),
                              ProfileImageCircleBox(
                                url: state.user.uImgBig,
                                onPressed: () => onPhoto(),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.user.uName,
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
                                        showEditingNicknameDialog(context,
                                            exNickname: state.user.uName,
                                            submit: (String text) async {
                                          if (text != state.user.uName &&
                                              text.toString().isNotEmpty) {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final result = await context
                                                .read<AuthenticationBloc>()
                                                .updateNickname(text);

                                            setState(() {
                                              isLoading = false;
                                            });
                                            Fluttertoast.showToast(
                                                msg: result,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.7),
                                                textColor: Colors.white,
                                                fontSize: 15.0);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "닉네임이 올바르지 않습니다.",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.7),
                                                textColor: Colors.white,
                                                fontSize: 15.0);
                                          }
                                        });
                                      },
                                      child: Image.file(
                                        File('${_imagePath}edit_btn.png'),
                                        width: 20,
                                      ))
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
                                              AppConfig.lang=='kor' ? '플레이 횟수' : 'Play',
                                              style: _basicTextStyle.copyWith(
                                                  fontSize: 14),
                                            ))),
                                        SizedBox(
                                            width: _w1,
                                            child: Center(
                                                child: Text(
                                              AppConfig.lang=='kor' ? '성공 횟수' : 'Success',
                                              style: _basicTextStyle.copyWith(
                                                  fontSize: 14),
                                            ))),
                                        SizedBox(
                                            width: _w1,
                                            child: Center(
                                                child: Text(
                                              AppConfig.lang=='kor' ? '성공 확률' : 'Possibility',
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
                                              AppConfig.lang=='kor' ? '${state.user.uTotalPlayCount} 회' : '${state.user.uTotalPlayCount}',
                                              style: _basicTextStyle.copyWith(
                                                  fontSize: 18),
                                            ))),
                                        SizedBox(
                                            width: _w1,
                                            child: Center(
                                                child: Text(
                                              AppConfig.lang=='kor' ?  '${state.user.uWins} 회' : '${state.user.uWins}',
                                              style: _basicTextStyle.copyWith(
                                                  fontSize: 18),
                                            ))),
                                        SizedBox(
                                            width: _w1,
                                            child: Center(
                                                child: state.user
                                                            .uTotalPlayCount ==
                                                        0
                                                    ? Text(
                                                        '0%',
                                                        style: _basicTextStyle
                                                            .copyWith(
                                                                fontSize: 18),
                                                      )
                                                    : Text(
                                                        '${((state.user.uWins / state.user.uTotalPlayCount) * 100).toStringAsFixed(2)}%',
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
                                    AppConfig.lang == 'kor' ? '스테이지 플레이' : 'Stage Play',
                                    style:
                                        _basicTextStyle.copyWith(fontSize: 14),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 20),
                                    child: Image.file(
                                      File('${_imagePath}line.png'),
                                      width: 300,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: Wrap(
                                      runSpacing: 20,
                                      children: [
                                        StageInfoBox(
                                          successRate: ((state
                                                          .user.uStage1Wins /
                                                      state.user.uStage1Total) *
                                                  100)
                                              .toDouble(),
                                          stageName: 'stage1',
                                          stagePath: "forest",
                                        ),
                                        StageInfoBox(
                                          successRate: ((state
                                                          .user.uStage2Wins /
                                                      state.user.uStage2Total) *
                                                  100)
                                              .toDouble(),
                                          stageName: 'stage2',
                                          stagePath: "desert",
                                        ),
                                        StageInfoBox(
                                          successRate: ((state
                                                          .user.uStage3Wins /
                                                      state.user.uStage3Total) *
                                                  100)
                                              .toDouble(),
                                          stageName: 'stage3',
                                          stagePath: "mine",
                                        ),
                                        StageInfoBox(
                                          successRate: ((state
                                                          .user.uStage4Wins /
                                                      state.user.uStage4Total) *
                                                  100)
                                              .toDouble(),
                                          stageName: 'stage4',
                                          stagePath: "sea",
                                        ),
                                        StageInfoBox(
                                          successRate: ((state
                                                          .user.uStage5Wins /
                                                      state.user.uStage5Total) *
                                                  100)
                                              .toDouble(),
                                          stageName: 'stage5',
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
      ),
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
              borderRadius: BorderRadius.circular(37.0),
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
      '${AppConfig.appDocDirectory!.path}/osgame/screen/profile/';
  final String stageName;
  final String stagePath;
  final double successRate;

  StageInfoBox({required this.stageName, required this.successRate, required this.stagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.file(
          AppConfig.lang=='kor' ?
          File('${_imagePath + stageName}.png') :
          File('${_imagePath + stageName}_en.png'),
          width: 100,
          fit: BoxFit.contain,
        ),
        Positioned(
            bottom: 7,
            child: Text(
            successRate > 0 &&  successRate < 101 ? '${successRate.toStringAsFixed(2)}%' : '0%',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ))
      ],
    );
  }
}

void showEditingNicknameDialog(BuildContext context,
    {required String exNickname, required Function submit}) {
  var textName = exNickname;
  showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (_) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                height: 220,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '닉네임 변경',
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
                          controller: TextEditingController()
                            ..text = exNickname,
                          cursorColor: Colors.black,
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
                              submit(textName);
                              Navigator.pop(context);
                            },
                            color: appMainColor,
                            child: const Text(
                              '변경하기',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),
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
            ),
          )).then((value) {
    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIOverlays([]);
  });
}
