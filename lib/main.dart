import 'package:flutter/material.dart';
import 'package:myagenda/app.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();

  // Init translations
  await i18n.init();
  // Init shared preferences
  final prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs));
}
