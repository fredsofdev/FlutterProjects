import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/shop_repository.dart';
import 'package:equatable/equatable.dart';

part 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  ShopCubit(this._shopRepository, String myId)
      : assert(_shopRepository != null),
        super(const ShopState()) {
    emit(state.updateState(myId: myId));
    getItems();
  }

  final ShopRepository _shopRepository;

  Future<void> getItems() async {
    final data = await _shopRepository.listItems();
    if (data.isNotEmpty) {
      emit(state.updateState(items: data));
    }
  }

  Future<void> buyItem(String id, int count) async {
    final int index = state.items.indexWhere((element) => element['id'] == id);
    final item = state.items[index];

    final ItemPayResult result = await _shopRepository.payForItem(state.myId,
        item['price'] as Map<String,dynamic>,count);
    if (result == ItemPayResult.SUCCESS) {
      await _shopRepository.buyItem(item, state.myId, count);
    }

    emit(state.updateState(result: result));
    emit(state.updateState(result: ItemPayResult.DONE));
  }
}
