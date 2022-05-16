// import 'package:flutter/material.dart';
//
// class FaceBookAdScreen extends StatefulWidget {
//   @override
//   _FaceBookAdScreenState createState() => _FaceBookAdScreenState();
// }
//
// class _FaceBookAdScreenState extends State<FaceBookAdScreen> {
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     FacebookAudienceNetwork.init(
//       testingId: '3f541525-47c1-497d-9618-999175aa350a'
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           const Text('Facebook AD'),
//           Container(
//             alignment: const Alignment(0.5, 1),
//             child: FacebookNativeAd(
//               placementId: '1088107105005052_1088109968338099',//'1088107105005052_1088109968338099',
//               adType: NativeAdType.NATIVE_AD,
//               height: 300,
//               backgroundColor: Colors.orange,
//               titleColor: Colors.white,
//               descriptionColor: Colors.white,
//               buttonColor: Colors.orange,
//               buttonTitleColor: Colors.white,
//               buttonBorderColor: Colors.white,
//               keepAlive: true, //set true if you do not want adview to refresh on widget rebuild
//               keepExpandedWhileLoading: false, // set false if you want to collapse the native ad view when the ad is loading
//               expandAnimationDuraion: 300, //in milliseconds. Expands the adview with animation when ad is loaded
//               listener: (result, value) {
//                 print("Native Ad: $result --> $value");
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
