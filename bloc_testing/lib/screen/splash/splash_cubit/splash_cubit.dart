import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:/authentication_repository/authentication_repository.dart';
import 'package:meta/meta.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._authenticationRepository,
  )  : super(const SplashState.initial()) {
    _resourceSubscription = _authenticationRepository.getResources()
        .listen((process) => _resourceProcessChanged(process));
  }

  void _resourceProcessChanged(String process){
    if(double.tryParse(process) != null){
         emit(SplashState.processing(process));
    }
  }

  final AuthenticationRepository _authenticationRepository;
  StreamSubscription<String> _resourceSubscription;

  @override
  Future<Function> close() {
    _resourceSubscription.cancel();
    return super.close();
  }
}
