import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class UserData extends Equatable {
  final String uId;
  final String uName;
  final String uLevel;
  final String uImgBig;
  final String uImgSmall;
  final String uLastSeen;
  final String uEmail;
  final bool uOnline;
  final int uCoin;
  final int uPlayCoin;
  final bool isNewMail;
  final int itemPlayTime;
  final int itemPurpleCoin;
  final int itemGoldCoin;
  final int itemRotationCount;
  final int uTotalPlayCount;
  final int uRankPoint;
  final int uWins;
  final Map<String, dynamic> uRewards;
  final int uStage1Total;
  final int uStage2Total;
  final int uStage3Total;
  final int uStage4Total;
  final int uStage5Total;
  final int uStage6Total;
  final int uStage1Wins;
  final int uStage2Wins;
  final int uStage3Wins;
  final int uStage4Wins;
  final int uStage5Wins;
  final int uStage6Wins;

  const UserData({
    required this.uId,
    required this.uName,
    required this.uLevel,
    required this.uImgBig,
    required this.uImgSmall,
    required this.uLastSeen,
    required this.uEmail,
    required this.uCoin,
    required this.uRankPoint,
    required this.uPlayCoin,
    required this.itemPlayTime,
    required this.itemPurpleCoin,
    required this.itemGoldCoin,
    required this.itemRotationCount,
    required this.uTotalPlayCount,
    required this.uWins,
    required this.uOnline,
    required this.isNewMail,
    required this.uRewards,
    required this.uStage1Total,
    required this.uStage2Total,
    required this.uStage3Total,
    required this.uStage4Total,
    required this.uStage5Total,
    required this.uStage6Total,
    required this.uStage1Wins,
    required this.uStage2Wins,
    required this.uStage3Wins,
    required this.uStage4Wins,
    required this.uStage5Wins,
    required this.uStage6Wins,
  })  : assert(uId != null),
        assert(uName != null);

  static const empty = UserData(
      uId: '',
      uName: '',
      uLevel: "",
      uImgBig:
          "https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/Users%2FguestUserImage%2Fdrag_btn.png?alt=media&token=b6eccd4b-d83d-4773-a89d-e42f1bac991f",
      uImgSmall:
          "https://firebasestorage.googleapis.com/v0/b/orangestep-a9bff.appspot.com/o/Users%2FguestUserImage%2Fdrag_btn.png?alt=media&token=b6eccd4b-d83d-4773-a89d-e42f1bac991f",
      uEmail: "",
      uCoin: 0,
      uPlayCoin: 0,
      uOnline: false,
      itemPlayTime: 0,
      uLastSeen: "",
      itemPurpleCoin: 0,
      itemGoldCoin: 0,
      itemRotationCount: 0,
      uRankPoint: 0,
      uWins: 0,
      uTotalPlayCount: 0,
      uRewards: {},
      uStage1Total: 0,
      uStage2Total: 0,
      uStage3Total: 0,
      uStage4Total: 0,
      uStage5Total: 0,
      uStage6Total: 0,
      uStage1Wins: 0,
      uStage2Wins: 0,
      uStage3Wins: 0,
      uStage4Wins: 0,
      uStage5Wins: 0,
      uStage6Wins: 0,
      isNewMail: false);

  factory UserData.fromToData(Map<String, dynamic> data) {
    final Map<String, dynamic> price = {
      'stage1': data['u_stage1Reward'] ,
      'stage2': data['u_stage2Reward'] ,
      'stage3': data['u_stage3Reward'] ,
      'stage4': data['u_stage4Reward'] ,
      'stage5': data['u_stage5Reward'] ,
      'stage6': data['u_stage6Reward'] ,
    };

    return UserData(
        uId: data['u_id'].toString(),
        uName: data['u_name'].toString() ,
        uLevel: data['u_level'].toString() ,
        uImgBig: data['u_imgUrlHigh'].toString() ,
        uImgSmall: data['u_imgUrl'].toString() ,
        uEmail: data['u_email'].toString() ,
        uOnline: data['u_online'] as bool,
        uRankPoint: data.containsKey('u_rankPoint')? data['u_rankPoint'] as int : 0,
        uCoin: data['u_coin'] as int ,
        uLastSeen: data['u_lastSeen'].toString() ,
        uPlayCoin: data['u_playCoin'] as int ,
        itemPlayTime: data['itemPlayTime'] as int ,
        itemPurpleCoin: data.containsKey('itemPurpleCoin')? data['itemPurpleCoin']  as int : 0,
        itemGoldCoin: data.containsKey('itemGoldCoin')? data['itemGoldCoin'] as int: 0,
        itemRotationCount: data.containsKey('itemRotateCount')? data['itemRotateCount'] as int : 0,
        uTotalPlayCount: data.containsKey('u_totalPlayCount')? data['u_totalPlayCount'] as int : 0,
        uWins: data['u_wins'] as int ,
        uRewards: price,
        isNewMail: data['is_newMail'] as bool,
        uStage1Total: data.containsKey('u_stage1Total')? data['u_stage1Total'] as int:0,
        uStage2Total: data.containsKey('u_stage2Total')? data['u_stage2Total'] as int:0,
        uStage3Total: data.containsKey('u_stage3Total')? data['u_stage3Total'] as int:0,
        uStage4Total: data.containsKey('u_stage4Total')? data['u_stage4Total'] as int:0,
        uStage5Total: data.containsKey('u_stage5Total')? data['u_stage5Total'] as int:0,
        uStage6Total: data.containsKey('u_stage6Total')? data['u_stage6Total'] as int:0,
        uStage1Wins: data.containsKey('u_stage1Wins')? data['u_stage1Wins'] as int:0 ,
        uStage2Wins: data.containsKey('u_stage2Wins')? data['u_stage2Wins'] as int:0 ,
        uStage3Wins: data.containsKey('u_stage3Wins')? data['u_stage3Wins'] as int:0 ,
        uStage4Wins: data.containsKey('u_stage4Wins')? data['u_stage4Wins'] as int:0 ,
        uStage5Wins: data.containsKey('u_stage5Wins')? data['u_stage5Wins'] as int:0 ,
        uStage6Wins: data.containsKey('u_stage6Wins')? data['u_stage6Wins'] as int:0 );
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        uId,
        uName,
        uLevel,
        uImgBig,
        uImgSmall,
        uCoin,
        uPlayCoin,
        uLastSeen,
        itemPlayTime,
        itemPurpleCoin,
        itemGoldCoin,
        itemRotationCount,
        uTotalPlayCount,
        uWins,
        uEmail,
        isNewMail,
        uStage1Total,
        uRewards,
        uStage2Total,
        uStage3Total,
        uStage4Total,
        uStage5Total,
        uStage6Total,
        uStage1Wins,
        uStage2Wins,
        uStage3Wins,
        uStage4Wins,
        uStage5Wins,
        uStage6Wins,
      ];
}
