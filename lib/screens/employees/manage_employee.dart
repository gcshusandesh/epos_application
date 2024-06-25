import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/data_provider.dart';
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

  List<Employee> employeeList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      // Defer the call to getEmployeeData
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get Employee Data from API
      Provider.of<DataProvider>(context, listen: false).getEmployeeData();
      employeeList =
          Provider.of<DataProvider>(context, listen: false).employeeList;
      // });

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
                                      tableTitle("S.N.", width),
                                      tableTitle("Full Name", width),
                                      tableTitle("Email", width),
                                      tableTitle("Phone", width),
                                      tableTitle("Gender", width),
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
                                  tableTitle("Status", width),
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
        tableItem((index + 1).toString(), width),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              tableItem(employee.name, width),
              buildCustomText(
                employee.status ? "Active" : "Inactive",
                employee.status ? Data.greenColor : Data.redColor,
                width,
              )
            ],
          ),
        ),
        tableItem(employee.email, width),
        tableItem(employee.phone, width),
        tableItem(employee.gender, width),
        buildCupertinoSwitch(
            index: index,
            value: employeeList[index].status,
            onChanged: (value) {
              setState(() {
                employeeList[index].status = value;
              });
            }),
      ],
    );
  }
}
