import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/inventory_provider.dart';
import 'package:epos_application/screens/inventory/update_inventory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditUnitType extends StatefulWidget {
  const EditUnitType({super.key});

  @override
  State<EditUnitType> createState() => _EditUnitTypeState();
}

class _EditUnitTypeState extends State<EditUnitType> {
  @override
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      init = false;
    }
  }

  void _fetchData() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<InventoryProvider>(context, listen: false).getUnitTypes(
        accessToken:
            Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
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
            ? onLoading(width: width, context: context)
            : const SizedBox(),
      ],
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            customTopSection(
                context: context,
                height: height,
                text: "Inventory Unit Type",
                width: width,
                onTap: () {
                  _fetchData();
                }),
            SizedBox(
              height: height * 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                iconButton(
                  "assets/svg/add.svg",
                  height,
                  width,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateInventory()),
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
                  isSelected: isEditing,
                  context: context,
                ),
              ],
            ),
            SizedBox(
              height: height * 2,
            ),
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
          child: Provider.of<InventoryProvider>(context, listen: true)
                  .unitTypes
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
                              tableTitle("Quantity Type", width),
                              tableTitle("Action", width),
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
                          tableTitle("Quantity Type", width),
                          tableTitle("Action", width),
                        ]),
                    for (int index = 0;
                        index <
                            Provider.of<InventoryProvider>(context,
                                    listen: true)
                                .unitTypes
                                .length;
                        index++)
                      buildUnitRows(index),
                  ],
                ),
        ),
      ),
    );
  }

  TableRow buildUnitRows(int index) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width, context),
        InkWell(
          onTap: () {
            if (isEditing) {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => UpdateData(
              //         isCategory: true,
              //         category:
              //         Provider.of<MenuProvider>(context, listen: false)
              //             .categoryList[index],
              //         isEdit: true,
              //         index: index,
              //       )),
              // );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                tableItem(
                    Provider.of<InventoryProvider>(context, listen: true)
                        .unitTypes[index]
                        .name,
                    width,
                    context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: width),
                      child: isEditing
                          ? label(
                              text: "edit",
                              height: height,
                              width: width,
                              labelColor: Provider.of<InfoProvider>(context,
                                      listen: true)
                                  .systemInfo
                                  .iconsColor)
                          : const SizedBox(),
                    ),
                  ],
                )
              ],
            ),
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
            onTap: () async {
              // do not delete if unit has items
            },
          ),
        ),
      ],
    );
  }
}
