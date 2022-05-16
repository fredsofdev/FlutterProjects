import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/authentication_repository.dart';
import 'package:catchchanceio/repository/authentication/models/user_data.dart';
import 'package:catchchanceio/screen/login/model/nickname.dart';
import 'package:date_format/date_format.dart';
import 'package:equatable/equatable.dart';


part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  :_authenticationRepository = authenticationRepository,
        super(const AuthenticationState()) {
    add(GetNotice());
    startTimer();
  }

  final AuthenticationRepository? _authenticationRepository;
  StreamSubscription<UserData>? _userSubscription;
  Timer? _ticker;
  Timer? _ticker2;
  Timer? _ticker4;

  get user => null;

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationUserChanged) {
      yield _mapAuthenticationUserChangedToState(event);
    } else if (event is AuthenticationLogoutRequested) {
      unawaited(_authenticationRepository!.logOut());
    } else if (event is AuthenticationDelete) {
      unawaited(_authenticationRepository!.deleteUser());
    } else if (event is GetQNA) {
      final data = await _authenticationRepository!.listQNA(state.user.uId);
      yield state.updateAuthState(qna: data.isEmpty ? [] : data);
    } else if (event is TimeAdRewardEvent) {
      yield state.updateAuthState(timeRewardAdCount: 5);
      startTimerForAdRewardTimer();
    } else if (event is ChargeAdRewardTickerEvent) {
      if (state.chargeRewardAdCount > 0) {
        yield state.updateAuthState(
            chargeRewardAdCount: state.chargeRewardAdCount - 1);
      }
    } else if (event is ChargeAdRewardEvent) {
      yield state.updateAuthState(chargeRewardAdCount: 5);
      startTimerForAdRewardCharge();
    } else if (event is TimeAdRewardTickerEvent) {
      if (state.timeRewardAdCount > 0) {
        yield state.updateAuthState(
            timeRewardAdCount: state.timeRewardAdCount - 1);
      }
    } else if (event is TickerEvent) {
      if (state.rewardTime == 0) {
        await _authenticationRepository!
            .giveTimePassReward(state.exchangeAd['auto_charge'] as int);
        yield state.updateAuthState(rewardTime: 600);
      } else {
        yield state.updateAuthState(rewardTime: state.rewardTime - 1);
      }
    } else if (event is PostQNA) {
      final data = {
        'user_id': state.user.uId,
        'title': event.title,
        'question': event.question,
        'answer': "",
        'q_reg_date': formatDate(
            DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            [yyyy, '-', mm, '-', dd]),
        'a_reg_date': "",
        'is_answered': false
      };
      await _authenticationRepository!.postQNA(data);
      final List<Map<String, dynamic>> list = [];
      list.addAll(state.qna);
      list.add(data);
      yield state.updateAuthState(qna: list);
    } else if (event is GetNotice) {
      final data = await _authenticationRepository!.listNotice();
      if (data.isNotEmpty) {
        yield state.updateAuthState(notice: data);
      }
      final rewards =
          await _authenticationRepository!.getAdRewards(state.user.uId);
      yield state.updateAuthState(exchangeAd: rewards);
      final reports =
          await _authenticationRepository!.getReportUrls(state.user.uId);
      yield state.updateAuthState(reportUrls: reports);
      final topUsers =
          await _authenticationRepository!.getTopUsers();
      yield state.updateAuthState(topUsers: topUsers);

      final popularCoupons =
      await _authenticationRepository!.getPopularCoupons();
      yield state.updateAuthState(popularCoupons: popularCoupons);
    } else if (event is StartAuthenticationListener) {
      await _userSubscription?.cancel();
      _userSubscription = _authenticationRepository!.user.listen(
        (user) => add(AuthenticationUserChanged(user)),
      );
    }
  }

  void startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.user != UserData.empty) {
        add(TickerEvent());
      }
    });
  }

  void startTimerForAdRewardTimer() {
    _ticker2?.cancel();
    _ticker2 = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.user != UserData.empty && timer.tick % 60 == 0) {
        add(TimeAdRewardTickerEvent());
        if (timer.tick % 300 == 0) timer.cancel();
      }
    });
  }

  void startTimerForAdRewardCharge() {
    _ticker4?.cancel();
    _ticker4 = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.user != UserData.empty && timer.tick % 60 == 0) {
        add(ChargeAdRewardTickerEvent());
        if (timer.tick % 300 == 0) timer.cancel();
      }
    });
  }


  @override
  Future<void> close() {
    setUserOffline();
    _ticker!.cancel();
    _ticker2!.cancel();
    _ticker4!.cancel();
    _authenticationRepository!.close();
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> setUserOffline() async {
    await _authenticationRepository!.setUserOffline(state.user.uId);
  }

  Future<String> updateNickname(String name) {
    final result = NickName.dirty(name);
    if (result.error == NickNameValidation.valid) {
      return _authenticationRepository!.updateNickname(name);
    } else {
      return Future<String>.value(_setErrorMsg(result.error!));
    }
  }

  String _setErrorMsg(NickNameValidation error) {
    if (error == NickNameValidation.empty) {
      return "닉네임을 입력해주세요.";
    } else if (error == NickNameValidation.notmatch) {
      return "한글, 영어, 숫자만 입력 가능";
    } else if (error == NickNameValidation.more) {
      return "15글자 이상의 닉네임은 입력 할 수 없습니다.";
    } else if (error == NickNameValidation.less) {
      return "2글자 이상의 닉네임을 입력하세요.";
    }
    return "";
  }

  Future<String> updateImg(File img) {
    return _authenticationRepository!.updateUserPhoto(state.user.uId, img);
  }

  AuthenticationState _mapAuthenticationUserChangedToState(
    AuthenticationUserChanged event,
  ) {
    if (event.user == UserData.empty) {
      return state.updateAuthState(
          status: AuthenticationStatus.unauthenticated);
    } else {
      if (event.user.uPlayCoin > (state.exchangeAd['max_auto_charge'] as int) &&
          _ticker!.isActive) {
        _ticker?.cancel();
        return state.updateAuthState(
            status: AuthenticationStatus.authenticated,
            user: event.user,
            rewardTime: 600);
      } else if (event.user.uPlayCoin <=
              (state.exchangeAd['max_auto_charge'] as int) &&
          !_ticker!.isActive) {
        startTimer();
      }
      int gap = 86400000;
      if(int.tryParse(event.user.uLastSeen) != null) {
         gap = DateTime
            .now()
            .millisecondsSinceEpoch - int.parse(event.user.uLastSeen);
      }
      if (gap > 86400000) {
        _authenticationRepository!.sendItemMail(gap);
      }
      return state.updateAuthState(
          status: AuthenticationStatus.authenticated, user: event.user);
    }
  }
}
