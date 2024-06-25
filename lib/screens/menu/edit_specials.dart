import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSpecials extends StatefulWidget {
  const EditSpecials({super.key});
  static const routeName = "editSpecials";

  @override
  State<EditSpecials> createState() => _EditSpecialsState();
}

class _EditSpecialsState extends State<EditSpecials> {
  bool init = true;
  late double height;
  late double width;

  List<Specials> specialsList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      // Get Employee Data from API
      Provider.of<DataProvider>(context, listen: false).getSpecialsList();
      specialsList =
          Provider.of<DataProvider>(context, listen: false).specialsList;

      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
