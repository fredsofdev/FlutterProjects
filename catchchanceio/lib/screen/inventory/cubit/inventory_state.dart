part of 'inventory_cubit.dart';

class InventoryState extends Equatable {
  const InventoryState(
      {this.data = const [],
      this.currentData = const [],
      this.screens = Screens.COUPON,
      this.uid = ""});

  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> currentData;
  final Screens screens;
  final String uid;

  @override
  // TODO: implement props
  List<Object> get props => [data, currentData, screens, uid];

  List<Map<String, dynamic>> sortData(
      Screens screen, List<Map<String, dynamic>> data) {
    print(data);
    switch (screen) {
      case Screens.COUPON:
        return data
            .where((element) => element['is_used'] == false)
            .toList();
      case Screens.USED:
        return data
            .where((element) => element['is_used'] == true)
            .toList();
      case Screens.ITEM:
        return data
            .where((element) => element['is_used'] == false)
            .toList();
      default:
        return data
            .where((element) => element['is_used'] == false)
            .toList();
    }
  }

  InventoryState updateState(
      {List<Map<String, dynamic>>? data, Screens? screens, String? uid}) {
    return InventoryState(
        uid: uid ?? this.uid,
        data: data ?? this.data,
        screens: screens ?? this.screens,
        currentData: sortData(screens ?? this.screens, data ?? this.data));
  }
}

enum Screens { COUPON, USED, ITEM, PRIZE }
