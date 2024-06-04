import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mamba/app/app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

class Bootstrap with PlatformMixin {
  // Initialize Variables
  final FirebaseOptions? firebaseOptions;
  Bootstrap(this.firebaseOptions);
  // Initialize Function
  Future<void> initialize() async {
    runZonedGuarded(
      () async {
        // Initialize App
        WidgetsFlutterBinding.ensureInitialized();
        // Initialize Hive
        await Hive.initFlutter();
        // Initialize Env Variables
        String envFileName = ".env.${flavor.name}";
        await dotenv.load(fileName: envFileName);
        // Initialize Firebase
        if (isWeb) {
          // Web = Firebase Options
          await Firebase.initializeApp(options: firebaseOptions);
        } else {
          // Mobile = Firebase .json or .plist
          await Firebase.initializeApp();
        }

        // TO DO: NETEJAR AIXÒ PER AL SEU PROPI CUBIT
        /////////////////////////////////////////////

        mixpanel = await Mixpanel.init(
          dotenv.env['MIXPANEL_KEY']!,
          trackAutomaticEvents: true,
          optOutTrackingDefault: false,
        );

        // Initialise TimeZone
        timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
        // Firebase Messaging Back Ground Message Handler
        FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
        // Firebase Dynamic Links
        if (isWeb == false) {
          await DynamicLinkUtils().retrieveDynamicLink();
        }

        /////////////////////////////////////////////
        // TO DO: NETEJAR AIXÒ PER AL SEU PROPI CUBIT

        // Firebase Crashlytics on Global Uncaught Errors
        if (flavor != Flavor.development) {
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;
        }
        // For Path Url Strategy in Web
        usePathUrlStrategy();
        // Run App
        runApp(App());
      },
      (error, stackTrace) {
        if (flavor != Flavor.development) {
          // Firebase Crashlytics on Explicitly Caught Exceptions
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
        }
        print("Error:");
        print(error);
        print(stackTrace);        
      },
    );
  }
}