import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/authentication_repository.dart';
import 'package:catchchanceio/screen/login/model/nickname.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository)
      : assert(_authenticationRepository != null),
        super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  late Map<String, Object> providerData;
  bool isSignInPressed = false;

  void nicknameChanged(String value) {
    final nickname = NickName.dirty(value);
    emit(state.copyWith(
      nickName: nickname,
      nicknameValid: nickname.error!,
    ));
  }

  Future<void> signInWithProviderData() async {
    emit(state.copyWith(loading: LoginLoading.loading));
    try {
      if (!isSignInPressed) {
        isSignInPressed = true;
        final result = await _authenticationRepository.logInWithNickname(
            providerData, state.nickName.value);
        if (result == "Ok") {
          emit(state.copyWith(loading: LoginLoading.initial));
          isSignInPressed = false;
        } else {
          emit(state.copyWith(
              loading: LoginLoading.initial,
              nicknameValid: NickNameValidation.exist));
          isSignInPressed = false;
        }
      }
    } on Exception {
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.failed));
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.initial));
      isSignInPressed = false;
    }
  }

  Future<void> logInWithGoogle() async {
    try {
      providerData = await _authenticationRepository.getGoogleCredential();
      final bool user = await _authenticationRepository
          .isUserExist(providerData['email'].toString());
      if (user) {
        emit(state.copyWith(loading: LoginLoading.loading));
        final result = await _authenticationRepository.logInWithNickname(
            providerData, null);
        if (result == "Ok") {
          emit(state.copyWith(loading: LoginLoading.initial));
        }
      } else {
        emit(state.copyWith(process: LoginProcess.receivedCred));
      }
    } on Exception {
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.failed));
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.initial));
    }
  }

  Future<void> logInWithFacebook() async {
    try {
      providerData = await _authenticationRepository.getFaceBookCredential();
      final bool user = await _authenticationRepository
          .isUserExist(providerData['email'].toString());
      if (user) {
        emit(state.copyWith(loading: LoginLoading.loading));
        final result = await _authenticationRepository.logInWithNickname(
            providerData, null);
        if (result == "Ok") {
          emit(state.copyWith(loading: LoginLoading.initial));
        }
      } else {
        emit(state.copyWith(process: LoginProcess.receivedCred));
      }
    } on Exception {
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.failed));
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.initial));
    }
  }

  Future<void> logInWithKakao() async {
    try {
      providerData = await _authenticationRepository.getKakaoLoginData();
      final bool user = await _authenticationRepository
          .isUserExist(providerData['email'].toString());
      if (user) {
        emit(state.copyWith(loading: LoginLoading.loading));
        final result = await _authenticationRepository.logInWithNickname(
            providerData, null);
        if (result == "Ok") {
          emit(state.copyWith(loading: LoginLoading.initial));
        }
      } else {
        emit(state.copyWith(process: LoginProcess.receivedCred));
      }
    } on Exception {
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.failed));
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.initial));
    }
  }

  Future<void> logInWithLine() async {
    try {
      providerData = await _authenticationRepository.getLineLoginData();
      final bool user = await _authenticationRepository
          .isUserExist(providerData['email'].toString());
      if (user) {
        emit(state.copyWith(loading: LoginLoading.loading));
        final result = await _authenticationRepository.logInWithNickname(
            providerData, null);
        if (result == "Ok") {
          emit(state.copyWith(loading: LoginLoading.initial));
        }
      } else {
        emit(state.copyWith(process: LoginProcess.receivedCred));
      }
    } on Exception {
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.failed));
      emit(state.copyWith(
          loading: LoginLoading.initial, process: LoginProcess.initial));
    }
  }
}
