import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMethod {
  static String getCurrentTimeStamp() {
    const int diffHour = 0;
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
    int nowMill = DateTime.now().millisecondsSinceEpoch;
    nowMill = nowMill + (3600 * 1000 * diffHour); //todo 9시간 플러스
    final datetime = DateTime.fromMillisecondsSinceEpoch(nowMill);
    return dateFormat.format(datetime);
  }
}

void showToastMessage(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 15.0);
}


Future<bool> isFirstTime() async{
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  final f = prefs.getBool("isFirst");

  return f!;
}




//todo 현재 날짜 체크 및 광고 최대 시청 횟수 제어
Future<bool> checkMaxAdvertisementCount() async{

  //todo 광고 하루 시청 최대 횟수.
  const _maxAdCnt=10;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;


  final DateTime now = DateTime.now();
  final DateTime date = DateTime(now.year, now.month, now.day,now.hour+9);

  final String _today = date.toString().split(' ')[0];
  final String? todayDate = prefs.getString('today_date');


  if(_today!=todayDate){
    await prefs.setString('today_date', _today);
    await prefs.setInt('ad_cnt', _maxAdCnt);
  }

  int adCnt = prefs.getInt('ad_cnt')!;
  if(adCnt==0){
    return false;
  }else{
    adCnt--;
    await prefs.setInt('ad_cnt', adCnt);
    return true;
  }


}























