import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class UserData extends Equatable {
  final String uId;
  final String uName;
  final String uLevel;
  final String uImgBig;
  final String uImgSmall;
  final int uCoin;
  final int uBronze;
  final int uDia;
  final int uGold;
  final int uSilver;
  final String uAuthType;

  const UserData({
     @required this.uId,
      @required this.uName,
      @required this.uLevel,
      @required this.uImgBig,
      @required this.uImgSmall,
      @required this.uCoin,
      @required this.uBronze,
      @required this.uDia,
      @required this.uGold,
      @required this.uSilver,
      @required this.uAuthType}) : assert(uId != null),
                                 assert(uName != null);


  static const empty = UserData(uId : '',uName: '',uLevel: null ,uImgBig: null,uImgSmall: null,
      uCoin: null,uBronze: null,uDia: null,uGold: null,uSilver: null, uAuthType: "unknown",);

  @override
  // TODO: implement props
  List<Object> get props => [uId,uName,uLevel,uImgBig,uImgSmall,
    uCoin,uBronze,uDia,uGold,uSilver, uAuthType];


}
