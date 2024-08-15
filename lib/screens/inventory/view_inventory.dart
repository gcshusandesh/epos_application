import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:flutter/material.dart';

class ViewInventory extends StatefulWidget {
  const ViewInventory({super.key});

  @override
  State<ViewInventory> createState() => _ViewInventoryState();
}

class _ViewInventoryState extends State<ViewInventory> {
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: customTopSection(
                context: context,
                height: height,
                text: "Analytics",
                width: width,
                onTap: () {
                  _fetchData(reload: true);
                }),
          ),
        ],
      ),
    );
  }
}
