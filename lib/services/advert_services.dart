import 'dart:ui';

import 'package:firebase_admob/firebase_admob.dart';

class AdvertService {
  static final AdvertService _instance = AdvertService._internal();
  factory AdvertService() => _instance;
  MobileAdTargetingInfo _targetingInfo;
  final String _bannerAd = 'ca-app-pub-5680866699962870/9456089593';
  AdvertService._internal() {
    _targetingInfo = MobileAdTargetingInfo();
  }
  showBanner() {
    BannerAd banner = BannerAd(adUnitId: BannerAd.testAdUnitId, size: AdSize.smartBanner, targetingInfo: _targetingInfo);
    banner..load() ..show(horizontalCenterOffset: 3.0);
    banner.dispose();
  }

  showIntersitial() {
    InterstitialAd interstitialAd = InterstitialAd(adUnitId:InterstitialAd.testAdUnitId, targetingInfo: _targetingInfo);
    interstitialAd..load()..show();
    interstitialAd.dispose();
  }
}
