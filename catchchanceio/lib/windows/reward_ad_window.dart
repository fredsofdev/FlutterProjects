import 'package:catchchanceio/constants/color.dart';
import 'package:catchchanceio/repository/authentication/models/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_overlay/loading_overlay.dart';

class RewardAdWindow extends StatefulWidget {
  final String userId;
  final String rewardType;
  final int amount;

  @override
  _RewardAdWindowState createState() => _RewardAdWindowState();

  const RewardAdWindow({required this.userId, required this.rewardType, required this.amount});
}

class _RewardAdWindowState extends State<RewardAdWindow> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  RewardedAd? _rewardedAd;
  bool _isLoading = true;
  bool _isRewarded = false;

  @override
  void initState() {
    super.initState();
    RewardedAd.load(
      adUnitId: AppConfig.admobRewardedAdUnitID,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            this._rewardedAd = ad;
            this._rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad){
                setState(() {
                  _isLoading = false;
                });
              },
              onAdDismissedFullScreenContent: (RewardedAd ad){
                Navigator.pop(context, _isRewarded);
              },
              onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error){
                Navigator.pop(context, _isRewarded);
              },
              onAdImpression: (RewardedAd ad) => print('$ad impression occurred'),

            );

            this._rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem){
              _fireStore
                  .collection("Users")
                  .doc(widget.userId)
                  .update({widget.rewardType: FieldValue.increment(widget.amount)});
              _isRewarded = true;
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
      )
    );


  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: _isLoading,
        color: Colors.white,
        progressIndicator: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appMainColor),
        ),
        child: Container(
          color: Colors.white,
        ));
  }
}
