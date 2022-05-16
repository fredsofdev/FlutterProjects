part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, unknown }


class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.status = AuthenticationStatus.unknown,
    this.user = UserData.empty,
    this.notice = const [],
    this.qna = const [],
    this.topUsers = const [],
    this.popularCoupons = const [],
    this.exchangeAd = const {},
    this.reportUrls = const {},
    this.rewardTime = 600,
    this.laserRewardAdCount = 0,
    this.timeRewardAdCount = 0,
    this.chargeRewardAdCount= 0,
  });

  final AuthenticationStatus status;
  final UserData user;
  final int rewardTime;
  final int laserRewardAdCount;
  final int timeRewardAdCount;
  final int chargeRewardAdCount;
  final List<Map<String, dynamic>> notice;
  final Map<String, dynamic> exchangeAd;
  final Map<String, dynamic> reportUrls;
  final List<Map<String, dynamic>> qna;
  final List<Map<String, dynamic>> topUsers;
  final List<Map<String, dynamic>> popularCoupons;

  AuthenticationState updateAuthState({
    AuthenticationStatus? status,
    UserData? user,
    int? rewardTime,
    int? laserRewardAdCount,
    int? timeRewardAdCount,
    int? chargeRewardAdCount,
    List<Map<String, dynamic>>? notice,
    List<Map<String, dynamic>>? qna,
    List<Map<String, dynamic>>? topUsers,
    List<Map<String, dynamic>>? popularCoupons,
    Map<String, dynamic>? exchangeAd,
    Map<String, dynamic>? reportUrls,
  }) {
    return AuthenticationState(
        reportUrls: reportUrls ?? this.reportUrls,
        status: status ?? this.status,
        user: user ?? this.user,
        rewardTime: rewardTime ?? this.rewardTime,
        notice: notice ?? this.notice,
        qna: qna ?? this.qna,
        topUsers: topUsers ?? this.topUsers,
        popularCoupons: popularCoupons ?? this.popularCoupons,
        chargeRewardAdCount: chargeRewardAdCount ?? this.chargeRewardAdCount ,
        exchangeAd: exchangeAd ?? this.exchangeAd,
        laserRewardAdCount: laserRewardAdCount ?? this.laserRewardAdCount,
        timeRewardAdCount: timeRewardAdCount ?? this.timeRewardAdCount);
  }

  @override
  List<Object> get props => [
        status,
        user,
        notice,
        qna,
        topUsers,
        popularCoupons,
        exchangeAd,
        reportUrls,
        rewardTime,
        laserRewardAdCount,
        timeRewardAdCount,
        chargeRewardAdCount
      ];
}
