import 'package:epos_application/providers/data_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<InfoProvider>(create: (_) => InfoProvider()),
  ChangeNotifierProvider<DataProvider>(create: (_) => DataProvider()),
];
