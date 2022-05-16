import 'package:dogfeed/connection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/src/provider.dart';


class Login extends HookWidget {
  const Login({Key? key}) : super(key: key);

  static Route route() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white70,
    ));
    return MaterialPageRoute<void>(builder: (_) => const Login());
  }


  @override
  Widget build(BuildContext context) {

    final ws = MediaQuery.of(context).size.width;
    final hs = MediaQuery.of(context).size.height;

    return Scaffold(
      // appBar: AppBar(
      //   title:const Text("Login"),
      // ),
      body: Container(
        height: hs,
        width: ws,
        color: Colors.white,
        child: Stack(
          children: [
            SizedBox(
              height: hs,
              width: ws,
              child: Image.asset('assets/2_login_title.png', fit: BoxFit.cover,)
            ),

            Positioned(
              top: hs * 0.3,
              left: ws * 0.38,
              child: Material(
                elevation: 0.0,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                child: Ink.image(
                  image: const AssetImage('assets/2_google_Btn.png'),
                  fit: BoxFit.cover,
                  width: ws * 0.25,
                  height: ws * 0.25,
                  child: InkWell(
                    onTap: () {
                      context.read<ConnectionCubit>().loginWithGoogle();
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: hs * 0.05,
              child: SizedBox(
                  height: ws * 0.5,
                  // width: ws,
                  child: Image.asset('assets/2_dog_ani.gif', fit: BoxFit.fill,)
              ),
            ),


          ],
        ),
      ),
    );
  }
}
