import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import 'models/app_config.dart';

class ShopRepository {
  ShopRepository({FirebaseFirestore? fireStore})
      : _fireStore = fireStore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _fireStore;

  Future<List<Map<String, dynamic>>> listItems() async {
    return _fireStore
        .collection('Item')
        .where('available', isEqualTo: true)
        .get()
        .then((data) {
      List<Map<String, dynamic>> list = [];
      if (data.docs.isNotEmpty) {
        list = data.docs.map((e) {
          final Map<String, dynamic> data = e.data();
          data['id'] = e.id;
          return data;
        }).toList();
      }
      return list;
    });
  }

  Future<List<Map<String, dynamic>>> listCoupons() async {
    return _fireStore
        .collection('Coupon')
        .where('available', isEqualTo: true)
        .get()
        .then((data) {
      List<Map<String, dynamic>> list = [];
      if (data.docs.isNotEmpty) {
        list = data.docs.map((e) {
          final Map<String, dynamic> data = e.data();
          data['id'] = e.id;
          final Map<String, dynamic> price =
              data['price'] as Map<String, dynamic>;
          price.removeWhere((key, value) => value == 0);
          data['price'] = price;
          return data;
        }).toList();
      }
      return list;
    });
  }

  Future<Map<String, dynamic>> getPercents() async {
    return _fireStore
        .collection('CountOfCollection')
        .doc('Roulette')
        .get()
        .then(
            (data) => data.get('percents') as Future<Map<String, dynamic>>);
  }

  Future<void> exchangeRewardToGold(int gold, String myId) async {
    await _fireStore
        .collection("Users")
        .doc(myId)
        .update({'u_coin': FieldValue.increment(gold)});
  }

