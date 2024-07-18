import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
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
  bool isLoading = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      setState(() {
        isLoading = true;
      });
      populateDashboard();
      // TODO: remove this api call and replace with settings saved in cache
      await Provider.of<InfoProvider>(context, listen: false).getSettings(
        context: context,
      );

      /// Populate Dashboard list

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        // Get Specials Data from API
        Provider.of<MenuProvider>(context, listen: false)
            .getSpecialsList(init: true);

        // Get Employee Data from API
        Provider.of<UserProvider>(context, listen: false).getUserList(
            user: Provider.of<AuthProvider>(context, listen: false).user,
            context: context);

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

  List<bool> dashboardVisibility = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  void populateDashboard() async {
    if (Provider.of<AuthProvider>(context, listen: false).user.userType ==
        UserType.owner) {
      /// Owner
      dashboardVisibility = [
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
      ];
    } else if (Provider.of<AuthProvider>(context, listen: false)
            .user
            .userType ==
        UserType.manager) {
      /// Manager
      dashboardVisibility = [
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
      ];
    } else if (Provider.of<AuthProvider>(context, listen: false)
            .user
            .userType ==
        UserType.chef) {
      /// Chef
      dashboardVisibility = [
        false,
        false,
        false,
        false,
        true,
        true,
        false,
        false,
      ];
    } else {
      ///default type is waiter
      dashboardVisibility = [
        true,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
      ];
    }
  }

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
    init = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          buildBody(context),
          isLoading
              ? Center(
                  child: onLoading(width: width, context: context),
                )
              : const SizedBox(),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Center buildBody(BuildContext context) {
    return Center(
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
              isVisible: dashboardVisibility[0],
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
              isVisible: dashboardVisibility[1],
            ),
            dashboardItem(
              "assets/dashboard/payment.svg",
              "Payment",
              height,
              width,
              () {},
              context,
              isVisible: dashboardVisibility[2],
            ),
            dashboardItem(
              "assets/dashboard/sales.svg",
              "Sales History",
              height,
              width,
              () {},
              context,
              isVisible: dashboardVisibility[3],
            ),
          ],
        ),
        SizedBox(
          height: height * 5,
        ),
        Row(
          mainAxisAlignment:
              Provider.of<AuthProvider>(context, listen: true).user.userType ==
                      UserType.chef
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
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
              isVisible: dashboardVisibility[4],
            ),
            SizedBox(
                width: Provider.of<AuthProvider>(context, listen: true)
                            .user
                            .userType ==
                        UserType.chef
                    ? width * 20
                    : 0),
            dashboardItem(
              "assets/dashboard/employees.svg",
              "Kitchen",
              height,
              width,
              () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const ManageEmployee()),
                // );
              },
              context,
              isVisible: dashboardVisibility[5],
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
              isVisible: dashboardVisibility[6],
            ),
            dashboardItem(
              "assets/dashboard/analytics.svg",
              "Analytics",
              height,
              width,
              () {},
              context,
              isVisible: dashboardVisibility[7],
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
