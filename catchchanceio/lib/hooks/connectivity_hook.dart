

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useConnectivity(
    BuildContext context, {
      Function? connectionUpdate,
    }) =>
    use(_ConnectivityUpdate(connectionUpdate!));

class _ConnectivityUpdate extends Hook<void> {
  final Function connectionUpdate;

  const _ConnectivityUpdate(this.connectionUpdate);

  @override
  _ConnectivityUpdateState createState() => _ConnectivityUpdateState();
}

class _ConnectivityUpdateState extends HookState<void, _ConnectivityUpdate> {
  StreamSubscription? subscription;
  @override
  void build(BuildContext context) {}

  @override
  void initHook() {
    super.initHook();
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      hook.connectionUpdate.call(result);
    });
  }


  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}