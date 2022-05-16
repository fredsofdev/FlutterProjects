import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/shop_repository.dart';
import 'package:equatable/equatable.dart';

part 'exchange_state.dart';

class ExchangeCubit extends Cubit<ExchangeState> {
  ExchangeCubit(this._shopRepository, String myId)
      : assert(_shopRepository != null),
        super(const ExchangeState()) {
    emit(state.updateState(myId: myId));
    getCoupons();
  }

  final ShopRepository _shopRepository;

  Future<void> getCoupons() async {
    final data = await _shopRepository.listCoupons();
    if (data.isNotEmpty) {
      emit(state.updateState(coupons: data, sortType: SortType.MART));
    }
  }

  Future<void> exchangeRewardToGold(int gold, Map<String, dynamic> data) async {
    await _shopRepository.exchangePay(data, state.myId);
    await _shopRepository.exchangeRewardToGold(gold, state.myId);
  }

  void search(String searchWord) {
    final List<Map<String, dynamic>> list = [];
    list.addAll(state.coupons);
    list.removeWhere(
        (element) => !element['search_word'].toString().contains(searchWord));
    emit(state.updateState(current: list));
  }

  void changeScreen({ Sort? sort,  SortType? sortType}) {
    emit(state.updateState(sortType: sortType, sort: sort));
  }

  Future<ItemPayResult> buyCoupon(String couponIndex) async {
    final List<Map<String, dynamic>> list = [];
    list.addAll(state.current);
    final index = list.indexWhere((element) => element['id'] == couponIndex);
    final data = list[index];
    final result = await _shopRepository.payForCoupon(
        state.myId, data['price'] as Map<String, dynamic>);
    if (result == ItemPayResult.SUCCESS) {
      try {
        await _shopRepository.buyCoupon(data, state.myId);
      } catch (e) {
        print(e);
        emit(state.updateState(resultToast: result));
        emit(state.updateState(resultToast: ItemPayResult.DONE));
        return ItemPayResult.FAIL;
      }
    }
    emit(state.updateState(resultToast: result));
    emit(state.updateState(resultToast: ItemPayResult.DONE));
    return result;
  }
}
