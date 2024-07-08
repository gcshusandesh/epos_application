import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/user_provider.dart';
import 'package:epos_application/screens/employees/create_employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageEmployee extends StatefulWidget {
  const ManageEmployee({super.key});
  static const routeName = "manageEmployee";

  @override
  State<ManageEmployee> createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
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

  @override
  Widget build(BuildContext context) {
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
            editSection(),
            SizedBox(height: height * 2),
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
        // SizedBox(width: width),
        // iconButton(
        //   "assets/svg/edit.svg",
        //   height,
        //   width,
        //   () {
        //     //do something
        //   },
        //   context: context,
        // ),
      ],
    );
  }

  TableRow buildEmployeeRow(int index) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              tableItem(
                  Provider.of<UserProvider>(context, listen: true)
                      .userList[index]
                      .name,
                  width),
              buildCustomText(
                Provider.of<UserProvider>(context, listen: true)
                        .userList[index]
                        .blocked
                    ? "Active"
                    : "Inactive",
                Provider.of<UserProvider>(context, listen: true)
                        .userList[index]
                        .blocked
                    ? Data.greenColor
                    : Data.redColor,
                width,
              )
            ],
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
        tableItem(
            Provider.of<UserProvider>(context, listen: true)
                .userList[index]
                .userType
                .name
                .toString(),
            width),
        buildCupertinoSwitch(
          index: index,
          value: !Provider.of<UserProvider>(context, listen: true)
              .userList[index]
              .blocked,
          onChanged: (value) {
            Provider.of<UserProvider>(context, listen: false)
                .changeUserStatus(index);
          },
          context: context,
        ),
      ],
    );
  }
}
