import 'dart:io';

import 'package:catchchanceio/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/hooks/life_cycle_hook.dart';
import 'package:catchchanceio/hooks/video_hook.dart';
import 'package:catchchanceio/music/background_music_player.dart';
import 'package:catchchanceio/repository/authentication/authentication_repository.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:catchchanceio/screen/splash/splash_cubit/splash_cubit.dart';
import 'package:catchchanceio/widgets/appbars/screen_app_bar.dart';
import 'package:catchchanceio/widgets/buttons/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';



class SplashScreen extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: BlocProvider(
        create: (_) => SplashCubit(
          context.read<AuthenticationRepository>(),
        ),
        child: SplashView(),
      ),
    );
  }
}

class SplashView extends HookWidget {
  // final BackgroundMusicPlayer _musicPlayer = BackgroundMusicPlayer();
  @override
  Widget build(BuildContext context) {



    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final cubit =
        useBloc<SplashCubit, SplashState>(onEmitted: (_, p, c) => false);
    final _ = useBloc<SplashCubit, SplashState>(onEmitted: (_, p, c) {
      if (p.status != c.status && c.status == ResourcesStatus.not_downloaded) {
        showConfirmDownload(context).then((result) {
          if (result == true) {
            cubit.getResources();
          } else {
            //  TODO navigation pop

          }
        });
      }

      return false;
    });
    useEffect(() {
      BackgroundMusicPlayer.instance.playLoopCash('splash_screen');
      return null;
    }, []);

    useLifeCycleUpdate(context, lifeCycleUpdate: (AppLifecycleState state) {
      if (state == AppLifecycleState.paused) {
        BackgroundMusicPlayer.instance.stopLoop();
      }
    });

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: appMainColor,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: sw,
            height: sh,
            color: Colors.transparent,
          ),
          HookBuilder(builder: (context) {
            final state = useBloc<SplashCubit, SplashState>().state;
            if (state.process == ResourceProcess.done) {
              final videoController = useVideoController(
                  videoUrl: '/osgame/screen/start/start_loading.mp4');
              final videoFuture =
                  useMemoized(() => videoController.initialize());
              const videoRatio = 1072 / 2738;
              return FutureBuilder(
                  future: videoFuture,
                  builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.done
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                  width: sw,
                                  height: sw / videoRatio,
                                  child: VideoPlayer(videoController)),
                            ),
                          )
                        : const SizedBox();
                  });
            } else {
              return Positioned(
                  bottom: 0,
                  child: Image.asset(
                    'assets/res/start/start_image.png',
                    width: sw,
                    height: sh,
                    fit: BoxFit.cover,
                  ));
            }
          }),
          // Positioned(
          //   top: sh * 0.05,
          //   left: sw * 0.05,
          //   child: BackButtonPolygonBox(),
          // ),
          Positioned(
              bottom: sw * 0.45,
              child: Image.asset(
                'assets/res/start/${makeFilename('game_logo.png')}',
                width: sw * 0.94,
              )
          ),
          Positioned(
              bottom: 0,
              child: Image.asset(
                'assets/res/start/bottom.png',
                width: sw * 1.0,
              )),
          Positioned(
            bottom: 35,
            child: HookBuilder(builder: (context) {
              final isClicked = useState(false);
              final state = useBloc<SplashCubit, SplashState>().state;
              final authBloc = useBloc<AuthenticationBloc, AuthenticationState>(
                  onEmitted: (_, p, c) {
                return p.user!=c.user;
              });
              if (state.process == ResourceProcess.done) {
                final String _imagePath =
                    '${AppConfig.appDocDirectory!.path}/osgame/screen/start/';
                return Visibility(
                  visible: !(state.percentage == "0"),
                  child: IgnorePointer(
                    ignoring: isClicked.value,
                    child: GestureDetector(
                      onTap: () {
                        authBloc.add(StartAuthenticationListener());

                        isClicked.value = true;
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(
                            File('$_imagePath/start_txt_bg.png'),
                            fit: BoxFit.contain,
                            width: 250,
                          ),
                          Image.file(
                            File('$_imagePath/${makeFilename('start_txt_border.png')}'),
                            fit: BoxFit.contain,
                            width: 250,
                          ),
                          Image.file(
                            File('$_imagePath/${makeFilename('start_txt.png')}'),
                            fit: BoxFit.contain,
                            width: 250,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Visibility(
                    visible: state.process == ResourceProcess.processing,
                    child: Container(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width * 0.8,
                            animation: true,
                            animateFromLastPercent: true,
                            alignment: MainAxisAlignment.center,
                            lineHeight: 14.0,
                            percent:
                                double.parse(state.percentage.split('%')[0]),
                            progressColor: appMainColor,
                            backgroundColor: Colors.grey.shade200,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            '${(double.parse((state.percentage).split('%')[0]) * 100).round()} % ${AppConfig.lang=='kor' ? '다운로드 중...' : 'downloading...'} (${state.percentage.split('%').removeLast()})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ));
              }
            }),
          )
        ],
      ),
    );
  }

  Future<bool> showConfirmDownload(BuildContext context) async {
    const TextStyle tsBlack =
         TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const TextStyle tsRed = TextStyle(
        fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red);

    return await showDialog(
      barrierColor: Colors.black.withOpacity(0.2),
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/res/dialog/dialog_frame.png',
                width: 300,
              ),
              // Positioned(
              //   right: 10,
              //   top: 10,
              //   child: CustomButtonAsset(
              //     width: 28,
              //     onPressed: () {
              //       Navigator.pop(context,false);
              //     },
              //     pressedImageFilePath:'assets/res/dialog/btn_exit_d.png',
              //     defaultImageFilePath:'assets/res/dialog/btn_exit_e.png' ,
              //   ),
              // ),
              Positioned(
                  top: 100,
                  child: Column(
                    children: [
                      Text(AppConfig.lang =='kor' ? '[데이터 환경 알림]' : '[Network Environment]', style: tsRed),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        AppConfig.lang=='kor' ? '대용량 리소스 파일을 다운로드 합니다.' : 'Large files will be downloaded',
                        style: tsBlack,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'LTE/Wifi',
                          style: tsRed,
                          children: <TextSpan>[
                            TextSpan(text:AppConfig.lang=='kor' ? ' 환경에서' : ' is recommended', style: tsBlack),
                          ],
                        ),
                      ),
                      Text(
                        AppConfig.lang=='kor' ? '다운로드를 진행하세요.' : 'Please click download button',
                        style: tsBlack,
                      ),
                    ],
                  )),

              Positioned(
                bottom: 20,
                child: CustomButtonAsset(
                  text: Text(
                    AppConfig.lang=='kor' ? '다운로드 시작' : 'Download Now',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                  ),
                  width: 160,
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  pressedImageFilePath: 'assets/res/dialog/btn_d.png',
                  defaultImageFilePath: 'assets/res/dialog/btn_e.png',
                ),
              ),
            ],
          )),
    );
  }
}
