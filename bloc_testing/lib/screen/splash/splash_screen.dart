
import 'package:bloc_testing/screen/splash/splash_cubit/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:/authentication_repository/authentication_repository.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SplashScreen extends StatelessWidget {

  static Route route(){
    return MaterialPageRoute<void>(builder: (_) => SplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider(
          create: (_) => SplashCubit(
            context.repository<AuthenticationRepository>(),
          ),
          child: SplashView(),
        ),
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal:20),
        width: double.infinity,
        height: double.infinity,
        color: Color(0xfffdc532),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo/game-logo.png'),
            BlocBuilder<SplashCubit, SplashState>(
              buildWhen: (previous, current) => previous.percentage != previous.percentage,
              builder:  (context, state){
                return Visibility(
                    visible: state.process == ResourceProcess.processing ? true : false,
                    child:Container(
                      padding: EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width*0.8,
                            animation: true,
                            animateFromLastPercent: true,
                            alignment: MainAxisAlignment.center,
                            lineHeight: 20.0,
                            percent: double.parse(state.percentage),
                            progressColor: Colors.deepPurple,
                            backgroundColor: Colors.grey.shade200,
                          ),
                          SizedBox(height:6,),
                          Text(
                            (double.parse(state.percentage)*100).round().toString()+'% 다운로드 중...',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize:12,
                            ),
                          ),
                        ],
                      ),
                    )
                );
              }
            )
          ],
        ),
      ),
    );
  }
}
