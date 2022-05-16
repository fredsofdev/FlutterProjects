part of 'login_cubit.dart';

enum LoginLoading { initial, loading }

enum LoginProcess { initial, receivedCred, failed }

class LoginState extends Equatable {
  const LoginState(
      {this.process = LoginProcess.initial,
      this.nickName = const NickName.pure(),
      this.nickNameValid = NickNameValidation.empty,
      this.errorMessage = "Empty ..",
      this.loading = LoginLoading.initial});

  final LoginProcess process;
  final NickNameValidation nickNameValid;
  final NickName nickName;
  final String errorMessage;
  final LoginLoading loading;

  String _setErrorMsg(NickNameValidation error) {
    if (error == NickNameValidation.empty) {
      return "닉네임을 입력해주세요.";
    } else if (error == NickNameValidation.exist) {
      return "이미 존재하는 닉네임 입니다.";
    } else if (error == NickNameValidation.notmatch) {
      return "한글, 영어, 숫자 입력 가능";
    } else if (error == NickNameValidation.more) {
      return "15글자 이상의 닉네임은 입력 할 수 없습니다.";
    } else if (error == NickNameValidation.less) {
      return "2글자 이상의 닉네임을 입력하세요.";
    }
    return "";
  }

  @override
  // TODO: implement props
  List<Object> get props =>
      [process, nickName, nickNameValid, errorMessage, loading];

  LoginState copyWith(
      {NickName? nickName,
      LoginProcess? process,
      NickNameValidation? nicknameValid,
      LoginLoading? loading}) {
    return LoginState(
        process: process ?? this.process,
        nickName: nickName ?? this.nickName,
        nickNameValid: nicknameValid ?? nickNameValid,
        errorMessage: nicknameValid == null
            ? _setErrorMsg(nickNameValid)
            : _setErrorMsg(nicknameValid),
        loading: loading ?? this.loading);
  }
}
