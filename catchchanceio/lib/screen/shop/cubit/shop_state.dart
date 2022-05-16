part of 'shop_cubit.dart';

class ShopState extends Equatable {
  const ShopState(
      {this.items = const [], this.myId = "", this.resultToast = ""});

  final List<Map<String, dynamic>> items;
  final String myId;
  final String resultToast;

  @override
  // TODO: implement props
  List<Object> get props => [items, myId, resultToast];

  String _setErrorMsg(ItemPayResult error) {
    if (error == ItemPayResult.FAIL) {
      return "네트워크 오류 발생";
    } else if (error == ItemPayResult.SUCCESS) {
      return "상품구매 완료 [보관함] 에서 확인";
    } else if (error == ItemPayResult.NOT_ENOUGH) {
      return "보유한 코인이 부족합니다.";
    }

    return "";
  }

  ShopState updateState({
    List<Map<String, dynamic>>? items,
    String? myId,
    ItemPayResult? result,
  }) {
    return ShopState(
        items: items ?? this.items,
        myId: myId ?? this.myId,
        resultToast: result != null ? _setErrorMsg(result) : resultToast);
  }
}
