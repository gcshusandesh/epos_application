import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/extra_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/providers/upload_provider.dart';
import 'package:epos_application/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<InfoProvider>(create: (_) => InfoProvider()),
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
  ChangeNotifierProvider<MenuProvider>(create: (_) => MenuProvider()),
  ChangeNotifierProvider<ExtraProvider>(create: (_) => ExtraProvider()),
  ChangeNotifierProvider<UploadProvider>(create: (_) => UploadProvider()),
];
