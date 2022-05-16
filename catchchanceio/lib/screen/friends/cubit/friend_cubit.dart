import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/friend_repository.dart';
import 'package:catchchanceio/repository/authentication/models/user_data.dart';
import 'package:equatable/equatable.dart';

part 'friend_state.dart';

class FriendCubit extends Cubit<FriendState> {
  FriendCubit(this._friendRepository, UserData myData)
      : assert(_friendRepository != null),
        super(const FriendState()) {
    emit(state.updateState(myData: myData));

    getFriends();
    getReceives();
    getSends();
    getRecommendedUsers();
    getItems();
  }

  Future<void> getItems() async {
    final List<Map<String, dynamic>> data =
        await _friendRepository.listInventory(state.myData.uId);
    if (data.isNotEmpty) {
      emit(state.updateState(listItems: data));
    }
  }

  void selectItem(String id, bool isSelected) {
    final List<String> data = [];
    if (state.selectedItems.isNotEmpty) {
      data.addAll(state.selectedItems);
    }
    if (isSelected) {
      data.add(id);
    } else {
      data.remove(id);
    }
    emit(state.updateState(selectedItems: data));
  }

  void resetSelected() {
    final List<Map<String, dynamic>> dataEmit = [];
    dataEmit.addAll(state.listItems);
    dataEmit
        .removeWhere((element) => state.selectedItems.contains(element['id']));
    emit(state.updateState(listItems: dataEmit));
    emit(state.updateState(selectedItems: []));
  }

  Future<bool> giveCoupon(String uid) async {
    if (state.selectedItems.isNotEmpty) {
      final List<Map<String, dynamic>> data = [];
      data.addAll(state.listItems);
      data.removeWhere(
          (element) => !state.selectedItems.contains(element['id']));
      await _friendRepository.sendGift(
          uid, data, state.myData.uName, state.myData.uImgSmall);
      return true;
    }
    return false;
  }

  Future<void> getRecommendedUsers() async {
    final List<UserData> data =
        await _friendRepository.getFriendRecommendations(state.myData.uId);
    data.removeWhere((element) => element == null);
    emit(state.updateState(recommends: data));
  }

  Future<void> getFriends() async {
    final List<UserData> data =
        await _friendRepository.getFriends(state.myData.uId, state.friendIndex);
    if (data.isNotEmpty) {
      emit(state.updateState(
          friends: data, friendIndex: state.friendIndex + 20));
    }
  }

  Future<void> getReceives() async {
    final List<UserData> data = await _friendRepository.getReceivedRequests(
        state.myData.uId, state.receiveIndex);
    if (data.isNotEmpty) {
      emit(state.updateState(receives: data, receiveIndex: state.receiveIndex));
    }
  }

  Future<void> updateSearchName(String searchNm) async {
    emit(state.updateState(searchName: searchNm));
  }

  Future<void> getSends() async {
    final List<UserData> data = await _friendRepository.getSendRequests(
        state.myData.uId, state.sendIndex);
    if (data.isNotEmpty) {
      emit(state.updateState(sends: data, sendIndex: state.sendIndex));
    }
  }

  Future<void> searchUsers() async {
    if(state.searchName.isNotEmpty){
    final data = await _friendRepository.searchUsers(state.searchName);
    emit(state.updateState(searches: data));
    }

  }

  final FriendRepository _friendRepository;

  Future<void> sendFriendRequest(String elseId) async {
    final ResultStatus result =
        await _friendRepository.sendFriendRequest(state.myData.uId, elseId);
    if (result == ResultStatus.FRIEND) {
      emit(state.updateState(errorToasts: ErrorToasts.friend));
    } else if (result == ResultStatus.REQUEST) {
      emit(state.updateState(errorToasts: ErrorToasts.request));
    } else {
      emit(state.updateState(errorToasts: ErrorToasts.success));
    }
    emit(state.updateState(errorToasts: ErrorToasts.none));
  }

  Future<void> cancelFriendRequest(String elseId) async {
    await _friendRepository.cancelFriendRequest(state.myData.uId, elseId);
    emit(state.updateState(
        sends: state.sends.skipWhile((value) => value.uId == elseId).toList()));
  }

  Future<void> acceptFriendRequest(String elseId) async {
    await _friendRepository.acceptFriendRequest(state.myData.uId, elseId);
    emit(state.updateState(
        receives:
            state.receives.skipWhile((value) => value.uId == elseId).toList()));
  }

  Future<void> denyFriendRequest(String elseId) async {
    await _friendRepository.denyFriendRequest(state.myData.uId, elseId);
    emit(state.updateState(
        receives:
            state.receives.skipWhile((value) => value.uId == elseId).toList()));
  }

  Future<void> deleteFriend(String elseId) async {
    await _friendRepository.deleteFriend(state.myData.uId, elseId);
    emit(state.updateState(
        friends:
            state.friends.skipWhile((value) => value.uId == elseId).toList()));
  }
}
