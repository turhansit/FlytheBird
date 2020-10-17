import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class pushNotificationsServices {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialise() async {
    if (Platform.isAndroid) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    }, onResume: (Map<String, dynamic> message) async {
      print('onMessage: $message');
    });
  }
}
