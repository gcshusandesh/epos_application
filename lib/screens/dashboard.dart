import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/extra_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/providers/user_provider.dart';
import 'package:epos_application/screens/menu/menu_page.dart';
import 'package:epos_application/screens/profile_screen.dart';
import 'package:epos_application/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'employees/manage_employee.dart';

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
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      // Test API Call
      // Provider.of<InfoProvider>(context, listen: false).getTestData();
      if (mounted) {
        await Provider.of<ExtraProvider>(context, listen: false)
            .checkInternetConnection(context: context);
      }
      if (mounted) {
        // Get Specials Data from API
        Provider.of<MenuProvider>(context, listen: false)
            .getSpecialsList(init: true);

        // Get Employee Data from API
        Provider.of<UserProvider>(context, listen: false)
            .getUsersList(init: true);

        // Get Category Data from API
        Provider.of<MenuProvider>(context, listen: false)
            .getCategoryList(init: true);

        // Get Menu Items by Category Data from API
        Provider.of<MenuProvider>(context, listen: false)
            .getMenuItemsByCategory(init: true);

        init = false;
      }
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 2),
                child: topSection(context),
              ),
              optionsSection(context),
            ]),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Column optionsSection(BuildContext context) {
    return Column(
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
              "menu",
              height,
              width,
              () {
                //can be used to initialise category as well
                Provider.of<MenuProvider>(context, listen: false)
                    .resetCategory();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              },
              context,
            ),
            dashboardItem(
              "assets/dashboard/order.svg",
              "order",
              height,
              width,
              () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const ColorPickerExample()),
                // );
              },
              context,
            ),
            dashboardItem(
              "assets/dashboard/payment.svg",
              "Payment",
              height,
              width,
              () {},
              context,
            ),
            dashboardItem(
              "assets/dashboard/sales.svg",
              "Sales History",
              height,
              width,
              () {},
              context,
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
              "assets/dashboard/employees.svg",
              "My Employee",
              height,
              width,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageEmployee()),
                );
              },
              context,
            ),
            dashboardItem(
              "assets/dashboard/inventory.svg",
              "Inventory",
              height,
              width,
              () {
                //do something
              },
              context,
            ),
            dashboardItem(
              "assets/dashboard/analytics.svg",
              "Analytics",
              height,
              width,
              () {},
              context,
            ),
          ],
        ),
      ],
    );
  }

  Row topSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(opacity: 0, child: options(context)),
        buildTitleText("Dashboard", Data.darkTextColor, width),
        options(context),
      ],
    );
  }

  Row options(BuildContext context) {
    return Row(
      children: [
        iconButton(
          "assets/svg/profile_icon.svg",
          height,
          width,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          context: context,
        ),
        SizedBox(width: width * 2),
        iconButton(
          "assets/svg/settings.svg",
          height,
          width,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Settings()),
            );
          },
          context: context,
        ),
        SizedBox(width: width * 2),
      ],
    );
  }

  InkWell buildMenuItem(IconData icon, String text, Color color) {
    return InkWell(
      onTap: () {
        // print("Tapped $text");
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
