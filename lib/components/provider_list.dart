import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/employee_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<InfoProvider>(create: (_) => InfoProvider()),
  ChangeNotifierProvider<EmployeeProvider>(create: (_) => EmployeeProvider()),
  ChangeNotifierProvider<MenuProvider>(create: (_) => MenuProvider()),
];
