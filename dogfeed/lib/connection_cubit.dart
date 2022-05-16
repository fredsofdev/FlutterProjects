import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dogfeed/connection_repo.dart';
import 'package:equatable/equatable.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionsState> {
  ConnectionCubit(
      this._connectionRepository
      ) : super(const ConnectionsState()){
    _connectionRepository.connectToServer();
     _connection = _connectionRepository.conditions.listen((event) {
       if(event.containsKey("notify")) {
         emit(state.copyWith(
             defaultAmount: event['notify']['defaultAmount'],
             weight: (event['notify']['weight']).toDouble(),
             reserves: Map<String, int>.from(event['notify']['reserves']),
             foodTime: event['notify']['foodTime']
         ));
       }else if(event.containsKey("weights")){
         emit(state.copyWith(
             weightList: event['weights']
         ));
       }
     });
    startListenUser();
  }

  final ConnectionRepository _connectionRepository;

  StreamSubscription<Map>? _connection;
  StreamSubscription<bool>? _userSubscription;

  void removeReserves(key){
    _connectionRepository.deleteReserve(key);
  }

  void addReserves(data){
    _connectionRepository.reserve(data, state.defaultAmount);
  }

  void updateVal(data){
    print("Value update $data");
    _connectionRepository.update(data);
    if(data["defaultAmount"] != null){
      emit(state.copyWith(defaultAmount: data['defaultAmount']));
    }
    if(data["foodTime"] != null){
      emit(state.copyWith(foodTime: data['foodTime']));
    }
  }
  void giveFood(){
    _connectionRepository.givefood();
  }

  void loginWithGoogle(){
    _connectionRepository.loginWithGoogle();
  }

  void logout(){
    _connectionRepository.logout();
  }

  void getWeights(){
    _connectionRepository.getWeightList();
  }

  void startListenUser()async{
    _userSubscription?.cancel();
    _userSubscription = (await _connectionRepository.isUser).listen(
            (user){
          print(user);
          emit(state.copyWith(isLoggedIn: user ? AuthState.login : AuthState.logout));
        });
  }

  @override
  Future<void> close() {
    _connection?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }
}
