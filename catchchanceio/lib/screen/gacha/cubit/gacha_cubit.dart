import 'package:bloc/bloc.dart';
import 'package:catchchanceio/repository/authentication/shop_repository.dart';
import 'package:equatable/equatable.dart';

part 'gacha_state.dart';

class GachaCubit extends Cubit<GachaState> {
  GachaCubit(this._shopRepository, String myId)
      : assert(_shopRepository != null),
        super(const GachaState()) {
    getElements(myId);
  }

  final ShopRepository _shopRepository;

  Future<void> getElements(String myId) async {
    emit(state.updateState(myId: myId));

    final success = await _shopRepository.listSuccess();
    final fail = [
      {
        'img_url': "",
        'title': "Fail",
        's_desc': "You have failed try next time"
      }
    ];
    final percents = await _shopRepository.getPercents();

    emit(state.updateState(success: success, fail: fail, percents: percents));
  }

  Future<void> giftSuccess(int index) async {
    await _shopRepository.exchangePay(state.values, state.myId);
    final gift = state.success[index];
    if (gift['type_item'] == "coupon") {
      await _shopRepository.buyCoupon(gift, state.myId);
    } else {
      await _shopRepository.buyItem(gift, state.myId, 1);
    }
    emit(state.updateState(values: {}));
  }

  void updateSValue(Map<String, dynamic> value) {
    final Map<String, dynamic> data = {};
    data.addAll(state.values);
    data.addAll(value);
    emit(state.updateState(values: data));
  }
}
