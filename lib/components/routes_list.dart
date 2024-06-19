import 'package:epos_application/screens/dashboard.dart';
import 'package:epos_application/screens/login_screen.dart';
import 'package:epos_application/screens/splash_screen.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> routes = {
  SplashScreen.routeName: (ctx) => const SplashScreen(),
  LoginScreen.routeName: (ctx) => const LoginScreen(),
  Dashboard.routeName: (ctx) => const Dashboard(),
};
