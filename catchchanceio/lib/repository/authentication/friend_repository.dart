import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';

import 'models/user_data.dart';

class FriendRepository {
  FriendRepository({FirebaseFirestore? fireStore})
      : _fireStore = fireStore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _fireStore;

  Future<List<UserData>> getFriends(String myId, int index) async {
    List<String> totalFriends = [];
    await _fireStore.collection("Friends").doc(myId).get().then((value) =>
        value.exists
            ? totalFriends = value.get('friends').cast<String>()
            : []);

    final List<String> chunkFriends = totalFriends.length > index
        ? totalFriends.sublist(
            index,
            totalFriends.length >= index + 20
                ? index + 19
                : totalFriends.length)
        : [];

    final List<UserData> data = [];
    if (chunkFriends.isNotEmpty) {
      for (var i = 0; i <= (chunkFriends.length ~/ 10); i++) {
        data.addAll(await _fireStore
            .collection('Users')
            .where('u_id',
                whereIn: chunkFriends.sublist(
                    i * 10,
                    i == 1
                        ? chunkFriends.length
                        : chunkFriends.length > 10
                            ? 9
                            : chunkFriends.length))
            .get()
            .then((event) =>
                event.docs.map((e) => UserData.fromToData(e.data())).toList()));
      }
    }
    return data;
  }

  Future<String> getRelationshipStatus(String userId, String myId) async {
    return _fireStore.collection("Friends").doc(myId).get().then((value) {
      if (value.data()!.isNotEmpty) {
        final List<String> friends = value.get('friends').cast<String>();
        final List<String> requests = value.get('receives').cast<String>();
        requests.addAll(value.get('sends').cast<String>());

        if (friends.contains(userId)) {
          return 'f';
        } else {
          return requests.contains(userId) ? 'r' : 'u';
        }
      } else {
        return 'u';
      }
    });
  }

  Future<UserData> getUserData(String id) async {
    return _fireStore
        .collection("Users")
        .doc(id)
        .get()
        .then((value) => UserData.fromToData(value.data() as Map<String, dynamic>));
  }

