part of 'login_cubit.dart';

enum LoginType {kakao, line, google, facebook, unknown}

class LoginState extends Equatable {
  const LoginState({
     this.status = FormzStatus.pure,
    this.nickName = const NickName.pure(),
    this.loginType = LoginType.unknown,
    this.nickNameValid = FormzStatus.invalid

});

  final FormzStatus status;
  final FormzStatus nickNameValid;
  final NickName nickName;
  final LoginType loginType;


  @override
  // TODO: implement props
  List<Object> get props => [status, nickName, loginType];


  LoginState copyWith({
    NickName nickName,
    FormzStatus status,
    LoginType loginType,
    FormzStatus nicknameValid
   }){
    return LoginState(
      status: status ?? this.status,
      nickName:  nickName ?? this.nickName,
      loginType: loginType ?? this.loginType,
      nickNameValid: nicknameValid ?? this.nickNameValid
    );
   }
}


