import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/models/user_data.dart';
import 'package:catchchanceio/repository/play/connection_repository.dart';
import 'package:catchchanceio/repository/play/model/rooms_list.dart';
import 'package:catchchanceio/repository/play/play_repository.dart';
import 'package:equatable/equatable.dart';


part 'play_event.dart';

part 'play_state.dart';

class PlayBloc extends Bloc<PlayEvent, PlayState> {
  PlayBloc(this._playRepository, this._connectionRepository, this._stage, this.user)
      :super(const PlayState()) {
    _connection = _connectionRepository.conditions.listen((event) {
      add(ConnectionChanged(event));
    });
    getMachineList();
  }

  final ConnectionRepository _connectionRepository;
  final PlayRepository _playRepository;
  final String _stage;
  final UserData user;
  StreamSubscription<Map>? _connection;
  Timer? _ticker;

  @override
  Stream<PlayState> mapEventToState(
      PlayEvent event,
      ) async* {
    if (event is ConnectToServerEvent) {
      yield state.stateUpdate(currentMachine: RoomsList.empty);
      yield state.stateUpdate(connection: Connection.waiting);
      add(MachineDataChangedEvent(event.roomData));
      _connectionRepository.connectToServer(event.roomData, {
        'id': event.userData.uId,
        'name': event.userData.uName,
        'url': event.userData.uImgSmall
      });
      yield state.stateUpdate(userData: event.userData);
    }
    else if (event is MachineDataChangedEvent) {
      yield state.stateUpdate(currentMachine: event.roomData);
    }
    else if (event is MachineListChangedEvent) {
      if(state.currentMachine == RoomsList.empty){
        final rng = Random();
        final roomData = event.roomList[rng.nextInt(event.roomList.length)];
        add(ConnectToServerEvent(roomData,user));
      }
      yield state.stateUpdate(machineList: event.roomList);
    }
    else if (event is ReserveGameEvent) {
      _connectionRepository.reserveGame();
    }
    else if (event is IsBackgroundEvent) {
      yield state.stateUpdate(isInBackground: event.isBackground);
    }
    else if (event is SetStartNoneEvent) {
      yield state.stateUpdate(start: Start.none);
    }
    else if (event is SendControlEvent) {
      _connectionRepository.sendControl(event.control);
    }
    else if (event is BackgroundTickerEvent) {
      if(state.connection != Connection.playing){
        _ticker?.cancel();
      }

      if(event.ticker == -1 || _ticker!.isActive){
        if(state.backgroundTick == 0){
          _ticker?.cancel();
        }
        if(state.backgroundTick == 5){
          add(const SendControlEvent(Controls.capStart));
        }
        if(state.backgroundTick == 1){
          add(const SendControlEvent(Controls.submit));
        }
        yield state.stateUpdate(backgroundTick: state.backgroundTick -1);
      }else{
        yield state.stateUpdate(backgroundTick: event.ticker);
        if(state.backgroundTick == 5){
          add(const SendControlEvent(Controls.capStart));
        }
        if(state.backgroundTick == 1){
          add(const SendControlEvent(Controls.submit));
        }
      }
    }
    else if (event is StartGameEvent) {
      final PayResult result = await _playRepository.checkPayForGame(
          state.userData.uId, state.currentMachine.mPrice!, state.currentMachine.mCoin!);
      if (result == PayResult.SUCCESS) {
        _connectionRepository.startGame(true);
      } else {
        _connectionRepository.cancelGame();
        yield state.stateUpdate(orders: Orders.notEnoughCoin);
        yield state.stateUpdate(orders: Orders.none);
        yield state.stateUpdate(connection: Connection.waiting);
      }
    }
    else if (event is EndGameEvent) {
      if (event.playAgain) {
        yield state.stateUpdate(isClawOpen: true);
        add(StartGameEvent());
      } else {
        if (state.connection == Connection.playing) {
          _connectionRepository.cancelGame();
          yield state.stateUpdate(
              connection: Connection.waiting, isClawOpen: true);
        } else {
          _connectionRepository.cancelGame();
          yield state.stateUpdate(connection: Connection.waiting);
        }
      }
    }
    else if (event is SuccessEvent) {
      if (state.isInBackground) {
        _ticker?.cancel();
        _playRepository.playerAddReport(
            event.isSuccess, state.userData.uId, state.currentMachine.mName!, {
          'stage': state.currentMachine.mStage!,
          'prize': state.currentMachine.mPrize!,
          'coin': state.currentMachine.mCoin!
        });
        add(const EndGameEvent(false));
      } else {
        _ticker?.cancel();
        _playRepository.playerAddReport(
            event.isSuccess, state.userData.uId, state.currentMachine.mName!, {
          'stage': state.currentMachine.mStage!,
          'prize': state.currentMachine.mPrize!,
          'coin': state.currentMachine.mCoin!
        });
        yield state.stateUpdate(
            popUps: event.isSuccess ? PopUps.success : PopUps.fail);
        yield state.stateUpdate(popUps: PopUps.initial);
      }
    }
    else if (event is ConnectionChanged) {
      switch (event.connection['connection'] as ConnectionConditions) {
        case ConnectionConditions.connected:
          if (state.connection == Connection.waiting ||
              state.connection == Connection.playing) {
            final previous = state.connection;
            yield state.stateUpdate(connection: Connection.connected, connectionSession: event.connection['data'] as int);
            yield state.stateUpdate(connection: previous);
          }
          break;
        case ConnectionConditions.disconnected:
          yield state.stateUpdate(connection: Connection.disconnected);
          break;
        case ConnectionConditions.your_turn:
          yield state.stateUpdate(connection: Connection.your_turn);
          break;
        case ConnectionConditions.confirm_play:

          if(event.connection['data'] == "resetting"){
            yield state.stateUpdate(start: Start.reset);
          } else if(event.connection['data'] == "ready") {
            yield state.stateUpdate(start: Start.start);
          } else if(event.connection['data'] == "start") {
            yield state.stateUpdate(connection: Connection.playing, isClawOpen: true);
            _playRepository.payForGame(
                state.userData.uId, state.currentMachine.mPrice!,
                state.currentMachine.mCoin!);
          }
          break;
        case ConnectionConditions.want_to_wait:
          yield state.stateUpdate(orders: Orders.want_to_wait);
          yield state.stateUpdate(orders: Orders.none);
          break;
        case ConnectionConditions.users_update:
          final listUsers = event.connection['data'] as List;
          listUsers.removeWhere((element) => element == "video");
          yield state.stateUpdate(users: listUsers);
          break;
        case ConnectionConditions.reserves_update:
          yield state.stateUpdate(reserves: event.connection['data'] as List);
          break;
        case ConnectionConditions.current_player:
          yield state.stateUpdate(
              currentPlayer: event.connection['data'] as Map);
          break;
        case ConnectionConditions.request:
          if (event.connection['data'] == ServerRequests.release_finish) {
            if(state.isClawOpen == true){
              yield state.stateUpdate(orders: Orders.claw);
              yield state.stateUpdate(orders: Orders.none);
            }
            yield state.stateUpdate(isClawOpen: true);
          } else if (event.connection['data'] == ServerRequests.grab_finish) {
            if(state.isClawOpen == false){
              yield state.stateUpdate(orders: Orders.claw);
              yield state.stateUpdate(orders: Orders.none);
            }
            yield state.stateUpdate(isClawOpen: false);
          } else if (event.connection['data'] == ServerRequests.success) {
            add(const SuccessEvent(true));
          } else if (event.connection['data'] == ServerRequests.fail) {
            add(const SuccessEvent(false));
          }
          break;
        default:
        // yield state.stateUpdate(connection: Connection.waiting);
          break;
      }
    }
  }

  void startTimer(int initial) {
    add(BackgroundTickerEvent(initial));

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const BackgroundTickerEvent(-1));
    });
  }

  void cancelBackgroundTicker(){
    _ticker?.cancel();
  }

  @override
  Future<void> close() {
    _connectionRepository.close();
    _connection?.cancel();
    _ticker?.cancel();
    return super.close();
  }

  Future<AddItemResult> addPlayTime(){
    return _playRepository.addPlayTime(state.userData.uId, -1);
  }

  Future<void> getMachineList() async{
    final list = await _playRepository.listRooms(_stage, "playerLow");
    add(MachineListChangedEvent(list));
  }
}
