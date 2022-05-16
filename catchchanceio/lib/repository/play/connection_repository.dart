import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'model/rooms_list.dart';

enum ConnectionConditions {
  connected,
  disconnected,
  your_turn,
  users_update,
  want_to_wait,
  reserves_update,
  current_player,
  confirm_play,
  success,
  machine_off,
  request
}

class ConnectionRepository {
  Future<void> connectToServer(
      RoomsList roomData, Map<String, String> userData) async {
    final rawHeader = {'tokenpassword': 'dhfpswltmxpqserver'};
    _socket?.disconnect();
    _socket = io.io(
        'http://${roomData.mIp}:${roomData.mPort}/${roomData.mName}',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders(rawHeader)
            .build());
    _socket!.connect();
    _socket!.on('connect', (_) {
      _socket!.emit('user_enter', {
        'uid': userData['id'],
        'room': roomData.mName,
        'name': userData['name'],
        'url': userData['url'],
      });
      _streamController.sink
          .add({'connection': ConnectionConditions.connected, 'data': DateTime.now().millisecondsSinceEpoch});
      _socket!.emit('start_video');
    });

    // _socket!.on('disconnect', (_) {
    //   _streamController.sink.add({'connection':ConnectionConditions.disconnected, 'data': null});
    // });

    // _socket!.on('on_disconnect', (data) async{
    //   print("Disconnected with reason " + data.toString());
    //   _socket!.disconnect();
    // });

    _socket!.on('you_turn', (_) {
      _streamController.sink
          .add({'connection': ConnectionConditions.your_turn, 'data': null});
    });

    _socket!.on('want_to_wait', (_) {
      _streamController.sink
          .add({'connection': ConnectionConditions.want_to_wait, 'data': null});
    });

    _socket!.on('users_update', (data) {
      _streamController.sink
          .add({'connection': ConnectionConditions.users_update, 'data': data});
    });
    _socket!.on('reserves_update', (data) {
      _streamController.sink.add(
          {'connection': ConnectionConditions.reserves_update, 'data': data});
    });
    _socket!.on('current_player', (data) {
      _streamController.sink.add(
          {'connection': ConnectionConditions.current_player, 'data': data});
    });
    _socket!.on('confirm_play', (data) {
      _streamController.sink
          .add({'connection': ConnectionConditions.confirm_play, 'data': data});
    });

    _socket!.on('notify_player', (data) {
      _streamController.sink.add({
        'connection': ConnectionConditions.request,
        'data': ServerRequests.values
            .firstWhere((e) => e.toString() == 'ServerRequests.$data')
      });
    });

    // _socket!.on('machine_off', (_) {
    //   _streamController.sink.add({'connection':ConnectionConditions.machine_off, 'data': null});
    // });

    // _socket!.on('success', (data) {
    //   _streamController.sink.add({'connection':ConnectionConditions.success, 'data': null});
    // });
  }

  io.Socket? _socket;
  final _streamController = StreamController<Map>();

  Stream<Map> get conditions => _streamController.stream;

  void sendControl(Controls control) {
    _socket!
        .emit('send_control', {'control': control.toString().split('.').last});
  }

  void startGame(bool laser) {
    _socket!.emit('start_game', {'laser': laser, 'stage': false});
  }

  void cancelGame() {
    _socket!.emit('cancel_game');
  }

  void reserveGame() {
    _socket!.emit('reserve');
  }

  Future<void> close() async {
    _streamController.close();
    _socket?.clearListeners();
    _socket?.dispose();
    _socket?.destroy();
  }
}

enum Controls {
  forward,
  backward,
  left,
  right,
  down,
  up,
  grab,
  release,
  capStart,
  capCancel,
  submit,
  stop
}

enum ServerRequests {
  grab_finish,
  release_finish,
  success,
  fail
}
