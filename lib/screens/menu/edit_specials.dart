import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSpecials extends StatefulWidget {
  const EditSpecials({super.key});
  static const routeName = "editSpecials";

  @override
  State<EditSpecials> createState() => _EditSpecialsState();
}

class _EditSpecialsState extends State<EditSpecials> {
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

      // Get Specials Data from API
      Provider.of<DataProvider>(context, listen: false).getSpecialsList();

      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(child: buildTitleText("Specials", Data.darkTextColor, width)),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Provider.of<DataProvider>(context, listen: true)
                          .specialsList
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
                                      tableTitle("Name", width),
                                      tableTitle("Image", width),
                                      tableTitle("Action", width),
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
                                  tableTitle("Name", width),
                                  tableTitle("Image", width),
                                  tableTitle("Action", width),
                                  tableTitle("Status", width),
                                ]),
                            for (int index = 0;
                                index <
                                    Provider.of<DataProvider>(context,
                                            listen: true)
                                        .specialsList
                                        .length;
                                index++)
                              buildSpecialsRow(index),
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

  TableRow buildSpecialsRow(int index) {
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
                      .specialsList[index]
                      .name,
                  width),
              buildCustomText(
                Provider.of<DataProvider>(context, listen: true)
                        .specialsList[index]
                        .status
                    ? "Active"
                    : "Inactive",
                Provider.of<DataProvider>(context, listen: true)
                        .specialsList[index]
                        .status
                    ? Data.greenColor
                    : Data.redColor,
                width,
              )
            ],
          ),
        ),
        Image.asset(
          Provider.of<DataProvider>(context, listen: true)
              .specialsList[index]
              .image,
          height: height * 10,
          width: width * 20,
          fit: BoxFit.fill,
        ),
        iconButton(
          "assets/profile_icon.svg",
          height,
          width,
          () {
            // delete item from list
            Provider.of<DataProvider>(context, listen: false)
                .deleteSpecials(index);
          },
        ),
        buildCupertinoSwitch(
            index: index,
            value: Provider.of<DataProvider>(context, listen: true)
                .specialsList[index]
                .status,
            onChanged: (value) {
              Provider.of<DataProvider>(context, listen: false)
                  .changeStatusSpecials(index);
            }),
      ],
    );
  }
}
