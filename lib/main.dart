import 'package:epos_application/components/provider_list.dart';
import 'package:epos_application/screens/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCVmYrZ6YLuKLOCCKpXqYjg7zzSPTkF0RA",
            authDomain: "epos-system-242bb.firebaseapp.com",
            projectId: "epos-system-242bb",
            storageBucket: "epos-system-242bb.appspot.com",
            messagingSenderId: "590041475178",
            appId: "1:590041475178:web:6c7c9e95096bc67a958213",
            measurementId: "G-46KX179EZT"));
  }

  //initializing firebase
  await Firebase.initializeApp();

  ///record error on firebase crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

//enabling app to run only in landscape mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: SafeArea(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
            navigatorObservers: [observer],
          ),
        ));
  }
}
