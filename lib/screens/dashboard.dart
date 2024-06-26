import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/employee_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/screens/menu/edit_category.dart';
import 'package:epos_application/screens/menu/edit_menu.dart';
import 'package:epos_application/screens/menu/edit_specials.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      // Test API Call
      // Provider.of<InfoProvider>(context, listen: false).getTestData();

      // Get Specials Data from API
      Provider.of<MenuProvider>(context, listen: false)
          .getSpecialsList(init: true);

      // Get Employee Data from API
      Provider.of<EmployeeProvider>(context, listen: false)
          .getEmployeeData(init: true);

      // Get Category Data from API
      Provider.of<MenuProvider>(context, listen: false)
          .getCategoryList(init: true);

      // Get Menu Items by Category Data from API
      Provider.of<MenuProvider>(context, listen: false)
          .getMenuItemsByCategory(init: true);

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
              () {},
            ),
            dashboardItem(
              "assets/dashboard/order.svg",
              "order",
              height,
              width,
              () {},
            ),
            dashboardItem(
              "assets/dashboard/payment.svg",
              "Payment",
              height,
              width,
              () {},
            ),
            dashboardItem(
              "assets/dashboard/sales.svg",
              "Sales History",
              height,
              width,
              () {
                //can be used to initialise category as well
                Provider.of<MenuProvider>(context, listen: false)
                    .resetCategory();
                animatedNavigatorPush(
                  context: context,
                  screen: const EditMenu(),
                );
              },
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
                animatedNavigatorPush(
                  context: context,
                  screen: const ManageEmployee(),
                );
              },
            ),
            dashboardItem(
              "assets/dashboard/inventory.svg",
              "Inventory",
              height,
              width,
              () {
                animatedNavigatorPush(
                  context: context,
                  screen: const EditSpecials(),
                );
              },
            ),
            dashboardItem(
              "assets/dashboard/analytics.svg",
              "Analytics",
              height,
              width,
              () {
                animatedNavigatorPush(
                  context: context,
                  screen: const EditCategory(),
                );
              },
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
