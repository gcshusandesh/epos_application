import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MakeEmployee extends StatefulWidget {
  const MakeEmployee({super.key});
  static const routeName = "makeEmployee";

  @override
  State<MakeEmployee> createState() => _MakeEmployeeState();
}

class _MakeEmployeeState extends State<MakeEmployee> {
  bool init = true;
  late double height;
  late double width;

  List<Employee> employeeList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      // Get Employee Data from API
      Provider.of<DataProvider>(context, listen: false).getEmployeeData();
      employeeList =
          Provider.of<DataProvider>(context, listen: false).employeeList;

      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(
              child: buildTitleText("My Employees", Data.darkTextColor, width)),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: employeeList.isEmpty
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
                                      tableTitle("S.N."),
                                      tableTitle("Full Name"),
                                      tableTitle("Email"),
                                      tableTitle("Phone"),
                                      tableTitle("Gender"),
                                      tableTitle("Status"),
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
                                  tableTitle("S.N."),
                                  tableTitle("Full Name"),
                                  tableTitle("Email"),
                                  tableTitle("Phone"),
                                  tableTitle("Gender"),
                                  tableTitle("Status"),
                                ]),
                            for (int i = 0; i < employeeList.length; i++)
                              buildEmployeeRow(i, employeeList[i]),
                          ],
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  TableRow buildEmployeeRow(int index, Employee employee) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              tableItem(employee.name),
              buildCustomText(
                employee.status ? "Active" : "Inactive",
                employee.status ? Data.greenColor : Data.redColor,
                width,
              )
            ],
          ),
        ),
        tableItem(employee.email),
        tableItem(employee.phone),
        tableItem(employee.gender),
        buildCupertinoSwitch(index: index),
      ],
    );
  }

  CupertinoSwitch buildCupertinoSwitch({required int index}) {
    return CupertinoSwitch(
      activeColor: Data.primaryColor,
      value: employeeList[index].status,
      onChanged: (bool newValue) {
        setState(() {
          employeeList[index].status = newValue;
        });
      },
    );
  }

  Widget tableTitle(String text) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: buildBodyText(
        text,
        Data.lightGreyTextColor,
        width,
        fontFamily: "RobotoMedium",
      ),
    ));
  }

  Widget tableItem(String text) {
    return Center(
        child: buildSmallText(
      text,
      Data.lightGreyTextColor,
      width,
    ));
  }
}
