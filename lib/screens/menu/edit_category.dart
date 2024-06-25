import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditCategory extends StatefulWidget {
  const EditCategory({super.key});
  static const routeName = "editCategory";

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  bool init = true;
  late double height;
  late double width;

  List<Category> categoryList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      // Get Category Data from API
      Provider.of<DataProvider>(context, listen: false).getCategoryList();
      categoryList =
          Provider.of<DataProvider>(context, listen: false).categoryList;

      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
