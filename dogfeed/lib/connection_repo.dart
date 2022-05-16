import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ConnectionRepository {
  Future<void> connectToServer() async {
    final rawHeader = {'tokenpassword': 'dhfpswltmxpqserverDogFeed'};
    // _socket.disconnect();
    //  http://3.35.68.27:5252/mac_1
    //  http://192.168.50.13:5252/mac_1
    _socket = io.io(
        'http://192.168.50.13:5252/mac_1',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders(rawHeader)
            .build());
    _socket.connect();
    _socket.on('connect', (d) {
      print("Connection Data: $d");
      _socket.emit('user', {
        'uid': "User",
      });
    });

    _socket.on('notify', (data) {
      print("Notify ${data}");
      _streamController.sink
          .add({"notify":data});
    });

    _socket.on('weight_list', (data) {
      _streamController.sink
          .add({"weights":data});
    });
  }

  late io.Socket _socket;
  final _streamController = StreamController<Map>();
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<bool> get isUser {
    return _firebaseAuth.idTokenChanges().map((firebaseUser){
      if(firebaseUser == null) {
        return false;
      }else{
        return true;
      }
    });
  }

  Future<void> loginWithGoogle()async{
    final googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    try {
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // handle the error here
      }
      else if (e.code == 'invalid-credential') {
        // handle the error here
      }
    } catch (e) {
      // handle the error here
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    // ignore: empty_catches
    } catch (e){

    }
  }


  Stream<Map> get conditions => _streamController.stream;

  void reserve(int key, int amount) {
    _socket.emit('reserve', {"stamp" : key, "amount": amount});
  }

  void update(data) {
    _socket.emit('update_val', data);
  }

  void deleteReserve(key) {
    _socket.emit('del_reserve', key);
  }

  void givefood() {
    _socket.emit('give_food');
  }

  void getWeightList() {
    _socket.emit('get_weights');
  }

  Future<void> close() async {
    _streamController.close();
    _socket.clearListeners();
    _socket.dispose();
    _socket.destroy();
  }
}
