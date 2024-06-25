import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditCategory extends StatefulWidget {
  const EditCategory({super.key});
  static const routeName = "editCategory";

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
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
                text: "Category",
                height: height,
                width: width),
            SizedBox(height: height * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                iconButton(
                  "assets/svg/add.svg",
                  height,
                  width,
                  () {
                    //do something
                  },
                ),
                SizedBox(width: width),
                iconButton(
                  "assets/svg/edit.svg",
                  height,
                  width,
                  () {
                    //do something
                  },
                ),
                SizedBox(width: width),
                textButton(
                  text: "Change Priority",
                  height: height,
                  width: width,
                  textColor: Data.iconsColor,
                  buttonColor: Data.iconsColor,
                  onTap: () {},
                )
              ],
            ),
            SizedBox(height: height * 2),
            tableSection(context),
          ],
        ),
      ),
    );
  }

  Expanded tableSection(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Provider.of<DataProvider>(context, listen: true)
                  .categoryList
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
                          left: BorderSide(color: Colors.black, width: 1),
                          right: BorderSide(color: Colors.black, width: 1),
                          bottom: BorderSide(color: Colors.black, width: 1),
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
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                        decoration:
                            const BoxDecoration(color: Data.lightGreyBodyColor),
                        children: [
                          tableTitle("S.N.", width),
                          tableTitle("Name", width),
                          tableTitle("Image", width),
                          tableTitle("Action", width),
                          tableTitle("Status", width),
                        ]),
                    for (int index = 0;
                        index <
                            Provider.of<DataProvider>(context, listen: true)
                                .categoryList
                                .length;
                        index++)
                      buildSpecialsRow(index),
                  ],
                ),
        ),
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
                      .categoryList[index]
                      .name,
                  width),
              buildCustomText(
                Provider.of<DataProvider>(context, listen: true)
                        .categoryList[index]
                        .status
                    ? "Active"
                    : "Inactive",
                Provider.of<DataProvider>(context, listen: true)
                        .categoryList[index]
                        .status
                    ? Data.greenColor
                    : Data.redColor,
                width,
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 5, vertical: 15.0),
          child: Image.asset(
            Provider.of<DataProvider>(context, listen: true)
                .categoryList[index]
                .image,
            height: height * 10,
            width: width * 20,
            fit: BoxFit.fill,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 6),
          child: textButton(
            text: "Delete",
            height: height,
            width: width,
            textColor: Data.redColor,
            buttonColor: Data.redColor,
            onTap: () {
              // delete item from list
              Provider.of<DataProvider>(context, listen: false)
                  .removeCategory(index);
            },
          ),
        ),
        buildCupertinoSwitch(
            index: index,
            value: Provider.of<DataProvider>(context, listen: true)
                .categoryList[index]
                .status,
            onChanged: (value) {
              Provider.of<DataProvider>(context, listen: false)
                  .changeCategoryStatus(index);
            }),
      ],
    );
  }
}
