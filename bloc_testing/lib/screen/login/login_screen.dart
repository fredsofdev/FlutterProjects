import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:/authentication_repository/authentication_repository.dart';
import 'package:formz/formz.dart';

import 'cubit/login_cubit.dart';

class LoginScreen extends StatelessWidget {

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider(
          create: (_) =>
              LoginCubit(
                context.repository<AuthenticationRepository>(),
              ),
          child: LoginForm(),
        ),
      ),
    );
  }
}


class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == FormzStatus.submissionFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Authentication Failure'))
              );
          }
          if(state.status == FormzStatus.submissionInProgress || state.status == FormzStatus.invalid){

          }
        },
        child: Container(
          width: double.infinity,
          child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height:150,),
                    Image.asset('assets/logo/game-logo.png',width: 200,),
                    Expanded(
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ProviderLoginButton(
                                loginProvider: 'google',
                                onTap: () async{
                                context.bloc<LoginCubit>().logInWithGoogle();
                                }
                            ),
                            SizedBox(height: 20,),
                            ProviderLoginButton(
                              loginProvider: 'facebook',
                              onTap: () async{
                                context.bloc<LoginCubit>().logInWithFacebook();
                              },
                            ),
                            SizedBox(height: 20,),
                            ProviderLoginButton(
                              loginProvider: 'kakao',
                              onTap: () async{
                                context.bloc<LoginCubit>().logInWithKakao();
                              },
                            ),
                            SizedBox(height: 20,),
                            ProviderLoginButton(
                              loginProvider: 'line',
                              onTap: () async{
                                context.bloc<LoginCubit>().logInWithLine();
                              },
                            ),
                            SizedBox(height: 20,),
                          ],
                        )
                    ),
                  ],
                );



        ),
    );
  }
