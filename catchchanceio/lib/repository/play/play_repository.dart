import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'model/rooms_list.dart';

class PlayerWinFailure implements Exception {}

class PlayerAddReportFailure implements Exception {}

class PlayRepository {
  PlayRepository(
      {FirebaseFirestore? firestore, DatabaseReference? firebaseDatabase})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseDatabase =
            firebaseDatabase ?? FirebaseDatabase.instance.reference();

  final FirebaseFirestore _firestore;
  final DatabaseReference _firebaseDatabase;

  Future<List<RoomsList>> listRooms(String stage, String order) {
    return _firebaseDatabase
        .child("MachineList")
        .orderByChild('m_stage')
        .equalTo(stage).once()
        // .onValue
        .then((data) {
      final List<RoomsList> list = [];
      final Map<dynamic, dynamic> values = data.value as Map;
      values.forEach((key, value) {
        list.add(RoomsList.fromMap(value as Map));
      });
      list.removeWhere((element) => element.mState == 'stopping');
      if (order == "playerHigh") {
        list.sort((a, b) => a.mPlayersCount!.compareTo(b.mPlayersCount!));
        return list;
      } else if (order == "playerLow") {
        list.sort((a, b) => b.mPlayersCount!.compareTo(a.mPlayersCount!));
        return list;
      } else if (order == "number") {
        list.sort((a, b) => a.mId!.compareTo(b.mId!));
        return list;
      }
      return list;
    });
  }

  Future<RoomsList> getRandomMachine(String stage)async{
   return _firebaseDatabase.child("MachineList").orderByChild('m_stage').equalTo(stage).once().then((value){
      final Map<dynamic, dynamic> values = value.value as Map;
      final List<RoomsList> list = [];
      values.forEach((key, value) {
        list.add(RoomsList.fromMap(value as Map));
      });
      list.removeWhere((element) => element.mState == "stopping");
      list.sort((a, b) => b.mPlayersCount!.compareTo(a.mPlayersCount!));
      final rng = Random();
      return list[rng.nextInt(list.length)];
    });
  }

  Stream<RoomsList> listenSingleMachine(String machineId) {
    return _firebaseDatabase
        .child("MachineList")
        .child(machineId)
        .onValue
        .map((event) => RoomsList.fromMap(event.snapshot.value as Map));
  }

  Future<void> playerAddReport(
      bool isWin, String uid, String mid, Map<String, Object> stage) async {
    try {
      await _firestore.collection("Users").doc(uid).update({
        "u_totalPlayCount": FieldValue.increment(1),
        "u_wins": isWin ? FieldValue.increment(1) : FieldValue.increment(0),
        "u_${stage['stage']}Total": FieldValue.increment(1),
        "u_${stage['stage']}Wins":
            isWin ? FieldValue.increment(1) : FieldValue.increment(0),
        "u_${stage['stage']}Reward": isWin
            ? FieldValue.increment(stage['prize'] as num)
            : FieldValue.increment(0),
        "u_rankPoint": isWin
            ? FieldValue.increment(stage['coin'] == "play_coin" ? 1:100)
            : FieldValue.increment(0)
      });
      await _firestore
          .collection("Users")
          .doc(uid)
          .collection("playHistory")
          .add({
        'date': FieldValue.serverTimestamp(),
        'mid': mid,
        'stage': stage['stage'],
        'win': isWin
      });
    } catch (e) {
      throw PlayerAddReportFailure();
    }
  }

  Future<PayResult> payForGame(String pId, int gameFee, String coinType) async {
    final DocumentReference ref = _firestore.collection("Users").doc(pId);
    return ref.get().then((value) {
      String type = "u_playCoin";
      if(coinType == "play_coin_purple"){
        type = "itemPurpleCoin";
      }else if(coinType == "play_coin_gold"){
        type = "itemGoldCoin";
      }
      final int userCoins = value.get(type) as int;
      if (userCoins >= gameFee) {
        try {
          ref.update({type: FieldValue.increment(-gameFee)});
          return PayResult.SUCCESS;
        } catch (e) {
          return PayResult.FAIL;
        }
      } else {
        return PayResult.NOT_ENOUGH;
      }
    });
  }

  Future<PayResult> checkPayForGame(String pId, int gameFee, String coinType) async {
    final DocumentReference ref = _firestore.collection("Users").doc(pId);
    return ref.get().then((value) {
      String type = "u_playCoin";
      if(coinType == "play_coin_purple"){
        type = "itemPurpleCoin";
      }else if(coinType == "play_coin_gold"){
        type = "itemGoldCoin";
      }
      final int userCoins = value.get(type) as int;
      if (userCoins >= gameFee) {
        return PayResult.SUCCESS;
      } else {
        return PayResult.NOT_ENOUGH;
      }
    });
  }

  Future<AddItemResult> addPlayTime(String pId, int time) async {
    final DocumentReference ref = _firestore.collection("Users").doc(pId);
    return ref.get().then((value) {
      final int userCoins = value.get('itemPlayTime') as int;
      if (userCoins >= -time) {
        try {
          ref.update({"itemPlayTime": FieldValue.increment(time)});
          return AddItemResult.SUCCESS;
        } catch (e) {
          return AddItemResult.FAIL;
        }
      } else {
        return AddItemResult.NOT_ENOUGH;
      }
    });
  }

  Future<AddItemResult> addLaserCount(String pId, int count) async {
    return _firestore.collection("Users").doc(pId).get().then((value) async {
      if (value.get('itemLaserCount') as int > 0) {
        await _firestore
            .collection("Users")
            .doc(pId)
            .update({"itemLaserCount": FieldValue.increment(count)});
        return AddItemResult.SUCCESS;
      } else {
        return AddItemResult.NOT_ENOUGH;
      }
    });
  }

  Future<AddItemResult> addRotateCount(String pId, int count) async {
    return _firestore.collection("Users").doc(pId).get().then((value) async {
      if (value.get('itemRotateCount') as int >= count) {
        await _firestore
            .collection("Users")
            .doc(pId)
            .update({"itemRotateCount": FieldValue.increment(count)});
        return AddItemResult.SUCCESS;
      } else {
        return AddItemResult.NOT_ENOUGH;
      }
    });
  }
}

enum PayResult {
  FAIL,
  SUCCESS,
  NOT_ENOUGH,
}
enum AddItemResult { FAIL, SUCCESS, NOT_ENOUGH }
