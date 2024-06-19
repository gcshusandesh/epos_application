import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  static const routeName = "dashboard";

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool init = true;
  late double height;
  late double width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      // Test API Call
      // Provider.of<InfoProvider>(context, listen: false).getTestData();
      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: height * 2,
              ),
              buildTitleText("Dashboard", Data.darkTextColor, width),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: height * 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      dashboardItem(
                        "assets/dashboard/menu.svg",
                        "Menu",
                        height,
                        width,
                      ),
                      dashboardItem(
                        "assets/dashboard/menu.svg",
                        "Order",
                        height,
                        width,
                      ),
                      dashboardItem(
                        "assets/dashboard/menu.svg",
                        "Payment",
                        height,
                        width,
                      ),
                      dashboardItem(
                        "assets/dashboard/menu.svg",
                        "Sales History",
                        height,
                        width,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      dashboardItem(
                        "assets/dashboard/menu.svg",
                        "My Employee",
                        height,
                        width,
                      ),
                      dashboardItem(
                        "assets/dashboard/menu.svg",
                        "Inventory",
                        height,
                        width,
                      ),
                      dashboardItem(
                        "assets/dashboard/menu.svg",
                        "Analytics",
                        height,
                        width,
                      ),
                    ],
                  ),
                ],
              ),
            ]),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  InkWell buildMenuItem(IconData icon, String text, Color color) {
    return InkWell(
      onTap: () {
        print("Tapped $text");
      },
      child: Expanded(
        child: Container(
          color: Colors.teal,
          child: Column(
            children: [
              Icon(icon, color: color, size: width * 10),
              buildBodyText(
                text,
                color,
                width,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
