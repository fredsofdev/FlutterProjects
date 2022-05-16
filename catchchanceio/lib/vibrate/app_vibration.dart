import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:vibration/vibration.dart';

class AppVibration {
  static Future<void> vibrate({ int? duration}) async {
    if ((await Vibration?.hasVibrator() ?? false) && AppConfig.setting.vibrate) {
      Vibration.vibrate(duration: 2000, amplitude: 50);
    }
  }

  static Future<void> cancel() async {
    Vibration.cancel();
  }
}
