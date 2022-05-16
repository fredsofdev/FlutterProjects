//
// // Create a [AndroidNotificationChannel] for heads up notifications
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// AndroidNotificationChannel channel;
// /// Initialize the [FlutterLocalNotificationsPlugin] package.
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// class AppFCM{
//
//   // ignore: avoid_void_async
//   static void setFCM({@required String uniqueId}) async{
//     if (true) {
//       channel = const AndroidNotificationChannel(
//         'high_importance_channel', // id
//         'High Importance Notifications', // title
//         'This channel is used for important notifications.', // description
//         importance: Importance.high,
//       );
//
//       flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//       /// Create an Android Notification Channel.
//       ///
//       /// We use this channel in the `AndroidManifest.xml` file to override the
//       /// default FCM channel to enable heads up notifications.
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);
//
//       /// Update the iOS foreground notification presentation options to allow
//       /// heads up notifications.
//       await FirebaseMessaging.instance
//           .setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: false,
//         sound: true,
//       );
//     }
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage message) {
//
//     });
//
//     FirebaseMessaging.instance.subscribeToTopic('t$uniqueId').then((value){
//       print('subscribe to topic t$uniqueId');
//     });
//
//     FirebaseMessaging.instance.subscribeToTopic('all').then((value){
//       print('subscribe to topic');
//     });
//
//
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//
//       final RemoteNotification notification = message.notification;
//       final AndroidNotification android = message.notification?.android;
//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 channel.id,
//                 channel.name,
//                 channel.description,
//                 // TODO add a proper drawable resource to android, for now using
//                 // one that already exists in example app.
//                 icon: 'launch_background',
//               ),
//             )
//         );
//       }
//     });
//
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//     });
//   }
// }