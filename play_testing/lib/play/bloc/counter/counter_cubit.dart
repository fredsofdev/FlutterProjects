import 'dart:async';

import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  Timer _timer;

  void startTimer(int initial) {
    emit(initial);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != 0) {
        emit(state - 1);
      } else {
        _timer.cancel();
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  void addTime(int extraTime){
    emit(state + extraTime);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
