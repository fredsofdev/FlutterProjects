part of 'gacha_cubit.dart';

class GachaState extends Equatable {
  const GachaState({
    this.success = const [],
    this.fail = const [],
    this.percents = const {},
    this.myId = "",
    this.values = const {},
  });

  final List<Map<String, dynamic>> success;
  final List<Map<String, dynamic>> fail;
  final Map<String, dynamic> percents;
  final Map<String, dynamic> values;
  final String myId;

  @override
  // TODO: implement props
  List<Object> get props => [success, fail, percents, values];

  GachaState updateState({
    List<Map<String, dynamic>>? success,
    List<Map<String, dynamic>>? fail,
    Map<String, dynamic>? percents,
    Map<String, dynamic>? values,
    String? myId,
  }) {
    return GachaState(
      success: success ?? this.success,
      fail: fail ?? this.fail,
      percents: percents ?? this.percents,
      myId: myId ?? this.myId,
      values: values ?? this.values,
    );
  }
}
