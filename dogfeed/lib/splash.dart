
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/src/provider.dart';

import 'connection_cubit.dart';

class Splash extends StatelessWidget {

  static Route route() {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   systemNavigationBarColor: Color.fromRGBO(133, 190, 100, 1),
    // ));
    return MaterialPageRoute<void>(builder: (_) => const Splash());
  }
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final ws = MediaQuery.of(context).size.width;
    final hs = MediaQuery.of(context).size.height;

    return Scaffold(
      // backgroundColor: const Color.fromARGB(0, 125, 175, 96) ,
      // body: Stack(
      //   children: [
      //     SizedBox(
      //       height: hs,
      //       width: ws,
      //       child: GestureDetector(
      //         onTap: (){
      //           context.read<ConnectionCubit>().startListenUser();
      //         },
      //         child: Image.asset(
      //           'assets/1_bg.png',
      //           fit: BoxFit.cover,
      //
      //         ),
      //       )
      //     ),
      //
      //   ],
      // ),
      body: Container(
        height: hs,
        width: ws,
        color: Colors.white,
      ),
    );
  }
}
