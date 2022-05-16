import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../authentication_repository.dart';
import '../authentication_repository.dart';
import 'models/models.dart';

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
  AuthenticationRepository({
    FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignIn,
    StorageReference storageReference,
    Future<SharedPreferences> prefs,
    Firestore firestore,
    AuthCodeClient authCodeClient,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        _storageReference = storageReference ?? FirebaseStorage.instance.ref(),
        _prefs = prefs ?? SharedPreferences.getInstance(),
        _firestore = firestore ?? Firestore.instance,
        _authCodeClient = authCodeClient ?? AuthCodeClient.instance;



  final GoogleSignIn _googleSignIn;
  final AuthCodeClient _authCodeClient;

  final Firestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final Future<SharedPreferences> _prefs;
  final StorageReference _storageReference;

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.

  Stream<UserData> get user {
    var group = StreamGroup<UserData>();
    var subscribe;
    _firebaseAuth.onAuthStateChanged.forEach((firebaseUser) {
      try{
        group.remove(subscribe);
      }catch (e){
        print("Error happened while removing subscription");
      }
      subscribe = _firestore.collection("Users").document(firebaseUser != null ? firebaseUser.uid : 'empty')
          .snapshots().map((doc) => doc.exists ? doc.toUserData : UserData.empty);
      group.add(subscribe);
    });
    group.close();
    return group.stream;
  }

  Future<String> getUserAuth() async{
     FirebaseUser user =  await _firebaseAuth.currentUser();
     if(user == null){
       return "unknown";
     }else{
       if(user.isAnonymous){
         return 'anonymous';
       }else{
         return 'provider';
       }
     }

  }

  Stream<String> getResources() => _getResources().asBroadcastStream();

  Stream<String> _getResources() async*{

    SharedPreferences prefs = await _prefs;
    bool isResourcesDownloaded = prefs.getBool('isResourcesDownloaded');
    AppConfig.appDocDirectory = await getApplicationDocumentsDirectory();
    print(isResourcesDownloaded.toString());
    if(isResourcesDownloaded==null || !isResourcesDownloaded){
      try{
        //todo First App Start...
        print('[1] first app start!');
        await prefs.setBool("setting_backgroundSound", true);
        await prefs.setBool("setting_soundEffect", true);
        await prefs.setBool("setting_vibrate", true);


        //todo not service now[lowPower, lightingEffect, highResolution]
        await  prefs.setBool("setting_lowPower", false);
        await prefs.setBool("setting_lightingEffect", true);
        await prefs.setBool("setting_highResolution", true);

        AppConfig.setting.backgroundSound=true;
        AppConfig.setting.soundEffect=true;
        AppConfig.setting.vibrate=true;
        AppConfig.setting.lowPower=false;
        AppConfig.setting.lightingEffect=false;
        AppConfig.setting.highResolution=true;

        yield "Started";
        List<int> _bytes = [];
        final client = new http.Client();
        String downloadAddress = await _storageReference.child('/resources/'+AppConfig.firebaseGameResourceFileName).getDownloadURL();
        http.StreamedResponse response = await client.send(http.Request('GET',Uri.parse(downloadAddress)));
        int received=0;
        AppConfig.appDocDirectory = await getApplicationDocumentsDirectory();
        print("Download started");

        await for(var value in response.stream){
          _bytes.addAll(value);
          received += value.length;
          //print('value  :  $received   fileSize  :  ${response.contentLength}');
          //print("Download started"+ (received/response.contentLength).toString() + "%");
          yield (received/response.contentLength).toString();
          if((received/response.contentLength) == 1.0){
            Directory directory = await new Directory(AppConfig.appDocDirectory.path).create(recursive: true);
            var archive = ZipDecoder().decodeBytes(_bytes);
            for(final file in archive){
              final filename = file.name;
              if(file.isFile){
                final data = file.content as List<int>;
                File('${directory.path}/' + filename)
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(data);
              }
            }

            await prefs.setBool('isResourcesDownloaded', true);
            await _firebaseAuth.signInAnonymously().then((result) async{
              await _firestore.collection('Users').document(result.user.uid)
                  .setData({'u_id': result.user.uid,
                            'u_authType': 'anonymous',
                            'u_lastSeen': FieldValue.serverTimestamp(),
                            'u_name': 'anyUserName'});
            });
            await Future.delayed(Duration(milliseconds:1500));
            yield "Done";

          }
        }
      } on Exception {
        throw GetResourcesFailure();
      }

    }else{
      print("It is Downloaded");
      AppConfig.setting.backgroundSound=prefs.getBool("setting_backgroundSound");
      AppConfig.setting.soundEffect=prefs.getBool("setting_soundEffect");
      AppConfig.setting.vibrate=prefs.getBool("setting_vibrate");
      AppConfig.setting.lowPower=prefs.getBool("setting_lowPower");
      AppConfig.setting.lightingEffect=prefs.getBool("setting_lightingEffect");
      AppConfig.setting.highResolution=prefs.getBool("setting_highResolution");
      await _firebaseAuth.currentUser().then((firebaseUser) async{
        if(firebaseUser != null && !firebaseUser.isAnonymous){
         await _firestore.collection("Users").document(firebaseUser.uid)
             .updateData({'u_lastSeen': FieldValue.serverTimestamp()});
        }
      });
      await Future.delayed(Duration(milliseconds: 1500), (){
        print("Downloaded");
      });
      yield "Downloaded";
    }
  }
  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.

  Future<void> signUp({
    @required String email,
    @required String password,
  }) async {
    assert(email != null && password != null);
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw SignUpFailure();
    }
  }


  Future<String> logInWithGoogleFacebookCredentials(AuthCredential credential, String name) async {
    await _firebaseAuth.currentUser().then((value) async{
      if(value != null && value.isAnonymous) {
        var myRef = _firestore.collection('Users').document(value.uid);

        await _firestore.runTransaction((transaction) async {
          await _firestore.collection('Users').where('u_name', isEqualTo: name)
              .getDocuments().then((value) async {
            if (value.documents.length == 0) {
              await transaction.update(myRef, {'u_name': name});
            } else {
              return "exist";
            }
          });
        });
        await value.linkWithCredential(credential).then((value) async{
          var userInfo = value.user.providerData[1];
         await _firestore.collection('Users').document(value.user.uid)
              .updateData({
            'u_coin': 50,
            'u_dia': 0,
            'u_bronze': 0,
            'u_gold': 0,
            'u_silver': 0,
            'u_authType': "provider",
            'u_level': "1",
            'u_imgUrl': userInfo.photoUrl,
            'u_imgUrlHigh': userInfo.photoUrl.replaceAll("s96-c", "s400-c"),
            'u_totalPlayCount': 0,
            'u_wins': 0});
        });
        return "Ok";
      }else{
        await _firebaseAuth.signInWithCredential(credential);
        return "Ok";
      }

    });
    return "Ok";
  }


  Future<String> logInWithKakaoLineData(Map<String, Object> user, String name) async{
    await _firebaseAuth.currentUser().then((value) async{
      if(value != null && value.isAnonymous) {
        var myRef = _firestore.collection('Users').document(value.uid);

        await _firestore.runTransaction((transaction) async {
          await _firestore.collection('Users').where('u_name', isEqualTo: name)
              .getDocuments().then((value) async {
            if (value.documents.length == 0) {
              await transaction.update(myRef, {'u_name': name});
            } else {
              return "exist";
            }
          });
        });
        await value.linkWithCredential(EmailAuthProvider.getCredential(
          email: user['id'].toString()+"@orangestep"+user['provider']+"login.orange",
          password: user['id'].toString(),
        )).then((value) async{
          await _firestore.collection('Users').document(value.user.uid)
              .updateData({
            'u_coin': 50,
            'u_dia': 0,
            'u_bronze': 0,
            'u_gold': 0,
            'u_silver': 0,
            'u_authType': "provider",
            'u_level': "1",
            'u_email': user['email'],
            'u_imgUrl': user['imgSmall'],
            'u_imgUrlHigh': user['imgBig'],
            'u_totalPlayCount': 0,
            'u_wins': 0});
        });
        return "Ok";
      }else{
        await _firebaseAuth.signInWithCredential(EmailAuthProvider.getCredential(
          email: user['id'].toString()+"@orangestep"+user['provider']+"login.orange",
          password: user['id'].toString(),
        ));
        return "Ok";
      }
    });
    return "Ok";
  }

  /// Starts the Sign In with Google Flow.
  Future<AuthCredential> getGoogleCredential() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken);
      return credential;
    } on Exception {
      throw GetGoogleCredentialFailure();
    }
  }

  Future<AuthCredential> getFaceBookCredential() async{
    try{
      FacebookLogin facebookLogin = FacebookLogin();
      FacebookLoginResult result = await facebookLogin.logIn(['email', 'public_profile']);
      AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
      return credential;
    }catch(e){
      print("exception SAMPLE "+ e.toString());
      throw GetFaceBookCredentialFailure();
    }
  }

  Future<Map<String, Object>> getKakaoLoginData() async {
    try {
      String authCode = await _authCodeClient.requestWithTalk();
      AccessTokenResponse token = await AuthApi.instance.issueAccessToken(
          authCode);
      await AccessTokenStore.instance.toStore(token);
      var user = await UserApi.instance.me();
      Map<String, Object> userData = {'id': user.id.toString(),
        'imgBig': user.kakaoAccount.profile.profileImageUrl.toString(),
        'imgSmall': user.kakaoAccount.profile.thumbnailImageUrl.toString(),
        'email': user.kakaoAccount.email.toString(),
        'provider': "kakao"};

      return userData;
    } on Exception {
      // some error happened during the course of user login... deal with it.
      throw GetKakaoLoginDataFailure();
    }
  }

  Future<Map<String, Object>> getLineLoginData() async{
    try {
      final result = await LineSDK.instance.login();
      Map<String, Object> userData = {'id': result.userProfile.userId,
        'imgBig': result.userProfile.pictureUrlLarge,
        'imgSmall': result.userProfile.pictureUrlSmall,
        'email': result.userProfile.displayName+"@somemail.com",
        'provider': "line"};

      return userData;
    } on Exception {
      throw GetKakaoLoginDataFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on Exception {
      throw LogOutFailure();
    }
  }


}

extension on DocumentSnapshot {
  UserData get toUserData {
    return UserData(uId : data['u_id'],uName: data['u_name'],uLevel: data['u_level'] ,uImgBig: data['u_imgUrlHigh'],uImgSmall: data['u_imgUrl'],
        uCoin: data['u_coin'],uBronze: data['u_bronze'],uDia: data['u_dia'],uGold: data['u_gold'],uSilver: data['u_silver'], uAuthType: data['u_authType']);
  }
}