  Future<List<Map<String, dynamic>>> listSuccess() async {
    List<String> totalSuccessCoupons = [];
    List<String> totalSuccessItems = [];
    await _fireStore
        .collection("CountOfCollection")
        .doc("Roulette")
        .get()
        .then((value) {
      if (value.exists) {
        totalSuccessCoupons = value.get('success_coupons') as List<String>;
        totalSuccessItems = value.get('success_items') as List<String>;
      } else {
        totalSuccessCoupons = [];
        totalSuccessItems = [];
      }
    });
    final List<Map<String, dynamic>> data = [];
    int index = 0;
    if (totalSuccessCoupons.isNotEmpty) {
      data.addAll(await _fireStore
          .collection("Coupon")
          .where(FieldPath.documentId, whereIn: totalSuccessCoupons)
          .get()
          .then((value) => value.docs.map((e) {
                final Map<String, dynamic> dataMap = e.data();
                dataMap['id'] = e.id;
                dataMap['index'] = index;
                dataMap['type_item'] = "coupon";
                index++;
                return dataMap;
              })));
    }

    if (totalSuccessItems.isNotEmpty) {
      data.addAll(await _fireStore
          .collection("Item")
          .where(FieldPath.documentId, whereIn: totalSuccessItems)
          .get()
          .then((value) {
        return value.docs.map((e) {
          final Map<String, dynamic> dataMap = e.data();
          dataMap['id'] = e.id;
          dataMap['index'] = index;
          dataMap['type_item'] = "item";
          index++;
          return dataMap;
        });
      }));
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> listFail() async {
    List<String> totalFailItems = [];
    await _fireStore
        .collection("CountOfCollection")
        .doc("Roulette")
        .get()
        .then((value) {
      if (value.exists) {
        totalFailItems = value.get('fail_items') as List<String>;
      } else {
        totalFailItems = [];
      }
    });
    final List<Map<String, dynamic>> data = [];

    for (final element in totalFailItems) {
      data.add(await _fireStore.collection("Item").doc(element).get().then((e) {
        final Map<String, dynamic> dataMap = e.data()!;
        dataMap['id'] = e.id;
        return dataMap;
      }));
    }

    return data;
  }

  Future<ItemPayResult> payForItem(
      String pId, Map<String,dynamic> price, int count) async {
    price.removeWhere((key, value) => value == 0);
    final DocumentReference ref = _fireStore.collection("Users").doc(pId);
    return ref.get().then((value) {
      bool isValid = true;
      price.forEach((key, data) {
        final int userCoins = value.get("u_${key}Reward") as int;
        if (userCoins < (data*count) && isValid) {
          isValid = false;
        }
      });

      if (isValid) {
        try {
          price.forEach((key, value) {
            ref.update({"u_${key}Reward": FieldValue.increment(-(value*count))});
          });
          return ItemPayResult.SUCCESS;
        } catch (e) {
          return ItemPayResult.FAIL;
        }
      } else {
        return ItemPayResult.NOT_ENOUGH;
      }
    });
  }

  Future<ItemPayResult> payForCoupon(
      String pId, Map<String, dynamic> itemFees) async {
    final DocumentReference ref = _fireStore.collection("Users").doc(pId);
    return ref.get().then((value) async {
      try {
        await ref.update({
          "u_stage1Reward": FieldValue.increment(
              itemFees['stage1'] == null ? 0 : -itemFees['stage1'] as num),
          "u_stage2Reward": FieldValue.increment(
              itemFees['stage2'] == null ? 0 : -itemFees['stage2'] as num),
          "u_stage3Reward": FieldValue.increment(
              itemFees['stage3'] == null ? 0 : -itemFees['stage3'] as num),
          "u_stage4Reward": FieldValue.increment(
              itemFees['stage4'] == null ? 0 : -itemFees['stage4'] as num),
          "u_stage5Reward": FieldValue.increment(
              itemFees['stage5'] == null ? 0 : -itemFees['stage5'] as num),
        });
        return ItemPayResult.SUCCESS;
      } catch (e) {
        return ItemPayResult.FAIL;
      }
    });
  }

  Future<void> exchangePay(Map<String, dynamic> values, String myId) async {
    values.forEach((key, value) async {
      final keys = key.split("");
      await _fireStore.collection("Users").doc(myId).update({
        "u_${keys[0]}tage${keys[1]}Reward": FieldValue.increment(-value as num)
      });
    });
  }

  Future<void> buyCoupon(Map<String, dynamic> data, String myId) async {
    await _fireStore
        .collection('Coupon')
        .doc(data['id'].toString())
        .update({'popular': FieldValue.increment(1)});
    final value = await _fireStore.collection('Inventory').add({
      'owner': myId,
    });
    final randomId =
        DateTime.now().year.toString().replaceRange(0, 2, "") + value.id;
    const requestUrl = 'https://bizapi.giftishow.com/bizApi/send';
    final uri = Uri.parse(requestUrl);
    final urlWithParam = uri.replace(queryParameters: {
      'api_code': '0204',
      'custom_auth_code': AppConfig.gifAuthCode,
      'custom_auth_token': AppConfig.gifAuthToken,
      'dev_yn': 'N',
      'goods_code': data['goods_code'],
      'mms_msg': '테스트 내용',
      'order_no': '312321321312',
      'mms_title': '테스트 발송',
      'callback_no': '01099361422',
      'phone_no': '01099361422',
      'tr_id': randomId,
      'user_id': 'orangestepkorea@gmail.com',
      'gubun': 'I',
    });
    await http
        .post(urlWithParam, encoding: Encoding.getByName('UTF-8'))
        .then((response) async {
      final json = jsonDecode(response.body);
      print('body: ${response.body}');
      final barcodeUrl = json['result']['result']['couponImgUrl'];

      await value.set({
        'owner': myId,
        'type': "Coupon",
        'product_id': data['id'],
        'title': data['title'],
        'desc': data['s_desc'],
        'is_owned': true,
        'is_used': false,
        'reg_date': formatDate(
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day),
            [yyyy, '-', mm, '-', dd]),
        'img_url': data['img_url_s'],
        'barcode_img_url': barcodeUrl ?? ""
      });
    }).catchError((err) async {
      await _fireStore
          .collection('Coupon')
          .doc(data['id'].toString())
          .update({'available': false});
      await refundCouponPayment(myId, data['price'] as Map<String, dynamic>);
      await value.delete();
      print('error: $err');
      throw err;
    });

  }

  Future<ItemPayResult> refundCouponPayment(
      String pId, Map<String, dynamic> itemFees) async {
    final DocumentReference ref = _fireStore.collection("Users").doc(pId);

    try {
      await ref.update({
        "u_stage1Reward": FieldValue.increment(
            itemFees['stage1'] == null ? 0 : itemFees['stage1'] as num),
        "u_stage2Reward": FieldValue.increment(
            itemFees['stage2'] == null ? 0 : itemFees['stage2'] as num),
        "u_stage3Reward": FieldValue.increment(
            itemFees['stage3'] == null ? 0 : itemFees['stage3'] as num),
        "u_stage4Reward": FieldValue.increment(
            itemFees['stage4'] == null ? 0 : itemFees['stage4'] as num),
        "u_stage5Reward": FieldValue.increment(
            itemFees['stage5'] == null ? 0 : itemFees['stage5'] as num),
      });
      return ItemPayResult.SUCCESS;
    } catch (e) {
      return ItemPayResult.FAIL;
    }

  }

  // Future<void> buyItem(Map<String,dynamic> data, String myId, String barcodeUrl) async{
  //  await _fireStore.collection('Inventory')
  //       .add({
  //    'owner': myId,
  //    'type' : "Item",
  //    'product_id' : data['id'],
  //    'title' : data['title'],
  //    'desc' : data['s_desc'],
  //    'is_owned': true,
  //    'is_used' : false,
  //    'reg_date' : formatDate(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day),[yyyy, '-', mm, '-', dd]),
  //    'img_url' : data['img_url'],
  //    'barcode_img_url': barcodeUrl ?? ""
  //  });
  // }

  Future<void> buyItem(
      Map<String, dynamic> data, String myId, int count) async {
    final amount = (data['amount'] as int) * count;
    print(amount);
    print(data['type']);
    if (data['type'] == "play_coin_purple") {
      await _fireStore
          .collection('Users')
          .doc(myId)
          .update({'itemPurpleCoin': FieldValue.increment(amount)});
    } else if (data['type'] == "item_addtime") {
      await _fireStore
          .collection('Users')
          .doc(myId)
          .update({'itemPlayTime': FieldValue.increment(amount)});
    } else if (data['type'] == "play_coin_gold") {
      await _fireStore
          .collection('Users')
          .doc(myId)
          .update({'itemGoldCoin': FieldValue.increment(amount)});
    }
  }
}

enum ItemPayResult { FAIL, SUCCESS, NOT_ENOUGH, DONE }