  Future<List<Map<String, dynamic>>> listInventory(String id) async {
    return _fireStore
        .collection('Inventory')
        .where('owner', isEqualTo: id)
        .where('type', isEqualTo: "Coupon")
        .where('is_owned', isEqualTo: true)
        .where('is_used', isEqualTo: false)
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

  Future<void> sendGift(String id, List<Map<String, dynamic>> data, String name,
      String url) async {
    for (final element in data) {
      await _fireStore
          .collection('Inventory')
          .doc(element['id'].toString())
          .update({'is_owned': false});
      await _fireStore.collection('Users').doc(id).update({'is_newMail': true});
      await _fireStore.collection('Users').doc(id).collection('Mail').add({
        'type': 'Inventory',
        'title': element['title'],
        'message': '${element['type']} send by $name',
        'reg_date': formatDate(
            DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            [yyyy, '-', mm, '-', dd]),
        'product_id': element['product_id'],
        'invent_id': element['id'],
        'product_type': element['type'],
        'from_name': name,
        'from_url': url
      });
    }
  }

  Future<List<UserData>> getReceivedRequests(String myId, int index) async {
    List<String> totalFriends = [];
    await _fireStore.collection("Friends").doc(myId).get().then((value) =>
        value.exists
            ? totalFriends = value.get('receives').cast<String>()
            : []);

    final List<String> chunkFriends = totalFriends.length > index
        ? totalFriends.sublist(
            index,
            totalFriends.length >= index + 20
                ? index + 19
                : totalFriends.length)
        : [];

    final List<UserData> data = [];
    if (chunkFriends.isNotEmpty) {
      for (var i = 0; i <= (chunkFriends.length ~/ 10); i++) {
        data.addAll(await _fireStore
            .collection('Users')
            .where('u_id',
                whereIn: chunkFriends.sublist(
                    i * 10,
                    i == 1
                        ? chunkFriends.length
                        : chunkFriends.length > 10
                            ? 9
                            : chunkFriends.length))
            .get()
            .then((event) =>
                event.docs.map((e) => UserData.fromToData(e.data())).toList()));
      }
    }
    return data;
  }

  Future<List<UserData>> getSendRequests(String myId, int index) async {
    List<String> totalFriends = [];
    await _fireStore.collection("Friends").doc(myId).get().then((value) =>
        value.exists
            ? totalFriends = value.get('sends').cast<String>()
            : []);

    final List<String> chunkFriends = totalFriends.length > index
        ? totalFriends.sublist(
            index,
            totalFriends.length >= index + 20
                ? index + 19
                : totalFriends.length)
        : [];
    final List<UserData> data = [];
    if (chunkFriends.isNotEmpty) {
      for (var i = 0; i <= (chunkFriends.length ~/ 10); i++) {
        data.addAll(await _fireStore
            .collection('Users')
            .where('u_id',
                whereIn: chunkFriends.sublist(
                    i * 10,
                    i == 1
                        ? chunkFriends.length
                        : chunkFriends.length > 10
                            ? 9
                            : chunkFriends.length))
            .get()
            .then((event) =>
                event.docs.map((e) => UserData.fromToData(e.data())).toList()));
      }
    }
    return data;
  }

  Future<List<UserData>> getFriendRecommendations(String myId) async {
    final rng = Random();
    int maxUsers = 0;
    await _fireStore
        .collection('CountOfCollection')
        .doc('User')
        .get()
        .then((value) => maxUsers = value.get('count') as int);
    List<int> random =
        List<int>.generate(50, (index) => rng.nextInt(maxUsers) + 1);
    random = random.toSet().toList();
    final List<String> idList = [];
    await _fireStore.collection('Friends').doc(myId).get().then((value) {
      if (value.exists) {
        idList.addAll(value.get('friends').cast<String>());
        idList.addAll(value.get('receives').cast<String>());
        idList.addAll(value.get('sends').cast<String>());
      }
    });

    final List<UserData> data = [];
    if (random.isNotEmpty) {
      for (var i = 0; i <= (random.length ~/ 10); i++) {
        data.addAll(await _fireStore
            .collection('Users')
            .where('u_index',
                whereIn: random
                    .skip(i * 10)
                    .take(random.length > 10 ? 9 : random.length)
                    .toList())
            .get()
            .then((event) => event.docs.map((e) {
              if (!idList.contains(e.get('u_id')) &&
                    e.get('u_id') != myId) {
                  return UserData.fromToData(e.data());
                }
              return UserData.empty;
            }).toList()));
      }
    }

    return data;
  }

  Future<List<UserData>> searchUsers(String nickname) async {
    return _fireStore
        .collection('Users')
        .where('u_name', isEqualTo: nickname)
        .limit(10)
        .get()
        .then((value) =>
            value.docs.map((e) => UserData.fromToData(e.data())).toList());
  }

  Future<ResultStatus> sendFriendRequest(String myId, String elseId) async {
    try {
      final ResultStatus result = await _fireStore
          .collection('Friends')
          .doc(myId)
          .get()
          .then((value) async {
        if (value.exists) {
          final List<dynamic> friends = value.get('friends').cast<String>();
          final List<dynamic> requests =
              value.get('receives').cast<String>();
          requests.addAll(value.get('sends').cast<String>());
          return friends.contains(elseId)
              ? ResultStatus.FRIEND
              : requests.contains(elseId)
                  ? ResultStatus.REQUEST
                  : ResultStatus.SUCCESS;
        } else {
          return ResultStatus.SUCCESS;
        }
      });
      if (result == ResultStatus.SUCCESS) {
        final batch = _fireStore.batch();
        batch.update(_fireStore.collection('Friends').doc(myId), {
          'sends': FieldValue.arrayUnion([elseId])
        });

        batch.update(_fireStore.collection('Friends').doc(elseId), {
          'receives': FieldValue.arrayUnion([myId])
        });

        batch.commit();
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelFriendRequest(String myId, String elseId) async {
    try {
      final batch = _fireStore.batch();
      batch.update(_fireStore.collection('Friends').doc(myId), {
        'sends': FieldValue.arrayRemove([elseId])
      });
      batch.update(_fireStore.collection('Friends').doc(elseId), {
        'receives': FieldValue.arrayRemove([myId])
      });
      batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String myId, String elseId) async {
    try {
      final batch = _fireStore.batch();
      batch.update(_fireStore.collection('Friends').doc(myId), {
        'friends': FieldValue.arrayUnion([elseId])
      });
      batch.update(_fireStore.collection('Friends').doc(elseId), {
        'friends': FieldValue.arrayUnion([myId])
      });
      batch.update(_fireStore.collection('Friends').doc(myId), {
        'receives': FieldValue.arrayRemove([elseId])
      });
      batch.update(_fireStore.collection('Friends').doc(elseId), {
        'sends': FieldValue.arrayRemove([myId])
      });
      batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> denyFriendRequest(String myId, String elseId) async {
    try {
      final batch = _fireStore.batch();
      batch.update(_fireStore.collection('Friends').doc(myId), {
        'receives': FieldValue.arrayRemove([elseId])
      });
      batch.update(_fireStore.collection('Friends').doc(elseId), {
        'sends': FieldValue.arrayRemove([myId])
      });
      batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFriend(String myId, String elseId) async {
    try {
      final batch = _fireStore.batch();
      batch.update(_fireStore.collection('Friends').doc(myId), {
        'friends': FieldValue.arrayRemove([elseId])
      });
      batch.update(_fireStore.collection('Friends').doc(elseId), {
        'friends': FieldValue.arrayRemove([myId])
      });
      batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}

enum ResultStatus { SUCCESS, FRIEND, REQUEST }
