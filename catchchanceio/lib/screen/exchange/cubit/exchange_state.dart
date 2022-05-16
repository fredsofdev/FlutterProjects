part of 'exchange_cubit.dart';

class ExchangeState extends Equatable {
  const ExchangeState({
    this.coupons = const [],
    this.current = const [],
    this.sortType = SortType.MART,
    this.sort = Sort.POPULAR,
    this.myId = "",
    this.resultToast = "",
  });

  final String myId;
  final List<Map<String, dynamic>> coupons;
  final List<Map<String, dynamic>> current;
  final Sort sort;
  final SortType sortType;
  final String resultToast;

  @override
  // TODO: implement props
  List<Object> get props => [
        coupons,
        current,
        sort,
        sortType,
        resultToast,
      ];

  List<Map<String, dynamic>> _reconstruct(
      Sort sort, SortType sortType, List<Map<String, dynamic>> data) {
    final List<Map<String, dynamic>> list = [];
    list.addAll(data);
    switch (sortType) {
      case SortType.MART:
        list.removeWhere((element) => element['type'] != "mart");
        break;
      case SortType.CAFE:
        list.removeWhere((element) => element['type'] != "cafe");
        break;
      case SortType.BOOK:
        list.removeWhere((element) => element['type'] != "book");
        break;
      case SortType.EMO:
        list.removeWhere((element) => element['type'] != "emo");
        break;
    }

    switch (sort) {
      case Sort.POPULAR:
        list.sort(
            (a, b) => (b['popular'] as int).compareTo(a['popular'] as int));
        break;
      case Sort.LOW:
        list.sort((a, b) =>
            (a['coin_price'] as int).compareTo(b['coin_price'] as int));
        break;
      case Sort.HIGH:
        list.sort((a, b) =>
            (b['coin_price'] as int).compareTo(a['coin_price'] as int));
        break;
      case Sort.BRAND:
        list.sort((a, b) =>
            (a['brand_name'].toString()).compareTo(b['brand_name'].toString()));
        break;
    }

    return list;
  }

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

  ExchangeState updateState({
    String? myId,
    List<Map<String, dynamic>>? coupons,
    List<Map<String, dynamic>>? current,
    Sort? sort,
    SortType? sortType,
    ItemPayResult? resultToast,
  }) {
    return ExchangeState(
      myId: myId ?? this.myId,
      coupons: coupons ?? this.coupons,
      sort: sort ?? this.sort,
      sortType: sortType ?? this.sortType,
      current: current ??
          (sort == null && sortType == null
              ? this.current
              : _reconstruct(sort ?? this.sort, sortType ?? this.sortType,
                  coupons ?? this.coupons)),
      resultToast:
          resultToast != null ? _setErrorMsg(resultToast) : this.resultToast,
    );
  }
}

enum Sort { POPULAR, LOW, HIGH, BRAND }
enum SortType { MART, CAFE, BOOK, EMO }
