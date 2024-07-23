import 'package:epos_application/screens/dashboard.dart';
import 'package:epos_application/screens/employees/create_employee.dart';
import 'package:epos_application/screens/employees/manage_employee.dart';
import 'package:epos_application/screens/image_upload.dart';
import 'package:epos_application/screens/login_screen.dart';
import 'package:epos_application/screens/menu/edit_category.dart';
import 'package:epos_application/screens/menu/edit_specials.dart';
import 'package:epos_application/screens/menu/menu_page.dart';
import 'package:epos_application/screens/profile_screen.dart';
import 'package:epos_application/screens/reset_password.dart';
import 'package:epos_application/screens/settings.dart';
import 'package:epos_application/screens/splash_screen.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> routes = {
  SplashScreen.routeName: (ctx) => const SplashScreen(),
  LoginScreen.routeName: (ctx) => const LoginScreen(),
  ResetPassword.routeName: (ctx) => const ResetPassword(),
  Dashboard.routeName: (ctx) => const Dashboard(),
  Settings.routeName: (ctx) => Settings(),
  ProfileScreen.routeName: (ctx) => const ProfileScreen(),
  ImageUpload.routeName: (ctx) => ImageUpload(),

  // Analytics Section

  // Employees Section
  ManageEmployee.routeName: (ctx) => const ManageEmployee(),
  CreateEmployee.routeName: (ctx) => const CreateEmployee(),

  // Inventory Section

  // Menu Section
  MenuPage.routeName: (ctx) => const MenuPage(),
  EditCategory.routeName: (ctx) => const EditCategory(),
  EditSpecials.routeName: (ctx) => const EditSpecials(),

  // Orders Section

  // Payments Section

  // Sales Section
};
