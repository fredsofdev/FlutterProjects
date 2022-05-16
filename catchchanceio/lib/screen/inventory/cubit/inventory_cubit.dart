import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/inventory_repository.dart';
import 'package:equatable/equatable.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit(this._inventoryRepository, String uid)
      : assert(_inventoryRepository != null),
        super(const InventoryState()) {
    emit(state.updateState(uid: uid));
    getData(uid);
  }

  Future<void> getData(String uid) async {
    emit(state.updateState(
        data: await _inventoryRepository.listInventory(uid),
        screens: Screens.ITEM));
  }

  final InventoryRepository _inventoryRepository;

  Future<void> useData(String itemId, {Map<String, dynamic>? dataItem}) async {
    final List<Map<String, dynamic>> data = state.data;

    for (final element in data) {
      if (element['id'] == itemId) {
        element['is_used'] = true;
      }
    }
    emit(state.updateState(data: data));
    if (dataItem == null) {
      await _inventoryRepository.useItem("", itemId, null, 0);
    } else {
      await _inventoryRepository.useItem(state.uid, itemId,
          dataItem['type'].toString(), dataItem['amount'] as int);
    }
  }

  void changeScreen(Screens screens) {
    emit(state.updateState(screens: screens));
  }

  Future<Map<String, dynamic>> getItem(String id, String collection) async {
    return await _inventoryRepository.getItem(id, collection);
  }
}
