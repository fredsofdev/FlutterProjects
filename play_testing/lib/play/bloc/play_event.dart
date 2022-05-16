part of 'play_bloc.dart';

abstract class PlayEvent extends Equatable {
  const PlayEvent();
}

class ConnectionChanged extends PlayEvent {
  const ConnectionChanged(this.connection);

  final Map connection;

  @override
  // TODO: implement props
  List<Object> get props => [connection];
}

class StartTimerEvent extends PlayEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SetStartNoneEvent extends PlayEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ConnectToServerEvent extends PlayEvent {
  final UserData userData;
  final RoomsList roomData;

  const ConnectToServerEvent(this.roomData, this.userData);

  @override
  // TODO: implement props
  List<Object> get props => [userData, roomData];
}

class MachineDataChangedEvent extends PlayEvent {
  final RoomsList roomData;

  const MachineDataChangedEvent(this.roomData);

  @override
  // TODO: implement props
  List<Object> get props => [roomData];
}

class MachineListChangedEvent extends PlayEvent {
  final List<RoomsList> roomList;

  const MachineListChangedEvent(this.roomList);

  @override
  // TODO: implement props
  List<Object> get props => [roomList];
}

class StartGameEvent extends PlayEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ReserveGameEvent extends PlayEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class EndGameEvent extends PlayEvent {
  final bool playAgain;

  @override
  // TODO: implement props
  List<Object> get props => [playAgain];

  const EndGameEvent(this.playAgain);
}

class SendControlEvent extends PlayEvent {
  final Controls control;

  @override
  // TODO: implement props
  List<Object> get props => [control];

  const SendControlEvent(this.control);
}

class SuccessEvent extends PlayEvent {
  const SuccessEvent(this.isSuccess);

  final bool isSuccess;

  @override
  // TODO: implement props
  List<Object> get props => [isSuccess];
}

class TickerEvent extends PlayEvent {
  final int ticker;

  const TickerEvent(this.ticker);

  @override
  // TODO: implement props
  List<Object> get props => [ticker];
}

class AddTimeEvent extends PlayEvent {
  final int time;

  @override
  // TODO: implement props
  List<Object> get props => [time];

  const AddTimeEvent({this.time = -1});
}

class IsBackgroundEvent extends PlayEvent {
  final bool isBackground;

  @override
  // TODO: implement props
  List<Object> get props => [isBackground];

  const IsBackgroundEvent({this.isBackground});
}
