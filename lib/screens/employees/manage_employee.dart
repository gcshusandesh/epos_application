import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
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
                  child: Provider.of<DataProvider>(context, listen: true)
                          .employeeList
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
                            for (int i = 0;
                                i <
                                    Provider.of<DataProvider>(context,
                                            listen: true)
                                        .employeeList
                                        .length;
                                i++)
                              buildEmployeeRow(i),
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
                  Provider.of<DataProvider>(context, listen: true)
                      .employeeList[index]
                      .name,
                  width),
              buildCustomText(
                Provider.of<DataProvider>(context, listen: true)
                        .employeeList[index]
                        .status
                    ? "Active"
                    : "Inactive",
                Provider.of<DataProvider>(context, listen: true)
                        .employeeList[index]
                        .status
                    ? Data.greenColor
                    : Data.redColor,
                width,
              )
            ],
          ),
        ),
        tableItem(
            Provider.of<DataProvider>(context, listen: true)
                .employeeList[index]
                .email,
            width),
        tableItem(
            Provider.of<DataProvider>(context, listen: true)
                .employeeList[index]
                .phone,
            width),
        tableItem(
            Provider.of<DataProvider>(context, listen: true)
                .employeeList[index]
                .gender,
            width),
        buildCupertinoSwitch(
            index: index,
            value: Provider.of<DataProvider>(context, listen: true)
                .employeeList[index]
                .status,
            onChanged: (value) {
              Provider.of<DataProvider>(context, listen: false)
                  .changeEmployeeStatus(index);
            }),
      ],
    );
  }
}
