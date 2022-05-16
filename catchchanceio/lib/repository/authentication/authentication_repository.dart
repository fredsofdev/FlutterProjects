import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:kakao_flutter_sdk/common.dart'; // import utility methods
import 'package:kakao_flutter_sdk/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models/app_config.dart';
import 'models/user_data.dart';


/// Thrown if during the sign up process if a failure occurs.
class SignUpFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInWithEmailAndPasswordFailure implements Exception {}

/// Thrown during the sign in with google process if a failure occurs.
class GetGoogleCredentialFailure implements Exception {}

/// Thrown during the sign in with facebook process if a failure occurs.
class GetFaceBookCredentialFailure implements Exception {}

/// Thrown during the sign in with facebook process if a failure occurs.
class GetKakaoLoginDataFailure implements Exception {}

/// Thrown during the sign in with facebook process if a failure occurs.
class GetLineLoginDataFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

class GetResourcesFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository(
      {FirebaseAuth? firebaseAuth,
      GoogleSignIn? googleSignIn,
       storageReference,
      Future<SharedPreferences>? prefs,
      FirebaseFirestore? firestore,
      AuthCodeClient? authCodeClient,
      LineSDK? lineSDK})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        _storageReference = storageReference ?? FirebaseStorage.instance.ref(),
        _prefs = prefs ?? SharedPreferences.getInstance(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _authCodeClient = authCodeClient ?? AuthCodeClient.instance,
        _lineSDK = lineSDK ?? LineSDK.instance {
    KakaoContext.clientId = AppConfig.kakaoKey;
    LineSDK.instance.setup(AppConfig.lineID).then((_) {});
  }

  final GoogleSignIn _googleSignIn;
  final AuthCodeClient _authCodeClient;
  final LineSDK _lineSDK;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final Future<SharedPreferences> _prefs;
  final  _storageReference;
  final group = StreamGroup<UserData>();

  Stream<UserData> get user {
    // logOut();
    Stream<UserData>? subscribe;
    _firebaseAuth.idTokenChanges().forEach((firebaseUser) async {
      print("Id token changed");
      print(firebaseUser);
      if (firebaseUser == null || !firebaseUser.isAnonymous) {
        if (firebaseUser != null) {}

        try {
          group.remove(subscribe!);
        } catch (e) {}
        print("User id: ${firebaseUser?.uid}");
        subscribe = _firestore
            .collection("Users")
            .doc(firebaseUser != null ? firebaseUser.uid : 'empty')
            .snapshots()
            .map((doc) => doc.exists ? doc.toUserData : UserData.empty);
        group.add(subscribe!);
      }
    });

    return group.stream.asBroadcastStream();
  }

  Future<bool> isUserExist(String email) async {
    return _firestore
        .collection('Users')
        .where('u_email', isEqualTo: email)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        return false;
      } else {
        if (value.docs[0]['is_deleted'] as bool) {
          try {
            logOut();
          } catch (e) {}
          throw GetGoogleCredentialFailure();
        } else {
          return true;
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> listNotice() async {
    return _firestore
        .collection('Notice')
        .orderBy('reg_date')
        .limit(3)
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

  Future<List<Map<String, dynamic>>> listQNA(String myId) async {
    return _firestore
        .collection('QNA')
        .where('user_id', isEqualTo: myId)
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

  Future<Map<String, dynamic>> getAdRewards(String myId) async {
    return _firestore
        .collection('CountOfCollection')
        .doc('Exchange')
        .get()
        .then((data) =>
            data.get('exchange_ad') as FutureOr<Map<String, dynamic>>);
  }

  Future<Map<String, dynamic>> getReportUrls(String myId) async {
    return _firestore
        .collection('CS')
        .doc('FormURL')
        .get()
        .then((data) => data.data() as FutureOr<Map<String, dynamic>>);
  }

  Future<List<Map<String, dynamic>>> getTopUsers() async {
    final List<Map<String, dynamic>> data = [];
    int index = 1;
    data.addAll(await _firestore
        .collection('Users').orderBy('u_rankPoint',descending: true).limit(20)
        .get()
        .then((data) => data.docs.map((e){
            final Map<String, dynamic> dataMap = e.data();
            dataMap['index'] = index;
            index++;
            return dataMap;
         })));

    return data;
  }

  Future<List<Map<String, dynamic>>> getPopularCoupons() async {
    final List<Map<String, dynamic>> data = [];
    int index = 1;
    data.addAll(await _firestore
        .collection('Coupon').where('available', isEqualTo: true).limit(8)
        .get()
        .then((data) => data.docs.map((e){
      final Map<String, dynamic> dataMap = e.data();
      dataMap['index'] = index;
      index++;
      return dataMap;
    })));

    return data;
  }

  Future<void> deleteUser() async {
    await _firestore
        .collection('Users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'is_deleted': true});
    await logOut();
  }

  Future<String> updateUserPhoto(String myId, File img) async {
    try {
      final  reference =
          _storageReference.child('Users').child(myId);
      final  snapshot = await reference.putFile(img);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (snapshot != null) {
        final url = downloadUrl.toString();
        await _firestore
            .collection('Users')
            .doc(myId)
            .update({'u_imgUrl': url, 'u_imgUrlHigh': url});
        return "프로필 이미지가 변경되었습니다.";
      } else {
        return "네트워크 에러 발생";
      }
    } catch (e) {
      print(e);
      return "네트워크 에러 발생";
    }
  }

  Future<void> postQNA(Map<String, dynamic> data) async {
    await _firestore
        .collection('CountOfCollection')
        .doc('QNA')
        .update({'count': FieldValue.increment(1)});
    await _firestore.collection('QNA').add(data);
  }

  Future<ResourcesStatus> checkResourceStatue() => _checkResources();

  Stream<String> getResources() => _getResources();

  Future<ResourcesStatus> _checkResources() async {
    final SharedPreferences prefs = await _prefs;

    // final AppUpdateInfo _updateInfo =
    // await InAppUpdate.checkForUpdate().catchError((e) { print("Error: $e");});
    // if (_updateInfo.updateAvailability!= 0) {
    //   if (_updateInfo.immediateUpdateAllowed) {
    //     await InAppUpdate.performImmediateUpdate()
    //         .then((_) {})
    //         .catchError((e) {});
    //   }
    //   if (_updateInfo.flexibleUpdateAllowed) {
    //     await InAppUpdate.startFlexibleUpdate().then((_) {
    //       InAppUpdate.completeFlexibleUpdate();
    //     }).catchError((e) {});
    //   }
    // }

    final data = await _firestore
        .collection('APP_SYSTEM')
        .doc('GAME_RESOURCE')
        .collection('FILE_LIST')
        .where('fileName', isEqualTo: AppConfig.fileName)
        .get()
        .then((value) => value.docs[0].data());
    final resourcesDownloaded = prefs.getStringList('resourcesDownloadedUrl');
    final Map<String, String> mapData =
        data['downloadUrl'].cast<String, String>();
    List<String> listUrls = [];
    print(mapData.toString());
    mapData.forEach((key, value) {
      print(value);
      listUrls.add(value);
    });
    Function eq = const ListEquality().equals;
    AppConfig.appDocDirectory = await getApplicationDocumentsDirectory();
    // // AppUpdateInfo _updateInfo;
    // // GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
    // // bool _flexibleUpdateAvailable = false;
    //
    //
    // // Platform messages are asynchronous, so we initialize in an async method.
    // Future<void> checkForUpdate() async {
    //   InAppUpdate.checkForUpdate().then((info) {
    //     print('logan'+info.updateAvailability.toString());
    //     print(info?.updateAvailability == UpdateAvailability.updateAvailable);
    //     info?.updateAvailability == UpdateAvailability.updateAvailable ? () {
    //       InAppUpdate.performImmediateUpdate().then((_) {
    //
    //       }).catchError((e) {
    //         print('logan : '+e.toString());
    //       });
    //     }
    //     : null;
    //   }).catchError((e) {
    //     print('logan : '+e.toString());
    //   });
    // }
    // checkForUpdate();
    if (resourcesDownloaded == null || !eq(resourcesDownloaded, listUrls)) {
      try {
        //todo First App Start...
        if (resourcesDownloaded == null) {
          await prefs.setBool("setting_backgroundSound", true);
          await prefs.setBool("setting_soundEffect", true);
          await prefs.setBool("setting_vibrate", false);
          await prefs.setBool("setting_push", true);
          await prefs.setBool("setting_sms", true);
          await prefs.setBool("setting_email", true);

          //todo not service now[lowPower, lightingEffect, highResolution]
          await prefs.setBool("setting_lowPower", false);
          await prefs.setBool("setting_lightingEffect", true);
          await prefs.setBool("setting_highResolution", true);
          AppConfig.setting.backgroundSound = true;
          AppConfig.setting.soundEffect = true;
          AppConfig.setting.vibrate = false;
          AppConfig.setting.lowPower = false;
          AppConfig.setting.lightingEffect = false;
          AppConfig.setting.highResolution = true;
          AppConfig.setting.push = true;
          AppConfig.setting.sms = true;
          AppConfig.setting.email = true;
        }
        return ResourcesStatus.not_downloaded;
      } on Exception {
        throw GetResourcesFailure();
      }
    } else {
      AppConfig.setting.backgroundSound =
          prefs.getBool("setting_backgroundSound")!;
      AppConfig.setting.soundEffect = prefs.getBool("setting_soundEffect")!;
      AppConfig.setting.vibrate = prefs.getBool("setting_vibrate")!;
      AppConfig.setting.lowPower = prefs.getBool("setting_lowPower")!;
      AppConfig.setting.lightingEffect =
          prefs.getBool("setting_lightingEffect")!;
      AppConfig.setting.highResolution =
          prefs.getBool("setting_highResolution")!;
      AppConfig.setting.push = prefs.getBool("setting_push")!;
      AppConfig.setting.sms = prefs.getBool("setting_sms")!;
      AppConfig.setting.email = prefs.getBool("setting_email")!;
      return ResourcesStatus.downloaded;
    }
  }

  Future<void> sendItemMail(int gap) async {
    int coins = gap ~/ 600000;
    await _firestore
        .collection('Users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'u_lastSeen': DateTime.now().millisecondsSinceEpoch.toString(),
      'u_playCoin' : FieldValue.increment(coins),
      'u_online': true
    });
    await _firestore
        .collection('Users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'is_newMail': true});
    // await _firestore
    //     .collection('Users')
    //     .doc(_firebaseAuth.currentUser!.uid)
    //     .collection('Mail')
    //     .add({
    //   'type': 'Admin',
    //   'title': "일일 접속 보상(레이저)",
    //   'message': '접속 보상 아이템을 수령하세요',
    //   'reg_date': formatDate(
    //       DateTime(
    //           DateTime.now().year, DateTime.now().month, DateTime.now().day),
    //       [yyyy, '-', mm, '-', dd]),
    //   'product_id': "Kg7FwHVP29hrsMPBf4zC",
    //   'product_type': "Item",
    //   'from_name': "캐치찬스 운영팀",
    //   'from_url':""
    // });
    await _firestore
        .collection('Users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('Mail')
        .add({
      'type': 'Admin',
      'title': "일일 접속 보상(시간추가)",
      'message': '접속 보상 아이템을 수령하세요',
      'reg_date': formatDate(
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          [yyyy, '-', mm, '-', dd]),
      'product_id': "5OTzhZsgY4LkZjWBh4Db",
      'product_type': "Item",
      'from_name': "캐치찬스 운영팀",
      'from_url':""
    });
  }

  Stream<String> _getResources() async* {
    final SharedPreferences prefs = await _prefs;
    final data = await _firestore
        .collection('APP_SYSTEM')
        .doc('GAME_RESOURCE')
        .collection('FILE_LIST')
        .where('fileName', isEqualTo: AppConfig.fileName)
        .get()
        .then((value) => value.docs[0].data());
    final resourcesDownloaded = prefs.getStringList('resourcesDownloadedUrl');
    final Map<String, String> mapData =
        data['downloadUrl'].cast<String, String>();
    List<String> listUrls = [];
    print(mapData.toString());
    mapData.forEach((key, value) {
      print(value);
      listUrls.add(value);
    });
    Function eq = const ListEquality().equals;
    AppConfig.appDocDirectory = await getApplicationDocumentsDirectory();
    if (resourcesDownloaded == null || !eq(resourcesDownloaded, listUrls)) {
      if (resourcesDownloaded != null) {
        listUrls
            .removeWhere((element) => resourcesDownloaded.contains(element));
      }
      yield "Started";

      AppConfig.appDocDirectory = await getApplicationDocumentsDirectory();
      final client = http.Client();
      // final dir = Directory(AppConfig.appDocDirectory.path);
      // dir.deleteSync(recursive: true);

      for (final url in listUrls) {
        final http.StreamedResponse response =
            await client.send(http.Request('GET', Uri.parse(url.toString())));
        final zc = ZipDecoder();
        final fileCount = '${listUrls.indexOf(url) + 1}/${listUrls.length}';
        final List<int> _bytes = [];
        await for (final value in response.stream) {
          _bytes.addAll(value);
          //print('value  :  $received   fileSize  :  ${response.contentLength}');
          //print("Download started"+ (received/response.contentLength).toString() + "%");

          // ignore: prefer_is_empty

          if (_bytes.length.remainder(153) == 0) {
            yield '${_bytes.length / response.contentLength!}%$fileCount';
          }
          if (_bytes.length == response.contentLength) {
            final Directory directory =
                await Directory(AppConfig.appDocDirectory!.path)
                    .create(recursive: true);
            final archive = zc.decodeBytes(_bytes);
            for (final file in archive) {
              final filename = file.name;
              if (file.isFile) {
                final data = file.content as List<int>;
                File('${'${directory.path}/osgame/'}$filename')
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(data);
              }
            }
          }
        }
      }

      List<String> listSetResList = [];
      print(mapData.toString());
      mapData.forEach((key, value) {
        print(value);
        listSetResList.add(value);
      });
      await prefs.setStringList('resourcesDownloadedUrl', listSetResList);
      yield "Done";
    }
  }

  /// Creates a new user with the provided [email] and [password].
  /// Throws a [SignUpFailure] if an exception occurs.

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    // assert(email != null && password != null);
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw SignUpFailure();
    }
  }

  Future<String> logInWithNickname(
      Map<String, Object> user, String? name) async {
    if (name != null) {
      return _firestore
          .collection('Users')
          .where('u_name', isEqualTo: name)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {
          await _firebaseAuth.signInAnonymously().then((value) async {
            final DocumentReference ref =
                _firestore.collection('CountOfCollection').doc('User');
            final int index = await _firestore.runTransaction((transaction) {
              return transaction.get(ref).then((value) {
                //transaction.update(ref, {'count': value.get('count'] + 1});
                return (value.get('count') as int) + 1;
              });
            });
            await _firestore.collection('Users').doc(value.user!.uid).set({
              'u_id': value.user!.uid,
              'u_name': name,
              'u_coin': 0,
              'u_index': index,
              'u_playCoin': 50,
              'u_lastSeen': DateTime.now().millisecondsSinceEpoch.toString(),
              'u_online': true,
              'u_rankPoint': 0,
              'u_level': "1",
              'u_email': user['email'],
              'u_imgUrl': user['imgSmall'],
              'u_imgUrlHigh': user['imgBig'],
              'is_newMail': true,
              'is_deleted': false,
              'u_totalPlayCount': 0,
              'u_stage1Reward': 0,
              'u_stage2Reward': 0,
              'u_stage3Reward': 0,
              'u_stage4Reward': 0,
              'u_stage5Reward': 0,
              'u_stage6Reward': 0,
              'u_stage1Total': 0,
              'u_stage2Total': 0,
              'u_stage3Total': 0,
              'u_stage4Total': 0,
              'u_stage5Total': 0,
              'u_stage6Total': 0,
              'u_stage1Wins': 0,
              'u_stage2Wins': 0,
              'u_stage3Wins': 0,
              'u_stage4Wins': 0,
              'u_stage5Wins': 0,
              'u_stage6Wins': 0,
              'u_wins': 0,
              'itemPlayTime': 50,
              'itemLaserCount': 50,
              'itemRotateCount': 1,
              'itemPurpleCoin': 0,
              'itemGoldCoin': 0,
            });
            try {
              await value.user!.linkWithCredential(EmailAuthProvider.credential(
                email:
                    "${user['id']}@orangestep${user['provider']}login.orange",
                password: user['id'].toString(),
              ));

              await _firestore
                  .collection('Friends')
                  .doc(value.user!.uid)
                  .set({'friends': [], 'receives': [], 'sends': []});
            } catch (e) {
              await _firestore.collection('Users').doc(value.user!.uid).delete();
            }
            await _firestore
                .collection('CountOfCollection')
                .doc('User')
                .update({'count': FieldValue.increment(1)});
          });
          // await _firebaseAuth.currentUser!.reload();
          return "Ok";
        } else {
          return "exist";
        }
      });
    } else {
      await _firebaseAuth.signInWithCredential(EmailAuthProvider.credential(
        email: "${user['id']}@orangestep${user['provider']}login.orange",
        password: user['id'].toString(),
      ));
      return "Ok";
    }
  }

  Future<void> giveTimePassReward(int amount) async {
    await _firestore
        .collection('Users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'u_playCoin': FieldValue.increment(amount)});
  }

  /// Starts the Sign In with Google Flow.
  Future<Map<String, Object>> getGoogleCredential() async {
    // try {
      print("google login stated");
      final googleUser = await _googleSignIn.signIn();
      print("google got sightins");
      await googleUser!.authentication;
      final Map<String, Object> userData = {
        'id': googleUser.id,
        'imgBig': googleUser.photoUrl!.replaceAll("s96-c", "s400-c"),
        'imgSmall': googleUser.photoUrl!,
        'email': "google_${googleUser.id}_${googleUser.email}",
        'provider': 'google'
      };
      return userData;
    // } catch (e) {
    //   throw GetGoogleCredentialFailure();
    // }
  }

  Future<Map<String, Object>> getFaceBookCredential() async {
    try {
      final facebookLogin = FacebookLogin();
      final result =
          await facebookLogin.logIn(permissions: [
            FacebookPermission.publicProfile,
            FacebookPermission.email
          ]);
      if(result.status == FacebookLoginStatus.success){
        final http.Response resultFacebook = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=id,picture.width(800).height(800),email&access_token=${result.accessToken!.token}'));

        final facebookResult = json.decode(resultFacebook.body);

        final Map<String, Object> userData = {
          'id': facebookResult['id'],
          'imgBig': facebookResult['picture']['data']['url'],
          'imgSmall': facebookResult['picture']['data']['url'],
          'email':
              "facebook_${facebookResult['id']}_${facebookResult['email']}",
          'provider': 'facebook'
        };

        return userData;
      }
      else{
        throw GetFaceBookCredentialFailure();
      }
    } catch (e) {
      throw GetFaceBookCredentialFailure();
    }
  }

  Future<Map<String, Object>> getKakaoLoginData() async {
    try {

      final installed = await isKakaoTalkInstalled();
      final String authCode =  installed ? await _authCodeClient.requestWithTalk() : await _authCodeClient.request();

      final AccessTokenResponse token =
          await AuthApi.instance.issueAccessToken(authCode);
      await TokenManager.instance.setToken(token);
      final user = await UserApi.instance.me();
      final Map<String, Object> userData = {
        'id': user.id.toString(),
        'imgBig': user.kakaoAccount!.profile!.profileImageUrl.toString(),
        'imgSmall': user.kakaoAccount!.profile!.thumbnailImageUrl.toString(),
        'email': "kakao_${user.id}_${user.kakaoAccount!.email}",
        'provider': 'kakao'
      };
      return userData;
    } catch (e) {
      throw GetKakaoLoginDataFailure();
    }
  }

  Future<String> updateNickname(String nickname) async {
    return _firestore
        .collection('Users')
        .where('u_name', isEqualTo: nickname)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        await _firestore
            .collection('Users')
            .doc(_firebaseAuth.currentUser!.uid)
            .update({'u_name': nickname});
        return "닉네임이 수정되었습니다.";
      } else {
        return "이미 존재하는 닉네임 입니다.";
      }
    });
  }

  Future<Map<String, Object>> getLineLoginData() async {
    try {
      final result = await _lineSDK.login();
      final Map<String, Object> userData = {
        'id': result.userProfile!.userId,
        'imgBig': result.userProfile!.pictureUrlLarge!,
        'imgSmall': result.userProfile!.pictureUrlSmall!,
        'email':
            "line_${result.userProfile!.userId}_${result.userProfile!.displayName}@somefakemail.com",
        'provider': 'line'
      };
      return userData;
    } on Exception {
      throw GetKakaoLoginDataFailure();
    }
  }

  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _lineSDK.logout(),
      ]);
    } catch (e) {
      // throw LogOutFailure();
    }
  }

  Future<void> setUserOffline(String uId) async {
    await _firestore.collection("Users").doc(uId).update({'u_online': false});
  }

  Future<void> close() async {
    group.close();
  }
}

extension on DocumentSnapshot {
  UserData get toUserData {
    return UserData.fromToData(data() as Map<String,dynamic>);
  }
}

enum ResourcesStatus { initial, not_downloaded, downloaded }
