import 'dart:io';
import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/behavior.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/webview/custom_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'children/company_info_screen.dart';
import 'children/game_usage_level_screen.dart';
import 'children/marketing_agreement_screen.dart';
import 'children/my_login_screen.dart';
import 'children/qna_screen.dart';
import 'children/withdrawal_screen.dart';

class ServiceScreen extends StatefulWidget {
  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final String _imagePath =
      '${AppConfig.appDocDirectory!.path}/osgame/screen/setting/';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIOverlays([]);
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
            //todo appbar
            ScreenAppBar(buttons: [],),
            const SizedBox(
              height: 20,
            ),
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                return Expanded(
                    child: Container(
                  width: double.infinity,
                  color: const Color(0xff2f294f),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: sw,
                              height: 3,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                colors: [
                                  Color(0xff2f294f),
                                  Color(0xffae9dcc),
                                  Color(0xff2f294f)
                                ],
                              )),
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  '고객센터',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )),
                            Container(
                              width: sw,
                              height: 3,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                colors: [
                                  Color(0xff2f294f),
                                  Color(0xffae9dcc),
                                  Color(0xff2f294f)
                                ],
                              )),
                            ),
                            Container(
                              color: Colors.grey.shade700,
                              padding: const EdgeInsets.only(bottom: 2),
                              child: ScrollConfiguration(
                                behavior: NoGlowScrollBehavior(),
                                child: GridView(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 2,
                                    crossAxisCount: 3,
                                  ),
                                  children: <Widget>[
                                    OneServiceBox(
                                      text: '개인정보처리방침',
                                      onPressed: () {
                                        //todo webview
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomWebview(
                                                  url: state
                                                      .reportUrls['user_privacy']
                                                      .toString(),
                                                  appBarTitle: '개인정보처리방침',
                                                )));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '광고성 정보\n수신동의',
                                      onPressed: () {
                                        //todo app
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child:
                                                    MarketingAgreementScreen()));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '게임 이용 등급',
                                      onPressed: () {
                                        //todo webview
                                        // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new CustomWebview(
                                        //   url: state.reportUrls['game_level'],
                                        //   appBarTitle: '게임 이용 등급',
                                        // )));

                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: GameUsageLevelScreen()));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '연동 계정',
                                      onPressed: () {
                                        //todo app
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: MyLoginScreen(
                                                  loginProvider: state.user.uEmail
                                                      .split("_")[0],
                                                )));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '1:1 문의',
                                      onPressed: () {
                                        //todo app
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: QNAScreen()));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '오류(네트워크)',
                                      onPressed: () {
                                        //todo webview
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomWebview(
                                                  url: state.reportUrls['network']
                                                      .toString(),
                                                  appBarTitle: '오류(네트워크)',
                                                )));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '오류(버그)',
                                      onPressed: () {
                                        //todo webview
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomWebview(
                                                  url: state.reportUrls['bug']
                                                      .toString(),
                                                  appBarTitle: '오류(버그)',
                                                )));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '건의',
                                      onPressed: () {
                                        //todo webview
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomWebview(
                                                  url: state.reportUrls['request']
                                                      .toString(),
                                                  appBarTitle: '건의',
                                                )));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '신고',
                                      onPressed: () {
                                        //todo webview
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomWebview(
                                                  url: state.reportUrls['report']
                                                      .toString(),
                                                  appBarTitle: '신고',
                                                )));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '밸런스',
                                      onPressed: () {
                                        //todo webview
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CustomWebview(
                                                  url: state.reportUrls['balance']
                                                      .toString(),
                                                  appBarTitle: '밸런스',
                                                )));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '회사정보',
                                      onPressed: () {
                                        //todo app
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: CompanyInfoScreen()));
                                      },
                                    ),
                                    OneServiceBox(
                                      text: '회원탈퇴',
                                      onPressed: () {
                                        //todo app
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: WithdrawalScreen()));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Image.file(
                            File(
                                '${AppConfig.appDocDirectory!.path}/osgame/logo/company_text_logo.png'),
                            width: 120,
                          ),
                        )
                      ],
                    ),
                  ),
                ));
              },
            )
          ],
        ),
      ),
    );
  }
}

class OneServiceBox extends StatelessWidget {
  final String text;
  final Function onPressed;

  const OneServiceBox({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        color: const Color(0xff2f294f),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
