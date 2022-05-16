import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:play_testing/play/play_screen.dart';
import 'package:play_testing/simple_bloc_observer.dart';
import 'package:play_testing/user_data.dart';

void main() {

  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.



  @override
  Widget build(BuildContext context) {
    final user = UserData.fromToData({'u_imgUrl': 'https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/Users%2FPffZKNeyZudEqJbeLyAJCSCuf952?alt=media&token=fe850c0b-6d67-4ce2-a578-bccadf2177bb', 'u_stage4Total': 44, 'itemPlayTime': 11, 'u_stage1Wins': 56, 'u_email': 'google_111133859702709477944_abdullaevfarhodjon@gmail.com', 'itemGoldCoin': 2, 'u_stage5Wins': 0, 'u_stage1Reward': 12, 'u_gold': 0, 'u_stage3Total': 104, 'u_index': 3, 'is_newMail': false, 'is_deleted': false, 'u_coin': 0, 'u_stage2Reward': 18,
      'u_imgUrlHigh': 'https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/Users%2FPffZKNeyZudEqJbeLyAJCSCuf952?alt=media&token=fe850c0b-6d67-4ce2-a578-bccadf2177bb', 'u_stage2Total': 338, 'u_id': 'PffZKNeyZudEqJbeLyAJCSCuf952', 'u_stage4Wins': 14, 'u_lastSeen': '2021-03-26', 'u_stage3Reward': 2, 'u_name': '프래드', 'u_wins': 147, 'itemPurpleCoin': 1, 'u_stage1Total': 907, 'u_stage4Reward': 12, 'u_stage3Wins': 4, 'u_rankPoint': 147, 'u_playCoin': 656, 'u_stage5Reward': 10, 'itemLaserCount': 49, 'u_level': '1', 'u_totalPlayCount': 1413, 'u_stage5Total': 20, 'u_stage2Wins': 73, 'u_stage6Reward': 0, 'u_online': false, 'u_dia': 0, 'itemRotateCount': 900, 'u_silver': 0});
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.yellow.shade700, primarySwatch: Colors.yellow
      ),
      home: PlayScreen(user: user,stage: "stage2"),
    );
  }
}

