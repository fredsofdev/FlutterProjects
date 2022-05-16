import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';

class InventoryRepository {
  InventoryRepository({FirebaseFirestore? fireStore})
      : _fireStore = fireStore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _fireStore;

  Future<List<Map<String, dynamic>>> listInventory(String id) async {
    return _fireStore
        .collection('Inventory')
        .where('owner', isEqualTo: id)
        .where('is_owned', isEqualTo: true)
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

  Future<Map<String, dynamic>> getItem(String id, String collection) async {
    Map<String, dynamic> datas = {};
    await _fireStore
        .collection(collection)
        .doc(id)
        .get()
        .then((data) => datas = data.data()!);
    return datas;
  }

  Future<void> useItem(
      String uid, String itemId, String? type, int amount) async {
    await _fireStore
        .collection('Inventory')
        .doc(itemId)
        .update({'is_used': true});
    if (type != null) {
      await _fireStore
          .collection("Users")
          .doc(uid)
          .update({type: FieldValue.increment(amount)});
    }
  }

  Future<List<Map<String, dynamic>>> listMail(String id) async {
    await _fireStore.collection('Users').doc(id).update({'is_newMail': false});
    return _fireStore
        .collection('Users')
        .doc(id)
        .collection('Mail')
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

  Future<void> acceptItems(String uid, Map<String, dynamic> data) async {
    print(data['type']);
    if (data['type'] == "Inventory") {
      await _fireStore
          .collection('Inventory')
          .doc(data['invent_id'].toString())
          .update({'owner': uid, 'is_owned': true});
    } else if (data['type'] == "Admin") {
      if (data['product_type'] == "Coin") {
        await _fireStore
            .collection('Users')
            .doc(uid)
            .update({'u_coin': FieldValue.increment(data['amount'] as num)});
      } else {
        await _fireStore.collection('Inventory').add({
          'desc': data['desc'],
          'type': data['product_type'],
          'product_id': data['product_id'],
          'is_owned': true,
          'expire_date': formatDate(
              DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day),
              [yyyy, '-', mm, '-', dd]),
          'img_url': data['img_url'],
          'is_used': false,
          'owner': uid,
          'title': data['title']
        });
      }
    } else {
      print("Type not found");
    }
    await _fireStore
        .collection("Users")
        .doc(uid)
        .collection('Mail')
        .doc(data['id'].toString())
        .delete();
  }

  Future<void> acceptSendItem(String uid, Map<String, dynamic> data) async {
    await _fireStore
        .collection("Users")
        .doc(uid)
        .collection('Mail')
        .doc(data['id'].toString())
        .delete();
    if (data['itemType'] == "addtime") {
      await _fireStore.collection('Users').doc(uid).update(
          {'itemPlayTime': FieldValue.increment(data['amount'] as num)});
    } else if (data['itemType'] == "laser") {
      await _fireStore.collection('Users').doc(uid).update(
          {'itemLaserCount': FieldValue.increment(data['amount'] as num)});
    }
  }

  Future<List<Map<String, dynamic>>> listNotice() async {
    return _fireStore.collection('Notice').get().then((data) {
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
}
