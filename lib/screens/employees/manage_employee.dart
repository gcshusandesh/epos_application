import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/user_provider.dart';
import 'package:epos_application/screens/employees/create_employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ManageEmployee extends StatefulWidget {
  const ManageEmployee({super.key});
  static const routeName = "manageEmployee";

  @override
  State<ManageEmployee> createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
  bool isLoading = false;
  bool isEditing = false;
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

      init = false;
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<UserProvider>(context, listen: false).getUserList(
        user: Provider.of<AuthProvider>(context, listen: false).user,
        context: context);
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
            ? Center(
                child: onLoading(width: width, context: context),
              )
            : const SizedBox(),
      ],
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            topSection(
                context: context,
                text: "My Employees",
                height: height,
                width: width),
            SizedBox(height: height * 2),
            Provider.of<AuthProvider>(context, listen: false).user.userType ==
                    UserType.owner
                ? editSection()
                : const SizedBox(),
            SizedBox(
                height: Provider.of<AuthProvider>(context, listen: false)
                            .user
                            .userType ==
                        UserType.owner
                    ? height * 2
                    : 0),
            Expanded(
              child: SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Provider.of<UserProvider>(context, listen: true)
                          .userList
                          .isEmpty
                      ? Column(
                          children: [
                            Table(
                              border: TableBorder.all(color: Colors.black),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                    decoration: const BoxDecoration(
                                        color: Data.lightGreyBodyColor),
                                    children: [
                                      tableTitle("S.N.", width),
                                      tableTitle("Full Name", width),
                                      tableTitle("Email", width),
                                      tableTitle("Phone", width),
                                      tableTitle("Gender", width),
                                      tableTitle("User Type", width),
                                      tableTitle("Status", width),
                                    ]),
                              ],
                            ),
                            Container(
                              width: width * 100,
                              decoration: const BoxDecoration(
                                color: Data.lightGreyBodyColor,
                                border: Border(
                                  left:
                                      BorderSide(color: Colors.black, width: 1),
                                  right:
                                      BorderSide(color: Colors.black, width: 1),
                                  bottom:
                                      BorderSide(color: Colors.black, width: 1),
                                ),
                              ),
                              child: Center(
                                child: buildSmallText("No Data Available",
                                    Data.lightGreyTextColor, width),
                              ),
                            )
                          ],
                        )
                      : Table(
                          border: TableBorder.all(color: Colors.black),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                                decoration: const BoxDecoration(
                                    color: Data.lightGreyBodyColor),
                                children: [
                                  tableTitle("S.N.", width),
                                  tableTitle("Full Name", width),
                                  tableTitle("Email", width),
                                  tableTitle("Phone", width),
                                  tableTitle("Gender", width),
                                  tableTitle("User Type", width),
                                  tableTitle("Status", width),
                                ]),
                            for (int i = 0;
                                i <
                                    Provider.of<UserProvider>(context,
                                            listen: true)
                                        .userList
                                        .length;
                                i++)
                              buildEmployeeRow(i),
                          ],
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Row editSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        iconButton(
          isSvg: false,
          "",
          icon: Icons.refresh,
          height,
          width,
          () {
            _fetchData();
          },
          context: context,
        ),
        SizedBox(width: width),
        iconButton(
          "assets/svg/add.svg",
          height,
          width,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateEmployee()),
            );
          },
          context: context,
        ),
        SizedBox(width: width),
        iconButton(
          "assets/svg/edit.svg",
          height,
          width,
          () {
            setState(() {
              isEditing = !isEditing;
            });
          },
          context: context,
          isSelected: isEditing,
        ),
      ],
    );
  }

  TableRow buildEmployeeRow(int index) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width),
        InkWell(
          onTap: () {
            if (isEditing) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateEmployee(
                          isEdit: true,
                          user: Provider.of<UserProvider>(context, listen: true)
                              .userList[index],
                          index: index,
                        )),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                tableItem(
                    Provider.of<UserProvider>(context, listen: true)
                        .userList[index]
                        .name,
                    width),
                Row(
                  mainAxisAlignment: isEditing
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: [
                    buildCustomText(
                      !Provider.of<UserProvider>(context, listen: true)
                              .userList[index]
                              .isBlocked
                          ? "Active"
                          : "Inactive",
                      !Provider.of<UserProvider>(context, listen: true)
                              .userList[index]
                              .isBlocked
                          ? Data.greenColor
                          : Data.redColor,
                      width,
                    ),
                    isEditing
                        ? label(
                            text: "edit",
                            height: height,
                            width: width,
                            labelColor:
                                Provider.of<InfoProvider>(context, listen: true)
                                    .systemInfo
                                    .iconsColor)
                        : const SizedBox(),
                  ],
                )
              ],
            ),
          ),
        ),
        tableItem(
            Provider.of<UserProvider>(context, listen: true)
                .userList[index]
                .email,
            width),
        tableItem(
            Provider.of<UserProvider>(context, listen: true)
                .userList[index]
                .phone,
            width),
        tableItem(
            Provider.of<UserProvider>(context, listen: true)
                .userList[index]
                .gender,
            width),
        employeeLabel(
            text: Provider.of<UserProvider>(context, listen: true)
                .userList[index]
                .userType
                .name
                .toString(),
            height: height,
            width: width,
            labelColor: Provider.of<InfoProvider>(context, listen: false)
                .systemInfo
                .iconsColor),
        buildCupertinoSwitch(
          index: index,
          value: !Provider.of<UserProvider>(context, listen: true)
              .userList[index]
              .isBlocked,
          onChanged: (bool value) async {
            setState(() {
              isLoading = true;
            });
            bool isStatusUpdateSuccessful =
                await Provider.of<UserProvider>(context, listen: false)
                    .updateUserStatus(
              context: context,
              accessToken: Provider.of<AuthProvider>(context, listen: false)
                  .user
                  .accessToken!,
              id: Provider.of<UserProvider>(context, listen: false)
                  .userList[index]
                  .id!,
              isBlocked: !value,
            );

            ///need to provide opposite of value because the switch is already toggled
            setState(() {
              isLoading = false;
            });
            if (isStatusUpdateSuccessful) {
              if (mounted) {
                // Check if the widget is still mounted
                showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.success(
                    message: "User status successfully updated",
                  ),
                );

                Provider.of<UserProvider>(context, listen: false)
                    .changeUserStatusLocally(index);
              }
            } else {
              if (mounted) {
                // Check if the widget is still mounted
                showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.error(
                    message: "User status update failed",
                  ),
                );
              }
            }
          },
          context: context,
        ),
      ],
    );
  }

  Widget employeeLabel({
    required String text,
    required double height,
    required double width,
    required Color labelColor,
  }) {
    return Container(
      height: height * 3,
      margin: EdgeInsets.symmetric(horizontal: width * 1.5),
      decoration: BoxDecoration(
        color: labelColor,
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: buildSmallText(text, Colors.white, width * 0.8,
              fontFamily: "RobotoMedium"),
        ),
      ),
    );
  }
}
