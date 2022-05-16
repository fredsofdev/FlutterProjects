import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/authentication_repository.dart';
import 'package:equatable/equatable.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._authenticationRepository,
  ) : super(const SplashState()) {
    _checkResourceStatus();
  }

  Future<void> _checkResourceStatus() async {
    final ResourcesStatus status =
        await _authenticationRepository.checkResourceStatue();
    if (status == ResourcesStatus.not_downloaded) {
      emit(state.updateState(status: status));
    } else if (status == ResourcesStatus.downloaded) {
      emit(state.updateState(percentage: "1.0", process: ResourceProcess.done));
    }
  }

  void _resourceProcessChanged(String process) {
    if (double.tryParse(process.split('%')[0]) != null) {
      emit(state.updateState(
          percentage: process, process: ResourceProcess.processing));
    } else if (process == "Done" || process == "Downloaded") {
      emit(state.updateState(percentage: "1.0", process: ResourceProcess.done));
    }
  }

  void getResources() {
    _resourceSubscription = _authenticationRepository
        .getResources()
        .listen((process) => _resourceProcessChanged(process));
  }

  final AuthenticationRepository _authenticationRepository;
  StreamSubscription<String>? _resourceSubscription;

  @override
  Future<void> close() {
    _resourceSubscription?.cancel();
    return super.close();
  }
}
