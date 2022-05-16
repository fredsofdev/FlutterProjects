part of 'friend_cubit.dart';

class FriendState extends Equatable {
  const FriendState(
      {this.friends = const [],
      this.receives = const [],
      this.sends = const [],
      this.searches = const [],
      this.recommends = const [],
      this.listItems = const [],
      this.selectedItems = const [],
      this.errorMsg = "",
      this.searchName = "",
      this.myData = UserData.empty,
      this.friendIndex = 0,
      this.receiveIndex = 0,
      this.sendIndex = 0});

  final List<UserData> friends;
  final List<UserData> receives;
  final List<UserData> sends;
  final List<UserData> searches;
  final List<UserData> recommends;
  final List<Map<String, dynamic>> listItems;
  final List<String> selectedItems;
  final int friendIndex;
  final int sendIndex;
  final int receiveIndex;
  final UserData myData;
  final String errorMsg;
  final String searchName;

  @override
  // TODO: implement props
  List<Object> get props => [
        friends,
        receives,
        sends,
        searches,
        searchName,
        recommends,
        errorMsg,
        myData,
        friendIndex,
        sendIndex,
        receiveIndex,
        listItems,
        selectedItems,
        searchName
      ];

  String _setErrorMsg(ErrorToasts error) {
    if (error == ErrorToasts.friend) {
      return "Already friend.";
    } else if (error == ErrorToasts.request) {
      return "Request in progress.";
    } else if (error == ErrorToasts.success) {
      return "Request Send.";
    }
    return "";
  }

  FriendState updateState(
      {List<UserData>? friends,
      List<UserData>? receives,
      List<UserData>? sends,
      List<UserData>? searches,
      List<UserData>? recommends,
      List<Map<String, dynamic>>? listItems,
      List<String>? selectedItems,
      int? friendIndex,
      int? sendIndex,
      String? searchName,
      int? receiveIndex,
      ErrorToasts? errorToasts,
      UserData? myData}) {
    return FriendState(
        friends: friends ?? this.friends,
        receives: receives ?? this.receives,
        sends: sends ?? this.sends,
        searches: searches ?? this.searches,
        searchName: searchName ?? this.searchName,
        recommends: recommends ?? this.recommends,
        listItems: listItems ?? this.listItems,
        selectedItems: selectedItems ?? this.selectedItems,
        friendIndex: friendIndex ?? this.friendIndex,
        sendIndex: sendIndex ?? this.sendIndex,
        receiveIndex: receiveIndex ?? this.receiveIndex,
        errorMsg: errorToasts == null ? errorMsg : _setErrorMsg(errorToasts),
        myData: myData ?? this.myData);
  }
}

enum ErrorToasts { none, friend, request, success }
