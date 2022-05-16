import 'package:bloc/bloc.dart';
import 'package:bloc_testing/screen/login/model/nickname.dart';
import 'package:equatable/equatable.dart';
import 'package:/authentication_repository/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository)
      : assert(_authenticationRepository != null),
        super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  AuthCredential googleFacebookCredentials;
  Map<String, Object> kakaoLineData;



  void nicknameChanged(String value){
    final nickname = NickName.dirty(value);
    emit(state.copyWith(
      nickName: nickname,
      nicknameValid: Formz.validate([nickname]),
      status: FormzStatus.submissionInProgress
    ));
  }

  Future<void>  signInWithFacebookGoogleCred() async {
    try {
      var result = await _authenticationRepository.logInWithGoogleFacebookCredentials(googleFacebookCredentials, state.nickName.value);
      if(result == "Ok"){
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      }else{
        emit(state.copyWith(status: FormzStatus.invalid));
      }
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }


  Future<void>  signInWithKakaoLineData() async {
    try {
      var result = await _authenticationRepository.logInWithKakaoLineData(kakaoLineData, state.nickName.value);
      if(result == "Ok"){
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      }else{
        emit(state.copyWith(status: FormzStatus.invalid));
      }
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }


  Future<void> logInWithGoogle() async {
    try {
      var user = await _authenticationRepository.getUserAuth();
      if(user == "anonymous"){
        googleFacebookCredentials = await _authenticationRepository.getGoogleCredential();
        emit(state.copyWith(status: FormzStatus.submissionInProgress, loginType: LoginType.google));
      }else{
        googleFacebookCredentials = await _authenticationRepository.getGoogleCredential();
        var result = await _authenticationRepository.logInWithGoogleFacebookCredentials(googleFacebookCredentials, null);
        if(result == "Ok"){
         emit(state.copyWith(status: FormzStatus.submissionSuccess));
        }
      }

    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }

  Future<void> logInWithFacebook() async {
    try {
      var user = await _authenticationRepository.getUserAuth();
      if(user == "anonymous"){
        googleFacebookCredentials = await _authenticationRepository.getFaceBookCredential();
        emit(state.copyWith(status: FormzStatus.submissionInProgress, loginType: LoginType.facebook));
      }else{
        googleFacebookCredentials = await _authenticationRepository.getFaceBookCredential();
        var result = await _authenticationRepository.logInWithGoogleFacebookCredentials(googleFacebookCredentials, null);
        if(result == "Ok"){
          emit(state.copyWith(status: FormzStatus.submissionSuccess));
        }
      }
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }

  Future<void> logInWithKakao() async {
    try {
      var user = await _authenticationRepository.getUserAuth();
      if(user == "anonymous"){
        kakaoLineData = await _authenticationRepository.getKakaoLoginData();
        emit(state.copyWith(status: FormzStatus.submissionInProgress, loginType: LoginType.kakao));
      }else{
        kakaoLineData = await _authenticationRepository.getKakaoLoginData();
        var result = await _authenticationRepository.logInWithKakaoLineData(kakaoLineData, null);
        if(result == "Ok"){
          emit(state.copyWith(status: FormzStatus.submissionSuccess));
        }
      }
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }


  Future<void> logInWithLine() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      var user = await _authenticationRepository.getUserAuth();
      if(user == "anonymous"){
        kakaoLineData = await _authenticationRepository.getLineLoginData();
        emit(state.copyWith(status: FormzStatus.submissionInProgress, loginType: LoginType.line));
      }else{
        kakaoLineData = await _authenticationRepository.getLineLoginData();
        var result = await _authenticationRepository.logInWithKakaoLineData(kakaoLineData, null);
        if(result == "Ok"){
          emit(state.copyWith(status: FormzStatus.submissionSuccess));
        }
      }
      kakaoLineData = await _authenticationRepository.getLineLoginData();
      emit(state.copyWith(status: FormzStatus.submissionInProgress, loginType: LoginType.line));
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }


}
