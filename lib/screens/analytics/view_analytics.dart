import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/screens/employees/manage_employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewAnalytics extends StatefulWidget {
  const ViewAnalytics({super.key});

  @override
  State<ViewAnalytics> createState() => _ViewAnalyticsState();
}

class _ViewAnalyticsState extends State<ViewAnalytics> {
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: topSection(
              context: context,
              height: height,
              text: "Analytics",
              width: width,
            ),
          ),
          Container(
            color: Provider.of<InfoProvider>(context, listen: true)
                .systemInfo
                .iconsColor
                .withOpacity(0.5),
            margin: EdgeInsets.symmetric(vertical: height * 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: height * 30,
            child: Column(
              children: [
                buildCustomText(
                    "Employee Data", Data.lightGreyTextColor, width * 2.2,
                    fontWeight: FontWeight.bold),
                SizedBox(height: height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    analyticsBox(
                      title: "Total Employees",
                      count: 10,
                      context: context,
                      isTotal: true,
                    ),
                    analyticsBox(
                      title: "Active Employees",
                      count: 10,
                      context: context,
                    ),
                    analyticsBox(
                      title: "Total Employees",
                      count: 10,
                      context: context,
                    ),
                    topEmployeeBox(context: context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container analyticsBox({
    required BuildContext context,
    required int count,
    required String title,
    bool isTotal = false,
  }) {
    return Container(
      width: width * 15,
      height: height * 20,
      padding: EdgeInsets.symmetric(horizontal: width),
      decoration: BoxDecoration(
        color: Provider.of<InfoProvider>(context, listen: true)
            .systemInfo
            .primaryColor,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            spreadRadius: 0, // How much the shadow spreads
            blurRadius: 4, // How much the shadow blurs
            offset: const Offset(0, 5), // The offset of the shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomText(count.toString(), Colors.white, width * 3,
                  fontWeight: FontWeight.bold),
              isTotal
                  ? InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ManageEmployee()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.remove_red_eye,
                              color: Colors.white, size: width * 1.5),
                          SizedBox(width: width * 0.2),
                          buildCustomText("View", Colors.white, width * 1.5),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(
            height: height,
          ),
          buildCustomText(title, Colors.white, width * 1.65,
              fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Container topEmployeeBox({
    required BuildContext context,
  }) {
    return Container(
      width: width * 20,
      height: height * 20,
      padding: EdgeInsets.symmetric(horizontal: width),
      decoration: BoxDecoration(
        color: Provider.of<InfoProvider>(context, listen: true)
            .systemInfo
            .primaryColor,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            spreadRadius: 0, // How much the shadow spreads
            blurRadius: 4, // How much the shadow blurs
            offset: const Offset(0, 5), // The offset of the shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildCustomText("Top Employee(Month)", Colors.white, width * 1.7,
              fontWeight: FontWeight.bold),
          SizedBox(
            height: height,
          ),
          buildCustomText("Mr Shusandesh G C", Colors.white, width * 1.65),
        ],
      ),
    );
  }
}
