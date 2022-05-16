import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useLifeCycleUpdate(
  BuildContext context, {
  required Function lifeCycleUpdate,
}) =>
    use(_LifeCycleUpdate(lifeCycleUpdate));

class _LifeCycleUpdate extends Hook<void> {
  final Function lifeCycleUpdate;

  const _LifeCycleUpdate(this.lifeCycleUpdate);

  @override
  _LifeCycleUpdateState createState() => _LifeCycleUpdateState();
}

class _LifeCycleUpdateState extends HookState<void, _LifeCycleUpdate>
    with WidgetsBindingObserver {
  @override
  void build(BuildContext context) {}

  @override
  void initHook() {
    super.initHook();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    hook.lifeCycleUpdate.call(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
