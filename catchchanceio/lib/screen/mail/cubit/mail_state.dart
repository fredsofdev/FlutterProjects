part of 'mail_cubit.dart';

class MailState extends Equatable {
  const MailState(
      {this.mail = const [], this.notice = const [], this.myId = ""});

  final List<Map<String, dynamic>> mail;
  final List<Map<String, dynamic>> notice;
  final String myId;

  @override
  // TODO: implement props
  List<Object> get props => [mail, notice, myId];

  MailState updateState(
      {List<Map<String, dynamic>>? mail,
      List<Map<String, dynamic>>? notice,
      String? myId}) {
    return MailState(
        mail: mail ?? this.mail,
        notice: notice ?? this.notice,
        myId: myId ?? this.myId);
  }
}
