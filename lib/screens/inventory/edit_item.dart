import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:flutter/material.dart';

class EditItem extends StatefulWidget {
  const EditItem({super.key});

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      init = false;
    }
  }

  void _fetchData({bool reload = false}) {
    if (reload) {
      setState(() {
        isLoading = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainBody(context),
        isLoading
            ? onLoading(width: width, context: context)
            : const SizedBox(),
      ],
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            customTopSection(
                context: context,
                height: height,
                text: "Inventory Unit Type",
                width: width,
                onTap: () {
                  _fetchData(reload: true);
                }),
          ],
        ),
      ),
    );
  }
}
