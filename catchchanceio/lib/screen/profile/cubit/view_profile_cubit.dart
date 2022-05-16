import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/friend_repository.dart';
import 'package:catchchanceio/repository/authentication/models/user_data.dart';
import 'package:equatable/equatable.dart';

part 'view_profile_state.dart';

class ViewProfileCubit extends Cubit<ViewProfileState> {
  ViewProfileCubit(this._friendRepository, String userId, String myId)
      : assert(_friendRepository != null),
        super(const ViewProfileState()) {
    emit(state.updateState(myId: myId));
    getRelationship(userId);
  }

  final FriendRepository _friendRepository;

  Future<void> getRelationship(String userId) async {
    final userData = await _friendRepository.getUserData(userId);
    emit(state.updateState(userData: userData));

    final String result = await _friendRepository.getRelationshipStatus(
        state.userData.uId, state.myId);
    if (result == 'f') {
      emit(state.updateState(relationship: Relationship.FRIEND));
    } else if (result == 'r') {
      emit(state.updateState(relationship: Relationship.REQUESTED));
    } else {
      emit(state.updateState(relationship: Relationship.UNKNOWN));
    }
  }

  Future<void> sendFriendRequest() async {
    emit(state.updateState(relationship: Relationship.REQUESTED));
    await _friendRepository.sendFriendRequest(state.myId, state.userData.uId);
  }
}
