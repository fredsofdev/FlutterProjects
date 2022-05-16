import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/repository/authentication/authentication_repository.dart';
import 'package:catchchanceio/widgets/buttons/provider_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/login_cubit.dart';
import 'model/nickname.dart';

class LoginScreen extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: BlocProvider(
          create: (_) => LoginCubit(
            context.read<AuthenticationRepository>(),
          ),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext contexts) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          (previous.process != current.process) ||
          (previous.loading != current.loading),
      listener: (context, state) {
        if (state.process == LoginProcess.failed) {
          Scaffold.of(contexts)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                const SnackBar(content: Text('Authentication Failure')));
        }
        if (state.loading == LoginLoading.loading) {
          //   TODO loading while registering
          Scaffold.of(contexts)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                duration: const Duration(seconds: 5),
                content: Row(
                  children: const [
                    CircularProgressIndicator(),
                    Text(" 로그인 중..."),
                  ],
                )));
        } else {
          Scaffold.of(contexts).hideCurrentSnackBar();
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (contexts, state) {
          return Container(
              color: appMainColor,
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                      bottom: 0,
                      child: Image.asset(
                        'assets/res/start/start_image.png',
                        width: MediaQuery.of(contexts).size.width * 1.0,
                        height: MediaQuery.of(contexts).size.height * 1.0,
                        fit: BoxFit.cover,
                      )),
                  Positioned(
                      bottom: 0,
                      child: Image.asset(
                        'assets/res/start/bottom.png',
                        width: MediaQuery.of(contexts).size.width * 1.0,
                      )),
                  Positioned(
                      bottom: 70,
                      child: Image.asset(
                        'assets/res/start/game_logo.png',
                        width: MediaQuery.of(contexts).size.width * 0.8,
                      )),
                  Visibility(
                    visible: state.process == LoginProcess.initial ||
                        state.process == LoginProcess.failed,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        ProviderLoginButton(
                          loginProvider: 'google',
                          onTap: () async {
                            contexts.read<LoginCubit>().logInWithGoogle();
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ProviderLoginButton(
                          loginProvider: 'facebook',
                          onTap: () async {
                            contexts.read<LoginCubit>().logInWithFacebook();
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ProviderLoginButton(
                          loginProvider: 'kakao',
                          onTap: () async {
                            contexts.read<LoginCubit>().logInWithKakao();
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ProviderLoginButton(
                          loginProvider: 'line',
                          onTap: () async {
                            contexts.read<LoginCubit>().logInWithLine();
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: state.process == LoginProcess.receivedCred,
                      child: Container(
                          width: MediaQuery.of(contexts).size.width,
                          height: MediaQuery.of(contexts).size.height,
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Container(
                              //     padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                              //     decoration: BoxDecoration(
                              //         color: Colors.black.withOpacity(0.6),
                              //         borderRadius: BorderRadius.circular(5)
                              //     ),
                              //     child: const Text('사용할 닉네임을 입력해주세요.', style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),)
                              // ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 9),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    border: Border.all(color: Colors.black54),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                width:
                                    MediaQuery.of(contexts).size.width * 0.88,
                                height: 50,
                                child: Center(
                                  child: TextField(
                                    onChanged: (nickname) => contexts
                                        .read<LoginCubit>()
                                        .nicknameChanged(nickname),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 19),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        fillColor: Colors.grey.shade300,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: '새로운 닉네임을 입력해주세요.',
                                        hintStyle:
                                            const TextStyle(fontSize: 17)),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              //Text(state.errorMessage ,style: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize:15),),
                              const SizedBox(
                                height: 10,
                              ),
                              Material(
                                // needed
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xff4ec334),
                                child: InkWell(
                                  onTap: () {
                                    FocusScope.of(contexts).unfocus();
                                    // SystemChrome.setEnabledSystemUIOverlays([]);
                                    if (state.nickNameValid ==
                                        NickNameValidation.valid) {
                                      contexts
                                          .read<LoginCubit>()
                                          .signInWithProviderData();
                                    }
                                  }, // needed
                                  child: SizedBox(
                                    width: MediaQuery.of(contexts).size.width *
                                        0.88,
                                    height: 50,
                                    child: const Center(
                                      child: Text('이 닉네임으로 시작하기',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black87)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              )
                            ],
                          )))
                ],
              ));
        },
      ),
    );
  }
}
