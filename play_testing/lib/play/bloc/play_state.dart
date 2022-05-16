part of 'play_bloc.dart';

enum Connection { waiting, your_turn, playing, disconnected }

enum PopUps { initial, success, fail }

enum Orders {
  none,
  connect,
  notEnoughCoin,
  want_to_wait,
}

enum Start{
  none,
  start,
  reset
}

class PlayState extends Equatable {
  const PlayState({
    this.connection = Connection.waiting,
    this.users = const <dynamic>[],
    this.reserves = const <dynamic>[],
    this.machineList = const [],
    this.currentPlayer = const {},
    this.popUps = PopUps.initial,
    this.orders = Orders.none,
    this.start = Start.none,
    this.currentMachine = RoomsList.empty,
    this.userData = UserData.empty,
    this.isClawOpen = true,
    this.stageOn = true,
    this.isInBackground = false,
  });

  final Connection connection;
  final List<dynamic> users;
  final List<dynamic> reserves;
  final List<RoomsList> machineList;
  final RoomsList currentMachine;

  final UserData userData;
  final Map currentPlayer;
  final PopUps popUps;
  final Start start;
  final Orders orders;
  final bool isClawOpen;
  final bool isInBackground;
  final bool stageOn;

  @override
  // TODO: implement props
  List<Object> get props => [
        connection,
        users,
        reserves,
        currentPlayer,
        popUps,
        orders,
        userData,
        machineList,
        start,
        currentMachine,
        isInBackground,
        isClawOpen,
        stageOn
      ];

  PlayState stateUpdate(
      {Connection connection,
      List<dynamic> users,
      List<dynamic> reserves,
      List<RoomsList> machineList,
      Map currentPlayer,
      PopUps popUps,
      Orders orders,
      Start start,
      RoomsList currentMachine,
      UserData userData,
      bool isInBackground,
      bool stageOn,
      bool isClawOpen}) {
    return PlayState(
        connection: connection ?? this.connection,
        users: users != null ? users.toSet().toList() : this.users,
        reserves: reserves ?? this.reserves,
        currentPlayer: currentPlayer ?? this.currentPlayer,
        machineList: machineList ?? this.machineList,
        popUps: popUps ?? this.popUps,
        orders: orders ?? this.orders,
        start: start ?? this.start,
        userData: userData ?? this.userData,
        currentMachine: currentMachine ?? this.currentMachine,
        isInBackground: isInBackground ?? this.isInBackground,
        isClawOpen: isClawOpen ?? this.isClawOpen,
        stageOn: stageOn ?? this.stageOn);
  }
}
