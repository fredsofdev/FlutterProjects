import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:play_testing/connection_repository.dart';
import 'package:play_testing/rooms_list.dart';
import 'package:play_testing/user_data.dart';

part 'play_event.dart';

part 'play_state.dart';

class PlayBloc extends Bloc<PlayEvent, PlayState> {
  PlayBloc(this._connectionRepository, this.user)
      : assert(_connectionRepository != null),
        super(const PlayState()) {
    _connection = _connectionRepository.conditions.listen((event) {
      add(ConnectionChanged(event));
    });
    getMachineList();
  }

  final ConnectionRepository _connectionRepository;
  final UserData user;
  StreamSubscription<Map> _connection;

  @override
  Stream<PlayState> mapEventToState(
    PlayEvent event,
  ) async* {
    if (event is ConnectToServerEvent) {
      yield state.stateUpdate(currentMachine: RoomsList.empty);
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
    else if (event is StartGameEvent) {
      if (true) {
        _connectionRepository.startGame(true);
      }
      // else {
      //   _connectionRepository.cancelGame();
      //   yield state.stateUpdate(orders: Orders.notEnoughCoin);
      //   yield state.stateUpdate(orders: Orders.none);
      //   yield state.stateUpdate(connection: Connection.waiting);
      // }
    }
    else if (event is EndGameEvent) {
      if (event.playAgain) {
        yield state.stateUpdate(isClawOpen: true);
        _connectionRepository.sendControl(Controls.stopPlay);
        _connectionRepository.sendControl(Controls.laserOn);
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
        // _playRepository.playerAddReport(
        //     event.isSuccess, state.userData.uId, state.currentMachine.mName, {
        //   'stage': state.currentMachine.mStage,
        //   'prize': state.currentMachine.mPrize,
        //   'coin': state.currentMachine.mCoin
        // });
        add(const EndGameEvent(false));
      } else {
        // _playRepository.playerAddReport(
        //     event.isSuccess, state.userData.uId, state.currentMachine.mName, {
        //   'stage': state.currentMachine.mStage,
        //   'prize': state.currentMachine.mPrize,
        //   'coin': state.currentMachine.mCoin
        // });
        yield state.stateUpdate(
            popUps: event.isSuccess ? PopUps.success : PopUps.fail);
        yield state.stateUpdate(popUps: PopUps.initial);
      }
    }
    else if (event is ConnectionChanged) {
      switch (event.connection['connection'] as ConnectionConditions) {
        case ConnectionConditions.connected:
          if (state.connection == Connection.waiting ||
              state.connection == Connection.disconnected) {
            yield state.stateUpdate(connection: Connection.waiting);
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
             _connectionRepository.sendControl(Controls.laserOn);
            yield state.stateUpdate(start: Start.start);
          } else if(event.connection['data'] == "start") {
             yield state.stateUpdate(connection: Connection.playing);
             // _playRepository.payForGame(
             //     state.userData.uId, state.currentMachine.mPrice,
             //     state.currentMachine.mCoin);
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
            yield state.stateUpdate(isClawOpen: true);
          } else if (event.connection['data'] == ServerRequests.grab_finish) {
            yield state.stateUpdate(isClawOpen: false);
          } else if (event.connection['data'] == ServerRequests.stage_on) {
            yield state.stateUpdate(stageOn: true);
          } else if (event.connection['data'] == ServerRequests.stage_off) {
            yield state.stateUpdate(stageOn: false);
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

  @override
  Future<void> close() {
    _connectionRepository.close();
    _connection?.cancel();
    return super.close();
  }

  Future<AddItemResult> addPlayTime(){
   // return _playRepository.addPlayTime(state.userData.uId, -1);
    return Future.value(AddItemResult.SUCCESS);
  }

  Future<void> getMachineList() async{
      // final list = await _playRepository.listRooms(_stage, "playerLow");
      final list = [{'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 101, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '380765424224233409723213', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 102, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '102275381599014966811368', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 104, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '669044371960592442583687', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 106, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '328366898937148812856810', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 107, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '579354742820696270041881', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 108, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '149233511914272292999995', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 109, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '374098367559586395436571', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 110, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '691218955543887303095327', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0},
        {'m_coin': 'play_coin', 'm_currentPlayers': 0, 'm_id': 112, 'm_ip': '3.35.68.27', 'm_lastCheckDate': '2020-00-00 00:00:00', 'm_maxPlayer': '10', 'm_playTimeSec': '45', 'm_port': '8451', 'm_price': 1, 'm_prize': 1, 'm_stage': 'stage2', 'm_state': 'running', 'm_streamId': '700667686720423463964715', 'm_totalPlayTimeMin': 0, 'm_videoUrl': 'http://3.34.148.99:5000/?name=', 'm_visits': 0, 'm_wanIp': '218.146.238.40', 'm_wins': 0}];
      final List<RoomsList> newList = [];
      list.forEach((value) {
        newList.add(RoomsList.fromMap(value));
      });
      add(MachineListChangedEvent(newList));
  }
}


enum AddItemResult { FAIL, SUCCESS, NOT_ENOUGH }