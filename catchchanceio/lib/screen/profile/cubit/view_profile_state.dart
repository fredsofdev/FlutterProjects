part of 'view_profile_cubit.dart';

class ViewProfileState extends Equatable {
  const ViewProfileState(
      {this.relationship = Relationship.REQUESTED,
      this.userData = UserData.empty,
      this.myId = ""});

  final UserData userData;
  final Relationship relationship;
  final String myId;

  @override
  // TODO: implement props
  List<Object> get props => [userData, relationship];

  ViewProfileState updateState({
    UserData? userData,
    Relationship? relationship,
    String? myId,
  }) {
    return ViewProfileState(
        userData: userData ?? this.userData,
        relationship: relationship ?? this.relationship,
        myId: myId ?? this.myId);
  }
}

enum Relationship { UNKNOWN, FRIEND, REQUESTED }
